#دليل تحديث النظام والرفع على firebase تلقائي


أولاً: الفكرة الأساسية لنظام التحديث OTA

كل تحديث يتطلب 3 أشياء فقط:

بناء APK جديد

رفع APK إلى Firebase Storage

تحديث بيانات الإصدار في Firestore

عندها كل الأجهزة ستحدث نفسها تلقائياً.

الإجراء الرسمي لإصدار تحديث جديد (Release Procedure)
الخطوة 1: تعديل رقم الإصدار

افتح الملف:

pubspec.yaml

ستجد:

version: 1.0.0+1

غيرها مثلاً إلى:

version: 1.0.1+2

المعنى:

الجزء	المعنى
1.0.1	versionName (للعرض)
+2	buildNumber (الأهم للنظام)

كل تحديث يجب زيادة buildNumber.

مثال:

version: 1.0.2+3
version: 1.0.3+4
version: 1.0.4+5
الخطوة 2: بناء APK

نفذ:

flutter build apk --release

سينتج:

build/app/outputs/flutter-apk/app-release.apk
الخطوة 3: إعادة تسمية الملف

أعد تسميته إلى:

atheer-release.apk

(نفس الاسم دائماً)

السبب: النظام يستخدم نفس الرابط.

الخطوة 4: رفع APK إلى Firebase Storage

اذهب إلى:

Firebase Console → Storage

المسار:

ota/android/

استبدل الملف:

atheer-release.apk

مهم: قم بعمل Replace وليس ملف جديد باسم مختلف.

الخطوة 5: تحديث Firestore

اذهب إلى:

Firestore → collection:

app_config

document:

android

غير:

latestVersion: 2
versionName: "1.0.1"

مثال للتحديث الثالث:

latestVersion: 3
versionName: "1.0.2"
ماذا يحدث تلقائياً بعد ذلك

كل جهاز سيقوم بـ:

قراءة latestVersion
↓
مقارنتها مع نسخته الحالية
↓
إذا وجد إصدار أحدث
↓
تحميل APK
↓
تحديث نفسه تلقائياً

بدون أي تدخل منك.

مثال كامل عملي

الإصدار الحالي:

version: 1.0.0+1

نريد إصدار جديد:

1. تعديل pubspec.yaml
version: 1.0.1+2
2. بناء APK
flutter build apk --release
3. رفع

استبدل:

ota/android/atheer-release.apk
4. تعديل Firestore
latestVersion: 2
versionName: "1.0.1"

انتهى.