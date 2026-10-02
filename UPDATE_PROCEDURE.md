# إجراء التشغيل القياسي لإصدار تحديثات OTA  
## تطبيق أثير (Flutter + Firebase)

## 1) نظرة عامة
يعتمد نظام التحديثات في تطبيق **أثير** على نموذج **OTA** عبر:
1. **Firebase Storage** لاستضافة ملف APK النهائي في مسار ثابت.
2. **Cloud Firestore** كمصدر حقيقة لبيانات الإصدار المتاح للأجهزة.

عند تشغيل التطبيق، تقوم الأجهزة بالتحقق من وثيقة الإعدادات في Firestore بشكل دوري (كل 24 ساعة حسب الإعداد الحالي).  
إذا كان `latestVersion` في Firestore أكبر من `buildNumber` المثبت على الجهاز، يتم تنزيل APK من Storage وبدء التثبيت تلقائياً وفق سياسة التطبيق.

---

## 2) قواعد إدارة الإصدارات (Versioning Rules)
يتم أخذ الإصدار من `pubspec.yaml` في Flutter بصيغة:

`version: versionName+buildNumber`

مثال:
`version: 1.0.0+1`

التفسير:
1. **versionName**: رقم الإصدار المعروض للمستخدم (مثل `1.0.1`).
2. **buildNumber**: رقم إصدار تقني داخلي للمقارنة المنطقية (مثل `2`).

قواعد إلزامية:
1. يجب زيادة **buildNumber** في كل إصدار جديد.
2. لا يجوز تكرار أو إنقاص **buildNumber**.
3. يمكن تغيير **versionName** وفق سياسة المنتج، لكن قرار التحديث يعتمد على **buildNumber**.

---

## 3) خطوات الإصدار (Step-by-step)

### الخطوة 1: تحديث الإصدار في `pubspec.yaml`
عدّل سطر الإصدار قبل البناء.  
مثال:

```yaml
version: 1.0.1+2
```

### الخطوة 2: بناء APK للإصدار الإنتاجي
نفّذ:

```bash
flutter build apk --release
```

الملف الناتج:
`build/app/outputs/flutter-apk/app-release.apk`

### الخطوة 3: رفع APK إلى Firebase Storage
يجب رفع الملف إلى نفس المسار الثابت دائماً:

`ota/android/atheer-release.apk`

مثال (gcloud):

```bash
gcloud storage cp build/app/outputs/flutter-apk/app-release.apk gs://perfum-5b31c.firebasestorage.app/ota/android/atheer-release.apk --project perfum-5b31c
```

### الخطوة 4: تحديث وثيقة Firestore
حدّث الوثيقة التالية:

`app_config/android`

الحقول المطلوب تحديثها في كل إصدار:
1. `latestVersion`
2. `versionName`
3. `updatedAt`

مع التأكد أن `latestVersion` يساوي **buildNumber** الحالي من `pubspec.yaml`.

---

## 4) مثال إصدار فعلي
مثال ترقية من **buildNumber = 1** إلى **buildNumber = 2**:

1. تعديل `pubspec.yaml` من:
   `version: 1.0.0+1`
   إلى:
   `version: 1.0.1+2`

2. تنفيذ البناء:
   `flutter build apk --release`

3. رفع APK الجديد إلى نفس المسار:
   `ota/android/atheer-release.apk`

4. تحديث Firestore (`app_config/android`) إلى:
   - `latestVersion: 2`
   - `versionName: "1.0.1"`
   - `updatedAt: <server timestamp>`

بعد حفظ هذه القيم، الأجهزة التي تعمل بإصدار أقل من 2 ستبدأ دورة التحديث تلقائياً حسب سياسة الفحص.

---

## 5) قواعد مهمة (Important Rules)
1. استخدم نفس ملف الهدف دائماً في Storage:  
   `ota/android/atheer-release.apk`
2. زد **buildNumber** في كل إصدار بدون استثناء.
3. لا تُنقص **buildNumber** أبداً.
4. اختبر البناء محلياً قبل النشر.
5. تحقق من نجاح رفع APK قبل تعديل Firestore.
6. نفّذ الإصدار تدريجياً عند الحاجة (Pilot rollout) قبل تعميمه على جميع الأجهزة.

---

## 6) النتيجة (Result)
بعد إكمال الخطوات السابقة بنجاح:
1. تصبح بيانات الإصدار الجديد متاحة في Firestore.
2. تكتشف أجهزة **أثير** وجود إصدار أحدث تلقائياً.
3. يتم تنزيل APK من Firebase Storage.
4. يبدأ التحديث على الأجهزة تلقائياً وفق منطق OTA في التطبيق.

النتيجة النهائية: نشر مركزي وآمن وقابل للتوسع لتحديث التطبيق على عدد كبير من الأجهزة دون إعادة إعداد المتجر أو فقدان بيانات التشغيل.
