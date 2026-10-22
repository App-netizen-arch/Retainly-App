import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/constants/matric_subjects.dart';
import '../../data/repositories/local_ai_repository.dart';
import '../../services/local_ocr_service.dart';

class OcrScanScreen extends StatefulWidget {
  const OcrScanScreen({super.key});

  @override
  State<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends State<OcrScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final LocalAiRepository _repository = LocalAiRepository();
  final LocalOcrService _ocr = LocalOcrService();

  bool _isProcessing = false;
  String? _error;
  String? _result;
  String? _previewPath;
  String? _status;
  int _currentPage = 0;
  int _totalPages = 0;
  bool _wasTruncated = false;

  String _selectedLanguage = 'eng+urd';
  String _selectedSubject = 'Mathematics';
  String _selectedBoard = 'PCTB';
  String _selectedClass = '9';

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) setState(() => _error = 'Camera permission is required to scan a page.');
        return;
      }
    }
    final picked = await _picker.pickImage(
      source: source,
      imageQuality: 95,
      maxWidth: 2400,
    );
    if (picked == null) return;
    await _processFile(picked.path, isPdf: false);
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: false,
    );
    if (result == null || result.files.single.path == null) return;
    await _processFile(result.files.single.path!, isPdf: true);
  }

  Future<void> _processFile(String filePath, {required bool isPdf}) async {
    if (_isProcessing) return;
    setState(() {
      _isProcessing = true;
      _error = null;
      _result = null;
      _previewPath = filePath;
      _status = 'Preparing local OCR…';
      _currentPage = 0;
      _totalPages = 0;
      _wasTruncated = false;
    });

    try {
      final String title = p.basenameWithoutExtension(filePath).trim().isEmpty
          ? 'Scanned study material'
          : p.basenameWithoutExtension(filePath);
      final storedPath = await _copyToLocalLibrary(filePath);
      if (mounted) setState(() => _previewPath = storedPath);

      if (isPdf) {
        final extracted = await _ocr.extractPdfText(
          storedPath,
          language: _selectedLanguage,
          onProgress: (current, total) {
            if (!mounted) return;
            setState(() {
              _currentPage = current;
              _totalPages = total;
              _status = 'Recognizing page $current of $total on this device…';
            });
          },
        );
        final drafts = <TextbookChunkDraft>[];
        for (final page in extracted.pages) {
          for (final text in _splitForIndex(page.text)) {
            drafts.add(TextbookChunkDraft(
              pageNumber: page.pageNumber,
              content: text,
              chapterTitle: null,
              language: _selectedLanguage,
              extractionMethod: 'tesseract_ocr',
            ));
          }
        }
        if (drafts.isEmpty) {
          throw StateError(
            'No text was recognized. Try a clearer scan, a different language, or a page crop with less background.',
          );
        }
        final textbookId = await _repository.addTextbook(
          title: title,
          localPath: storedPath,
          board: _selectedBoard,
          classLevel: _selectedClass,
          subject: _selectedSubject,
          language: _selectedLanguage,
          pageCount: extracted.totalPages,
        );
        await _repository.replaceTextbookChunks(textbookId, drafts);
        if (!mounted) return;
        setState(() {
          _result = extracted.fullText;
          _wasTruncated = extracted.truncated;
          _status = 'Saved locally and indexed as "$title".';
          _currentPage = extracted.pages.length;
          _totalPages = extracted.totalPages;
        });
      } else {
        setState(() => _status = 'Recognizing image on this device…');
        final text = await _ocr.extractImageText(
          storedPath,
          language: _selectedLanguage,
        );
        if (text.trim().isEmpty) {
          throw StateError(
            'No text was recognized. Try better lighting, a sharper photo, or another language setting.',
          );
        }
        final textbookId = await _repository.addTextbook(
          title: title,
          localPath: filePath,
          board: _selectedBoard,
          classLevel: _selectedClass,
          subject: _selectedSubject,
          language: _selectedLanguage,
          pageCount: 1,
        );
        await _repository.replaceTextbookChunks(
          textbookId,
          _splitForIndex(text)
              .map((content) => TextbookChunkDraft(
                    pageNumber: 1,
                    content: content,
                    language: _selectedLanguage,
                    extractionMethod: 'tesseract_ocr',
                  ))
              .toList(),
        );
        if (!mounted) return;
        setState(() {
          _result = text;
          _status = 'Saved locally and indexed as "$title".';
          _currentPage = 1;
          _totalPages = 1;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString().replaceFirst('Bad state: ', '');
        _status = null;
      });
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  Future<String> _copyToLocalLibrary(String sourcePath) async {
    final source = File(sourcePath);
    if (!await source.exists()) {
      throw const FileSystemException('The selected document is no longer available.');
    }
    final appDirectory = await getApplicationDocumentsDirectory();
    final libraryDirectory = Directory(p.join(appDirectory.path, 'textbooks'));
    await libraryDirectory.create(recursive: true);

    final originalName = p.basename(sourcePath).replaceAll(RegExp(r'[^a-zA-Z0-9._ -]'), '_');
    final safeName = originalName.isEmpty ? 'study_document' : originalName;
    final uniqueName = '${DateTime.now().millisecondsSinceEpoch}_$safeName';
    final target = p.join(libraryDirectory.path, uniqueName);
    return (await source.copy(target)).path;
  }

  List<String> _splitForIndex(String source) {
    final normalized = source.replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) return const [];
    const maxChars = 1200;
    final chunks = <String>[];
    final paragraphs = normalized.split(RegExp(r'\n\s*\n'));
    var buffer = StringBuffer();

    void flush() {
      final value = buffer.toString().trim();
      if (value.isNotEmpty) chunks.add(value);
      buffer = StringBuffer();
    }

    for (final paragraph in paragraphs) {
      final value = paragraph.trim();
      if (value.isEmpty) continue;
      if (value.length > maxChars) {
        flush();
        for (var start = 0; start < value.length; start += maxChars) {
          final end = (start + maxChars < value.length) ? start + maxChars : value.length;
          chunks.add(value.substring(start, end).trim());
        }
        continue;
      }
      if (buffer.length > 0 && buffer.length + value.length + 2 > maxChars) {
        flush();
      }
      if (buffer.length > 0) buffer.write('\n\n');
      buffer.write(value);
    }
    flush();
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final languages = LocalOcrService.languageOptions;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline OCR & Book Import'),
        actions: [
          IconButton(
            tooltip: 'Ask Retainly AI about indexed books',
            onPressed: () => context.push('/ai/chat'),
            icon: const Icon(Icons.auto_awesome),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phonelink_lock_outlined, color: colors.primary, size: 28),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text('Your pages stay on this device', style: Theme.of(context).textTheme.titleMedium),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Retainly renders PDF pages and runs OCR locally. Recognized text is saved in the local textbook index so the chat assistant can search it. OCR does not upload the document.',
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Punjabi note: the included pan model recognizes Gurmukhi, not Shahmukhi. For Pakistani Punjabi written in Shahmukhi, use Urdu + English as an experimental fallback and verify the output.',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _selectedLanguage,
            decoration: const InputDecoration(
              labelText: 'Recognition language',
              border: OutlineInputBorder(),
            ),
            items: languages.entries
                .map((entry) => DropdownMenuItem(
                      value: entry.value,
                      child: Text(entry.key),
                    ))
                .toList(),
            onChanged: _isProcessing ? null : (value) {
              if (value != null) setState(() => _selectedLanguage = value);
            },
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedSubject,
            decoration: const InputDecoration(labelText: 'Subject', border: OutlineInputBorder()),
            items: MatricSubjects.subjects
                .map((subject) => DropdownMenuItem(
                      value: subject['name'] as String,
                      child: Text(subject['name'] as String),
                    ))
                .toList(),
            onChanged: _isProcessing ? null : (value) {
              if (value != null) setState(() => _selectedSubject = value);
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedBoard,
                  decoration: const InputDecoration(labelText: 'Board', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: 'PCTB', child: Text('Punjab (PCTB)')),
                    DropdownMenuItem(value: 'FBISE', child: Text('FBISE')),
                    DropdownMenuItem(value: 'Other', child: Text('Other')),
                  ],
                  onChanged: _isProcessing ? null : (value) {
                    if (value != null) setState(() => _selectedBoard = value);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedClass,
                  decoration: const InputDecoration(labelText: 'Class', border: OutlineInputBorder()),
                  items: const [
                    DropdownMenuItem(value: '9', child: Text('Class 9')),
                    DropdownMenuItem(value: '10', child: Text('Class 10')),
                  ],
                  onChanged: _isProcessing ? null : (value) {
                    if (value != null) setState(() => _selectedClass = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: _isProcessing ? null : () => _pickImage(ImageSource.camera),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Scan from camera'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isProcessing ? null : () => _pickImage(ImageSource.gallery),
            icon: const Icon(Icons.image_outlined),
            label: const Text('Choose an image'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _isProcessing ? null : _pickPdf,
            icon: const Icon(Icons.picture_as_pdf_outlined),
            label: const Text('Import and scan PDF'),
          ),
          if (_isProcessing) ...[
            const SizedBox(height: 18),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(_status ?? 'Processing locally…', textAlign: TextAlign.center),
            if (_totalPages > 0)
              Text('Page $_currentPage of $_totalPages', textAlign: TextAlign.center),
          ],
          if (_status != null && !_isProcessing) ...[
            const SizedBox(height: 14),
            Text(_status!, style: TextStyle(color: colors.primary)),
          ],
          if (_wasTruncated) ...[
            const SizedBox(height: 8),
            const Text(
              'This PDF has more pages than the current 250-page safety limit. The first 250 pages were indexed. Scan the remaining section separately if needed.',
            ),
          ],
          if (_previewPath != null && !(_previewPath!.toLowerCase().endsWith('.pdf'))) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_previewPath!),
                height: 180,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 14),
            Card(
              color: colors.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Text(_error!, style: TextStyle(color: colors.onErrorContainer)),
              ),
            ),
          ],
          if (_result != null) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(child: Text('Recognized text', style: Theme.of(context).textTheme.titleLarge)),
                IconButton(
                  tooltip: 'Open AI chat',
                  onPressed: () => context.push('/ai/chat'),
                  icon: const Icon(Icons.chat_outlined),
                ),
              ],
            ),
            const Text(
              'OCR can mistake letters, equations and punctuation. Review this output against the original page before relying on it.',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 8),
            SelectableText(_result!),
          ],
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
