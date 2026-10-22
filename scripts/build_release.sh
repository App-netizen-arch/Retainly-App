#!/bin/bash
set -e

bash scripts/prepare_ocr_models.sh

echo "Running flutter analyze..."
flutter analyze

echo "Running flutter test..."
flutter test

echo "Building release APK..."
flutter build apk --release

echo "Build complete. APK location:"
ls -lh build/app/outputs/flutter-apk/*.apk
