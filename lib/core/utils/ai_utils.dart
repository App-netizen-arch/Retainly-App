class AiTextSanitizer {
  static final _metaTagPattern = RegExp(
    r'\*\*Draft Response.*?\*\*|User Safety:\s*(?:safe|unsafe)|'
    r'\*\*Review.*?\*\*|'
    r'Please review these questions.*?\n',
    dotAll: true,
  );
  static final _boldPattern = RegExp(r'\*{1,2}(.+?)\*{1,2}');
  static final _italicPattern = RegExp(r'(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)');
  static final _headerPattern = RegExp(r'^#{1,6}\s+', multiLine: true);
  static final _bulletPattern = RegExp(r'^(\s*)([-*+])\s+', multiLine: true);
  static final _numberedListPattern = RegExp(r'^\s*\d+[\.\)]\s*', multiLine: true);
  static final _quotePattern = RegExp(r'^>\s+', multiLine: true);
  static final _codePattern = RegExp(r'`(.+?)`');
  static final _strikePattern = RegExp(r'~~(.+?)~~');
  static final _linkPattern = RegExp(r'\[([^\]]+)\]\([^\)]+\)');
  static final _tableRowPattern = RegExp(r'^\s*\|.*\|\s*$');
  static final _tableDividerPattern = RegExp(r'^\s*\|?[\s\-:|]+\|?\s*$');
  static final _multipleSpacesPattern = RegExp(r'[ \t]+');
  static final _trailingWhitespacePattern = RegExp(r'[ \t]+$', multiLine: true);

  static String sanitize(String? raw) {
    if (raw == null || raw.isEmpty) return raw ?? '';

    String text = raw;
    text = text.replaceAll(_metaTagPattern, '');

    final lines = text.split('\n');
    final stripped = <String>[];
    var inCodeBlock = false;
    var lastWasEmpty = false;

    for (final line in lines) {
      if (line.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        stripped.add(line);
        lastWasEmpty = false;
        continue;
      }

      if (inCodeBlock) {
        stripped.add(line);
        lastWasEmpty = false;
        continue;
      }

      final trimmed = line.trim();
      if (_tableDividerPattern.hasMatch(trimmed)) {
        if (!lastWasEmpty) stripped.add('');
        lastWasEmpty = true;
        continue;
      }
      if (_tableRowPattern.hasMatch(trimmed)) {
        final cells = trimmed
            .split('|')
            .map((cell) => cell.trim())
            .where((cell) => cell.isNotEmpty && !_isTableDivider(cell))
            .toList();
        if (cells.isNotEmpty) {
          stripped.add(cells.join(' • '));
        }
        lastWasEmpty = false;
        continue;
      }

      if (trimmed.isEmpty) {
        if (!lastWasEmpty) stripped.add('');
        lastWasEmpty = true;
        continue;
      }

      var processed = trimmed;
      processed = processed.replaceAllMapped(_boldPattern, (match) => match.group(1) ?? '');
      processed = processed.replaceAllMapped(_italicPattern, (match) => match.group(1) ?? '');
      processed = processed.replaceAll(_headerPattern, '');
      processed = processed.replaceAllMapped(_bulletPattern, (match) => '');
      processed = processed.replaceAll(_numberedListPattern, '');
      processed = processed.replaceAll(_quotePattern, '');
      processed = processed.replaceAllMapped(_codePattern, (match) => match.group(1) ?? '');
      processed = processed.replaceAllMapped(_strikePattern, (match) => match.group(1) ?? '');
      processed = processed.replaceAllMapped(_linkPattern, (match) => match.group(1) ?? '');

      stripped.add(processed);
      lastWasEmpty = false;
    }

    final result = <String>[];
    inCodeBlock = false;
    for (final line in stripped) {
      if (line.startsWith('```')) {
        inCodeBlock = !inCodeBlock;
        result.add(line);
        continue;
      }
      if (inCodeBlock) {
        result.add(line);
      } else {
        final collapsed = line.replaceAll(_multipleSpacesPattern, ' ');
        result.add(collapsed.replaceAll(_trailingWhitespacePattern, ''));
      }
    }

    return result.join('\n');
  }

  static bool _isTableDivider(String cell) =>
      cell.replaceAll(RegExp(r'[\s\-:]'), '').isEmpty;
}

class SubTaskCleaner {
  static final _pipePattern = RegExp(r'\|');
  static final _dividerPattern = RegExp(r'^\s*\|?[\s\-:|]+\|?\s*$');
  static final _tableRowPattern = RegExp(r'^\s*\|.*\|\s*$');
  static final _numberPrefixPattern = RegExp(r'^\s*\d+[\.\)]\s*');
  static final _bulletPattern = RegExp(r'^\s*[-*+]\s+');
  static final _markdownBoldPattern = RegExp(r'\*{1,2}(.*?)\*{1,2}');
  static final _multipleSpacesPattern = RegExp(r'[ \t]+');
  static final _trimPattern = RegExp(r'^\s+|\s+$');

  static String clean(String? raw) {
    if (raw == null || raw.isEmpty) return raw ?? '';

    String text = raw.trim();
    if (_dividerPattern.hasMatch(text)) return '';

    final lines = text.split('\n');
    for (var i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();
      if (_dividerPattern.hasMatch(trimmed) || _tableRowPattern.hasMatch(trimmed)) {
        lines[i] = lines[i].replaceAll(_pipePattern, ' ');
      }
    }
    text = lines.join('\n');

    text = text.replaceAllMapped(
      _markdownBoldPattern,
      (match) => match.group(1)?.trim() ?? '',
    );
    text = text.replaceAll(_numberPrefixPattern, '');
    text = text.replaceAll(_bulletPattern, '');
    text = text.replaceFirst(RegExp(r'^#{1,6}\s*'), '');
    text = text.replaceAll(_multipleSpacesPattern, ' ');
    text = text.replaceAll(_trimPattern, '');

    return text;
  }
}
