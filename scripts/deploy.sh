#!/usr/bin/env bash
set -euo pipefail

# deploy.sh - Production deployment script for Retainly
# Usage: ./scripts/deploy.sh [android|all]

WORKDIR="$(cd "$(dirname "$0")/.." && pwd)"

log() {
  echo "[deploy] $*"
}

fail() {
  echo "[deploy] ERROR: $*" >&2
  exit 1
}

deploy_android() {
  log "Building and deploying Android App Bundle..."
  (cd "$WORKDIR" && flutter build appbundle --release) || fail "Android build failed"
  log "Android AAB ready at build/app/outputs/bundle/release/app-release.aab"
  log "Upload to Google Play Console manually or via fastlane."
}

deploy_all() {
  deploy_android
}

case "${1:-all}" in
  android)
    deploy_android
    ;;
  all)
    deploy_all
    ;;
  *)
    echo "Usage: $0 [android|all]"
    exit 1
    ;;
esac

log "Deployment step completed."
