#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-perfum-5b31c}"
BUCKET="${BUCKET:-${PROJECT_ID}.firebasestorage.app}"
APP_CONFIG_DOC="app_config/android"
APK_STORAGE_PATH="ota/android/atheer-release.apk"
APK_PUBLIC_URL="https://firebasestorage.googleapis.com/v0/b/${BUCKET}/o/ota%2Fandroid%2Fatheer-release.apk?alt=media"

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "❌ Missing command: $1"
    exit 1
  fi
}

require_cmd firebase
require_cmd gcloud
require_cmd curl

echo "🔐 Checking authentication..."
firebase projects:list >/dev/null
gcloud auth application-default print-access-token >/dev/null

echo "🚀 Deploying rules..."
bash scripts/deploy-rules.sh

echo "📁 Creating OTA folder structure in Storage (via placeholder object)..."
TMP_KEEP_FILE="$(mktemp)"
echo "atheer-ota-placeholder" > "${TMP_KEEP_FILE}"
gcloud storage cp "${TMP_KEEP_FILE}" "gs://${BUCKET}/ota/android/.keep" --project "${PROJECT_ID}"
rm -f "${TMP_KEEP_FILE}"

echo "📝 Creating Firestore document ${APP_CONFIG_DOC}..."
ACCESS_TOKEN="$(gcloud auth application-default print-access-token)"
NOW_UTC="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
FIRESTORE_URL="https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/${APP_CONFIG_DOC}"

read -r -d '' PAYLOAD <<EOF || true
{
  "fields": {
    "latestVersion": { "integerValue": "1" },
    "versionName": { "stringValue": "1.0.0" },
    "apkUrl": { "stringValue": "${APK_PUBLIC_URL}" },
    "apkStoragePath": { "stringValue": "${APK_STORAGE_PATH}" },
    "mandatory": { "booleanValue": false },
    "enabled": { "booleanValue": true },
    "releaseNotes": { "stringValue": "الإصدار الأول من تطبيق أثير" },
    "createdAt": { "timestampValue": "${NOW_UTC}" },
    "updatedAt": { "timestampValue": "${NOW_UTC}" }
  }
}
EOF

curl -sS -X PATCH "${FIRESTORE_URL}" \
  -H "Authorization: Bearer ${ACCESS_TOKEN}" \
  -H "Content-Type: application/json" \
  -d "${PAYLOAD}" >/dev/null

echo "✅ Firebase OTA setup completed for project: ${PROJECT_ID}"
echo "   Firestore doc: ${APP_CONFIG_DOC}"
echo "   Storage path : gs://${BUCKET}/${APK_STORAGE_PATH}"
echo "   APK URL      : ${APK_PUBLIC_URL}"
