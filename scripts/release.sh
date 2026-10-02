#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-perfum-5b31c}"
BUCKET="${BUCKET:-${PROJECT_ID}.firebasestorage.app}"
APK_NAME="${APK_NAME:-atheer-release.apk}"
APK_STORAGE_PATH="ota/android/${APK_NAME}"
APK_PUBLIC_URL="https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/ota%2Fandroid%2F${APK_NAME}?alt=media"
FIRESTORE_DOC_URL="https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/app_config/android"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "❌ Missing command: $1"
    exit 1
  fi
}

require_cmd flutter
require_cmd gcloud
require_cmd curl
require_cmd python3

echo "🧱 Building Android APK (release)..."
flutter build apk --release

SOURCE_APK="build/app/outputs/flutter-apk/app-release.apk"
if [[ ! -f "${SOURCE_APK}" ]]; then
  echo "❌ APK not found at ${SOURCE_APK}"
  exit 1
fi

echo "☁️ Uploading APK to Firebase Storage..."
gcloud storage cp "${SOURCE_APK}" "gs://${BUCKET}/${APK_STORAGE_PATH}" --project "${PROJECT_ID}"

VERSION_NAME="$(python3 - <<'PY'
import re,sys
content=open('pubspec.yaml','r',encoding='utf-8').read()
m=re.search(r'^version:\s*([^\+]+)\+(\d+)', content, re.M)
if not m:
    sys.exit(1)
print(m.group(1))
PY
)"
BUILD_NUMBER="$(python3 - <<'PY'
import re,sys
content=open('pubspec.yaml','r',encoding='utf-8').read()
m=re.search(r'^version:\s*([^\+]+)\+(\d+)', content, re.M)
if not m:
    sys.exit(1)
print(m.group(2))
PY
)"

echo "📝 Updating Firestore app_config/android with buildNumber=${BUILD_NUMBER}, version=${VERSION_NAME}"
ACCESS_TOKEN="$(gcloud auth application-default print-access-token)"
NOW_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

read -r -d '' PAYLOAD <<EOF || true
{
  "fields": {
    "latestVersion": { "integerValue": "${BUILD_NUMBER}" },
    "versionName": { "stringValue": "${VERSION_NAME}" },
    "apkUrl": { "stringValue": "${APK_PUBLIC_URL}" },
    "apkStoragePath": { "stringValue": "${APK_STORAGE_PATH}" },
    "mandatory": { "booleanValue": false },
    "enabled": { "booleanValue": true },
    "releaseNotes": { "stringValue": "Release ${VERSION_NAME}" },
    "updatedAt": { "timestampValue": "${NOW_UTC}" }
  }
}
EOF

curl -sS -X PATCH "${FIRESTORE_DOC_URL}" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "${PAYLOAD}" >/dev/null

echo "✅ Release pipeline completed."
echo "   APK: gs://${BUCKET}/${APK_STORAGE_PATH}"
echo "   URL: ${APK_PUBLIC_URL}"
