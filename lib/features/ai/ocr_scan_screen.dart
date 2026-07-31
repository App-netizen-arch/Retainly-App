import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/feature_flags.dart';
import '../../services/ai_service.dart';

class OcrScanScreen extends ConsumerStatefulWidget {
  const OcrScanScreen({super.key});

  @override
  ConsumerState<OcrScanScreen> createState() => _OcrScanScreenState();
}

class _OcrScanScreenState extends ConsumerState<OcrScanScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String? _error;
  String? _result;
  File? _previewFile;

  Future<void> _pickImage() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      setState(() => _error = 'Camera permission is required');
      return;
    }
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return;
    setState(() {
      _previewFile = File(picked.path);
      _error = null;
      _result = null;
    });
    await _processOcr(picked.path);
  }

  Future<void> _pickPdf() async {
    if (!FeatureFlags.aiAssistance) {
      setState(() {
        _isProcessing = false;
        _error = 'OCR is unavailable in local-only mode';
        _result = null;
      });
      return;
    }
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result == null || result.files.single.path == null) return;
    final path = result.files.single.path!;
    setState(() {
      _previewFile = File(path);
      _error = null;
      _result = null;
    });
    await _processOcr(path);
  }

  Future<void> _processOcr(String filePath) async {
    setState(() {
      _isProcessing = true;
      _error = null;
      _result = null;
    });
    try {
      final service = AIService();
      final jobId = await service.startOcrJob('local_user', filePath);
      if (jobId == null ||
          jobId.startsWith('OCR') ||
          jobId.startsWith('No internet')) {
        setState(() => _error = jobId ?? 'OCR failed');
        return;
      }
      for (var i = 0; i < 20; i++) {
        await Future.delayed(const Duration(seconds: 2));
        final data = await service.getOcrResult('local_user', jobId);
        if (data != null) {
          final extracted = data['extractedText'] as String?;
          if (extracted != null && extracted.isNotEmpty) {
            setState(() => _result = extracted);
          } else if (data['status'] == 'completed') {
            setState(() => _result = 'OCR completed. No text extracted.');
          }
          break;
        }
      }
    } catch (e) {
      setState(() => _error = 'Unexpected error: $e');
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Document')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_previewFile != null) Image.file(_previewFile!, height: 200),
            if (_isProcessing)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Processing...'),
                ],
              ),
            if (_result != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Extracted Text:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(_result!),
                  const SizedBox(height: 16),
                ],
              ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _pickImage,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Scan from Camera'),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _isProcessing ? null : _pickPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Scan PDF Document'),
            ),
          ],
        ),
      ),
    );
  }
}
