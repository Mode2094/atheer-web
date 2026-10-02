#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-perfum-5b31c}"

if ! command -v firebase >/dev/null 2>&1; then
  echo "❌ Firebase CLI غير مثبت. ثبته عبر: npm i -g firebase-tools"
  exit 1
fi

echo "🚀 Deploying Firestore + Storage rules to ${PROJECT_ID}..."
firebase deploy --project "${PROJECT_ID}" --only "firestore:rules,storage"
echo "✅ Rules deployed successfully."
