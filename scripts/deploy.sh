#!/usr/bin/env bash
set -euo pipefail

# deploy.sh - Production deployment script for Retainly
# Usage: ./scripts/deploy.sh [android|ios|functions|rules|all]

PROJECT_ID="retainly-app-b4f4a"
WORKDIR="$(cd "$(dirname "$0")/.." && pwd)"

log() {
  echo "[deploy] $*"
}

fail() {
  echo "[deploy] ERROR: $*" >&2
  exit 1
}

check_firebase_auth() {
  if ! firebase projects:list >/dev/null 2>&1; then
    fail "Firebase CLI not authenticated. Run: firebase login"
  fi
}

select_project() {
  firebase use "$PROJECT_ID" || fail "Failed to select Firebase project $PROJECT_ID"
}

deploy_rules() {
  log "Deploying Firestore and Storage rules..."
  (cd "$WORKDIR" && firebase deploy --only firestore:rules,storage:rules) || fail "Rules deployment failed"
}

deploy_functions() {
  log "Deploying Cloud Functions..."
  (cd "$WORKDIR/functions" && npm install && npm run build) || fail "Functions build failed"
  (cd "$WORKDIR" && firebase deploy --only functions) || fail "Functions deployment failed"
}

deploy_android() {
  log "Building and deploying Android App Bundle..."
  (cd "$WORKDIR" && flutter build appbundle --release) || fail "Android build failed"
  log "Android AAB ready at build/app/outputs/bundle/release/app-release.aab"
  log "Upload to Google Play Console manually or via fastlane."
}

deploy_ios() {
  log "Building iOS archive..."
  (cd "$WORKDIR" && flutter build ios --release --no-codesign) || fail "iOS build failed"
  log "iOS build ready in build/ios/iphoneos/"
  log "Open ios/Runner.xcworkspace in Xcode to archive and upload to App Store Connect."
}

deploy_all() {
  deploy_rules
  deploy_functions
  deploy_android
}

case "${1:-all}" in
  android)
    check_firebase_auth
    select_project
    deploy_android
    ;;
  ios)
    check_firebase_auth
    select_project
    deploy_ios
    ;;
  functions)
    check_firebase_auth
    select_project
    deploy_functions
    ;;
  rules)
    check_firebase_auth
    select_project
    deploy_rules
    ;;
  all)
    check_firebase_auth
    select_project
    deploy_all
    ;;
  *)
    echo "Usage: $0 [android|ios|functions|rules|all]"
    exit 1
    ;;
esac

log "Deployment step completed."
