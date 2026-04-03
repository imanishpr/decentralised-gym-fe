#!/usr/bin/env bash
set -euo pipefail

if [ -z "${API_BASE_URL:-}" ]; then
  echo "API_BASE_URL is required for Vercel builds."
  echo "Set it in Vercel Project Settings -> Environment Variables."
  exit 1
fi

if ! command -v flutter >/dev/null 2>&1; then
  export PATH="$HOME/flutter/bin:$PATH"
fi

if ! command -v flutter >/dev/null 2>&1; then
  FLUTTER_VERSION="3.29.2"
  FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  curl -fsSLo "/tmp/${FLUTTER_ARCHIVE}" "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${FLUTTER_ARCHIVE}"
  tar -xf "/tmp/${FLUTTER_ARCHIVE}" -C "$HOME"
  export PATH="$HOME/flutter/bin:$PATH"
fi

git config --global --add safe.directory "$HOME/flutter"

flutter config --enable-web
flutter pub get
flutter build web --release --dart-define=API_BASE_URL="${API_BASE_URL}"
