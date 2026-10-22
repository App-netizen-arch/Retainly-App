import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdfx/pdfx.dart';
import 'package:read_pdf_text/read_pdf_text.dart';
import 'package:tesseract_ocr/ocr_engine_config.dart';
import 'package:tesseract_ocr/tesseract_ocr.dart';

class OcrPageResult {
  const OcrPageResult({
    required this.pageNumber,
    required this.text,
    this.extractionMethod = 'tesseract_ocr',
  });

  final int pageNumber;
  final String text;
  final String extractionMethod;
}

class OcrDocumentResult {
  const OcrDocumentResult({
    required this.pages,
    required this.totalPages,
    required this.truncated,
  });

  final List<OcrPageResult> pages;
  final int totalPages;
  final bool truncated;

  String get fullText => pages
      .where((page) => page.text.trim().isNotEmpty)
      .map((page) => '--- Page ${page.pageNumber} ---\n${page.text.trim()}')
      .join('\n\n');
}

/// Offline OCR adapter. Tesseract model files are bundled into release builds
/// by scripts/prepare_ocr_models.sh; no document content is uploaded.
class LocalOcrService {
  static const int defaultMaxPdfPages = 250;

  static const Map<String, String> languageOptions = {
    'English': 'eng',
    'Urdu + Punjabi Shahmukhi (experimental) + English': 'eng+urd',
    'Arabic + English': 'eng+ara',
    'Punjabi Gurmukhi + English': 'eng+pan',
  };

  Future<String> extractImageText(
    String imagePath, {
    String language = 'eng+urd',
  }) async {
    if (!await File(imagePath).exists()) {
      throw const FileSystemException('The selected image could not be found.');
    }
    _ensureSupportedPlatform();
    _validateLanguage(language);
    final text = await TesseractOcr.extractText(
      imagePath,
      config: OCRConfig(
        language: language,
        engine: OCREngine.tesseract,
        options: const {'preserve_interword_spaces': '1'},
      ),
    );
    return text.trim();
  }

  Future<OcrDocumentResult> extractPdfText(
    String pdfPath, {
    String language = 'eng+urd',
    int maxPages = defaultMaxPdfPages,
    void Function(int currentPage, int totalPages)? onProgress,
  }) async {
    if (!await File(pdfPath).exists()) {
      throw const FileSystemException('The selected PDF could not be found.');
    }
    _ensureSupportedPlatform();
    _validateLanguage(language);

    // Prefer the PDF's native text layer; only render/OCR pages where no text
    // was extractable. Scanned PDFs generally return empty page strings here.
    var nativeTextPages = <String>[];
    try {
      nativeTextPages = await ReadPdfText.getPDFtextPaginated(pdfPath);
    } catch (_) {
      // Encrypted, malformed or unsupported PDFs fall back to local OCR.
    }

    final document = await PdfDocument.openFile(pdfPath);
    final pageResults = <OcrPageResult>[];
    final totalPages = document.pagesCount;
    final pagesToProcess = totalPages < maxPages ? totalPages : maxPages;
    final tempDir = await getTemporaryDirectory();

    try {
      for (var pageNumber = 1; pageNumber <= pagesToProcess; pageNumber++) {
        onProgress?.call(pageNumber, totalPages);
        final nativeText = pageNumber <= nativeTextPages.length
            ? nativeTextPages[pageNumber - 1].trim()
            : '';
        if (nativeText.isNotEmpty) {
          pageResults.add(OcrPageResult(
            pageNumber: pageNumber,
            text: nativeText,
            extractionMethod: 'pdf_text',
          ));
          continue;
        }

        final page = await document.getPage(pageNumber);
        final tempImagePath = p.join(
          tempDir.path,
          'retainly_ocr_${DateTime.now().microsecondsSinceEpoch}_$pageNumber.png',
        );
        try {
          final rendered = await page.render(
            width: page.width * 2,
            height: page.height * 2,
            format: PdfPageImageFormat.png,
            backgroundColor: '#ffffff',
          );
          if (rendered == null) {
            pageResults.add(OcrPageResult(
              pageNumber: pageNumber,
              text: '',
            ));
            continue;
          }
          final imageFile = File(tempImagePath);
          await imageFile.writeAsBytes(rendered.bytes, flush: true);
          final text = await TesseractOcr.extractText(
            imageFile.path,
            config: OCRConfig(
              language: language,
              engine: OCREngine.tesseract,
              options: const {'preserve_interword_spaces': '1'},
            ),
          );
          pageResults.add(OcrPageResult(
            pageNumber: pageNumber,
            text: text.trim(),
          ));
        } finally {
          try {
            final renderedFile = File(tempImagePath);
            if (await renderedFile.exists()) await renderedFile.delete();
          } catch (_) {
            // Temporary-file cleanup must not mask the OCR result/error.
          }
          await page.close();
        }
      }
    } finally {
      await document.close();
    }

    return OcrDocumentResult(
      pages: pageResults,
      totalPages: totalPages,
      truncated: totalPages > pagesToProcess,
    );
  }

  void _ensureSupportedPlatform() {
    if (!Platform.isAndroid && !Platform.isIOS) {
      throw UnsupportedError(
        'Local OCR is currently supported on Android and iOS builds only.',
      );
    }
  }

  void _validateLanguage(String language) {
    const supported = {'eng', 'eng+urd', 'eng+ara', 'eng+pan', 'urd', 'ara', 'pan'};
    if (!supported.contains(language)) {
      throw ArgumentError.value(language, 'language', 'Unsupported OCR language combination.');
    }
  }
}
