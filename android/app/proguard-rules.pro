# pdfx / PDFBox Android references an optional JPEG2000 decoder that is not
# packaged with the app. JPEG2000 streams are unsupported without that optional
# library; silence R8's missing-class diagnostic for this optional code path.
-dontwarn com.gemalto.jp2.JP2Decoder
