import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class PdfViewerScreen extends StatefulWidget {
  final String path;
  final String title;

  const PdfViewerScreen({super.key, required this.path, required this.title});

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _password;
  bool _needPassword = false;

  void _showPasswordDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Password Required'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('This PDF is password-protected.'),
                const SizedBox(height: 12),
                TextField(
                  controller: controller,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: 'Enter password',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final pw = controller.text;
                  if (pw.isNotEmpty) {
                    Navigator.pop(ctx);
                    setState(() {
                      _password = pw;
                      _needPassword = false;
                    });
                  }
                },
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final file = File(widget.path);
    if (!file.existsSync()) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: Text('File not found')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: PDFView(
        filePath: widget.path,
        password: _password,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageFling: true,
        onError: (e) {
          final errStr = e.toString().toLowerCase();
          if (errStr.contains('password') || errStr.contains('encrypted')) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted && !_needPassword) {
                setState(() => _needPassword = true);
                _showPasswordDialog();
              }
            });
          } else if (!context.mounted) {
            return;
          } else {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Error loading PDF. Please try again.')));
          }
        },
        onPageError: (page, e) {
          if (!context.mounted) return;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Error loading page. Please try again.')));
        },
      ),
    );
  }
}
