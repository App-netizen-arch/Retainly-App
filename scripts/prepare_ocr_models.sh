#!/usr/bin/env bash
set -euo pipefail

# Pinned official Tesseract fast-model release. The downloaded traineddata is
# embedded into the app build, so OCR itself works offline after installation.
readonly MODEL_RELEASE="4.1.0"
readonly MODEL_BASE_URL="https://raw.githubusercontent.com/tesseract-ocr/tessdata_fast/${MODEL_RELEASE}"
readonly DEST_DIR="assets/tessdata"
readonly LANGUAGES=("eng" "urd" "ara" "pan")

if ! command -v curl >/dev/null 2>&1; then
  echo "Error: curl is required to prepare bundled OCR models." >&2
  exit 1
fi

mkdir -p "${DEST_DIR}"
for language in "${LANGUAGES[@]}"; do
  destination="${DEST_DIR}/${language}.traineddata"
  if [[ -s "${destination}" ]]; then
    echo "Keeping existing ${destination}"
    continue
  fi

  echo "Downloading official Tesseract ${language} model (${MODEL_RELEASE})..."
  curl --fail --location --retry 3 --retry-all-errors \
    --connect-timeout 20 --max-time 300 \
    "${MODEL_BASE_URL}/${language}.traineddata" \
    --output "${destination}.part"
  test -s "${destination}.part"
  mv "${destination}.part" "${destination}"
done

echo "Bundled OCR models prepared:"
du -h "${DEST_DIR}"/*.traineddata
