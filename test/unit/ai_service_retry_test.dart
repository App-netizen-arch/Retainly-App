import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:test/test.dart';
import 'package:retainly/services/ai_service.dart';
import 'package:retainly/services/connectivity_service.dart';

class FakeHttpClient extends http.BaseClient {
  final List<http.Response> _responses;
  int _callCount = 0;

  FakeHttpClient(this._responses);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = _responses[_callCount % _responses.length];
    _callCount++;
    final stream =
        http.ByteStream.fromBytes(utf8.encode(response.body));
    return http.StreamedResponse(
      stream,
      response.statusCode,
      headers: response.headers,
    );
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    ConnectivityService.setOnlineOverride(true);
  });

  tearDown(() {
    ConnectivityService.setOnlineOverride(null);
  });

  group('AIService - Retry / Backoff', () {
    test('callAiProxy retries on 429 then succeeds', () async {
      final client = FakeHttpClient([
        http.Response('{"output": ""}', 429),
        http.Response(jsonEncode({'output': 'Success after retry'}), 200),
      ]);
      final service = AIService();
      await service.setAiConsent(true);
      await service.acceptCostWarning();
      await service.acceptAiPolicy();
      final result = await service.callAiProxy(
        userId: 'user1',
        model: 'openrouter/free',
        systemPrompt: 'System',
        userPrompt: 'Question',
        client: client,
      );
      expect(result, 'Success after retry');
      expect(client._callCount, 2);
    });

    test('callAiProxy retries on 502 then succeeds', () async {
      final client = FakeHttpClient([
        http.Response('Bad Gateway', 502),
        http.Response(jsonEncode({'output': 'Recovered'}), 200),
      ]);
      final service = AIService();
      await service.setAiConsent(true);
      await service.acceptCostWarning();
      await service.acceptAiPolicy();
      final result = await service.callAiProxy(
        userId: 'user1',
        model: 'openrouter/free',
        systemPrompt: 'System',
        userPrompt: 'Question',
        client: client,
      );
      expect(result, 'Recovered');
      expect(client._callCount, 2);
    });

    test('callAiProxy returns error immediately on 404 (no retry)', () async {
      final client = FakeHttpClient([
        http.Response('Not Found', 404),
      ]);
      final service = AIService();
      await service.setAiConsent(true);
      await service.acceptCostWarning();
      await service.acceptAiPolicy();
      final result = await service.callAiProxy(
        userId: 'user1',
        model: 'openrouter/free',
        systemPrompt: 'System',
        userPrompt: 'Question',
        client: client,
      );
      expect(result, startsWith('AI_ERROR:'));
      expect(client._callCount, 1);
    });

    test('callAiProxy returns error on empty output', () async {
      final client = FakeHttpClient([
        http.Response(jsonEncode({'output': ''}), 200),
      ]);
      final service = AIService();
      await service.setAiConsent(true);
      await service.acceptCostWarning();
      await service.acceptAiPolicy();
      final result = await service.callAiProxy(
        userId: 'user1',
        model: 'openrouter/free',
        systemPrompt: 'System',
        userPrompt: 'Question',
        client: client,
      );
      expect(result, startsWith('AI_ERROR:'));
      expect(client._callCount, 1);
    });

    test('callAiProxy prefixes errors with AI_ERROR:', () async {
      final client = FakeHttpClient([
        http.Response('rate limited', 429),
        http.Response('rate limited', 429),
        http.Response('rate limited', 429),
        http.Response('rate limited', 429),
      ]);
      final service = AIService();
      await service.setAiConsent(true);
      await service.acceptCostWarning();
      await service.acceptAiPolicy();
      final result = await service.callAiProxy(
        userId: 'user1',
        model: 'openrouter/free',
        systemPrompt: 'System',
        userPrompt: 'Question',
        client: client,
      );
      expect(result, startsWith('AI_ERROR:'));
      expect(client._callCount, 4);
    });

    test('callAiProxy does not leak raw exception messages', () async {
      final client = FakeHttpClient([
        http.Response('Internal Server Error', 500),
        http.Response('Internal Server Error', 500),
        http.Response('Internal Server Error', 500),
        http.Response('Internal Server Error', 500),
      ]);
      final service = AIService();
      await service.setAiConsent(true);
      await service.acceptCostWarning();
      await service.acceptAiPolicy();
      final result = await service.callAiProxy(
        userId: 'user1',
        model: 'openrouter/free',
        systemPrompt: 'System',
        userPrompt: 'Question',
        client: client,
      );
      expect(result, isNot(contains('Exception')));
      expect(result, isNot(contains('Stack trace')));
      expect(result, isNot(contains('SocketException')));
    });
  });
}
