import 'dart:io';
import 'package:flutter/services.dart';

class ShortcutService {
  static const _channel = MethodChannel('app_shortcuts');

  static Future<bool> checkFocusShortcut() async {
    try {
      final method =
          Platform.isIOS ? 'checkFocusShortcutIOS' : 'checkFocusShortcut';
      final result = await _channel.invokeMethod<bool>(method);
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  static Future<void> clearFocusShortcut() async {
    try {
      final method =
          Platform.isIOS ? 'clearFocusShortcutIOS' : 'clearFocusShortcut';
      await _channel.invokeMethod<void>(method);
    } on PlatformException {
      // Ignore
    }
  }

  static Future<void> setFocusShortcut() async {
    try {
      final method =
          Platform.isIOS ? 'setFocusShortcutIOS' : 'setFocusShortcut';
      await _channel.invokeMethod<void>(method);
    } on PlatformException {
      // Ignore
    }
  }
}
