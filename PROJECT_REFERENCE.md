# مرجع المشروع التقني الشامل

هذا المستند هو المرجع الرسمي لتطبيق **أثير** (Neuro-Scent Advisor)، ويغطي المعمارية، التدفقات، طبقات النظام، تكامل Firebase، نظام OTA، ووصفًا منظّمًا لكامل ملفات المشروع التطبيقية.

## 1) الملخص التنفيذي

المشروع عبارة عن منصة توصية عطور ذكية مبنية بـ Flutter + Firebase، وتدعم:

1. تجربة مستخدم نهائي (إدخال هاتف -> ملف شخصي -> أسئلة -> توصيات).
2. لوحة متجر لإدارة عطور متجر واحد.
3. لوحة مدير لإدارة النظام والتقارير والمستخدمين.
4. نظام تحديث OTA لأجهزة الكشك (Android) مع الحفاظ على إعدادات الجهاز.
5. بنية EEG حالية (جمع/عرض/تخزين) جاهزة للتطوير نحو تكامل فعلي مع Emotiv.

## 2) البداية وتهيئة النظام (Bootstrap)

1. `lib/main.dart`
   - تهيئة Flutter bindings.
   - تهيئة SharedPreferences helper.
   - تهيئة Firebase.
   - تهيئة Controller التحديثات.
   - تشغيل app مع مزودي الحالة (Providers).
   - بدء فحص/تدفق التحديثات التلقائي بالخلفية.

2. `lib/app.dart`
   - إعداد `MaterialApp`.
   - تفعيل RTL/العربية.
   - تعريف المسارات (routes).
   - ربط Controllers بالشاشات الأساسية.

3. `lib/features/init/init_screen.dart`
   - يحدد مسار البداية: إعداد أولي أو Splash أو المسار التشغيلي.

## 3) المعمارية التقنية

المشروع يتبع فصلًا واضحًا للمسؤوليات:

1. **Core Layer**
   - Constants, Services, Utilities, Theme.
2. **Features Layer**
   - كل نطاق أعمال ضمن وحدة مستقلة (Auth/Admin/Store/Recommendation/Update/EEG...).
3. **Shared Layer**
   - نماذج موحّدة + Widgets مشتركة.
4. **State Management**
   - `Provider` + `ChangeNotifier`.
5. **Serialization**
   - `freezed` و `json_serializable` عبر ملفات `*.freezed.dart` و `*.g.dart`.

## 4) أدوار المستخدمين

1. **Customer**
   - دخول سريع.
   - أسئلة نفسية/حسية.
   - توصية عطر مع أسباب.

2. **Store User**
   - دخول بحساب متجر.
   - إدارة عطور متجره فقط (CRUD).

3. **Admin**
   - إدارة متاجر، مستخدمي متاجر، عطور، تقارير، Telemetry، EEG، OTA.

## 5) تدفق المستخدم النهائي (Customer Flow)

1. شاشة البداية.
2. إدخال الهاتف.
3. إن كان مستخدمًا جديدًا: إدخال الاسم والجنس.
4. حل الاستبيان (15 أسئلة).
5. حساب ملف الشخصية.
6. الحصول على أفضل 3 توصيات.

## 6) محرك التوصية (Recommendation Engine)

1. الخدمة الأساسية: `lib/features/recommendation/recommendation_service.dart`.
2. النمط: **Hybrid**.
   - محاولة Cloud Function أولًا.
   - عند الفشل/المهلة: fallback محلي.
3. يعتمد على:
   - توافق السمات النفسية.
   - تفضيلات الحسية (freshness/sweetness/warmth/intensity).
   - العائلة العطرية.
   - التوافق مع الجنس المستهدف.
4. المخرجات:
   - درجات ترتيب.
   - أسباب ترشيح.
   - دعم حقل `wasEegUsed`.

## 7) نظام OTA (التحديث عن بعد)

### 7.1 مسارات التحديث
1. **مسار لوحة الأدمن** (`features/update`)
   - رفع APK إلى Firebase Storage.
   - تحديث وثيقة الإصدار في Firestore.
2. **مسار جهاز الكشك** (`core/services/update_service.dart` + `features/updater`)
   - فحص دوري كل 24 ساعة.
   - مقارنة الإصدار.
   - تحميل APK.
   - بدء التثبيت.

### 7.2 حماية بيانات الإعداد
قبل التثبيت، يتم الحفاظ على البيانات المحلية المهمة مثل:

1. `storeId`
2. حالة اكتمال الإعداد
3. معلومات الجلسة المهمة
4. وقت آخر فحص للتحديث

### 7.3 ملاحظات تشغيلية
1. التحقق ليس عند كل تشغيل، بل دوري لتخفيف الحمل.
2. يوجد retry/backoff للتعامل مع انقطاع الشبكة.
3. يجب ضبط قواعد Firestore/Storage للإنتاج قبل الإطلاق.

## 8) EEG في النظام الحالي

1. ملفات EEG تحت: `lib/features/eeg/`.
2. المتاح حاليًا:
   - نماذج مقاييس EEG.
   - خدمة حفظ/قراءة النتائج.
   - واجهات عرض/محاكاة وقياسات.
   - شاشات إحصائية للإدارة.
3. الهدف التالي:
   - الربط الحي مع Emotiv Cortex API.
   - دمج Interest/Stress/Excitement في درجة التوصية.

## 9) طبقة البيانات في Firebase

المجموعات الرئيسية:

1. `users`
2. `stores`
3. `stores/{storeId}/perfumes`
4. `store_users`
5. `admin_users`
6. `recommendations`
7. `eeg_results`
8. `eeg_stats`
9. `app_config`
10. `app_updates`

Cloud Functions الفعالة:

1. `getRecommendationV2` (Callable)
2. `updateEEGStats` (Scheduled)

## 10) فهرس ملفات `lib` الكامل (دون استثناء)

إجمالي الملفات داخل `lib`: **138 ملفًا**

### 10.1 ملفات التشغيل والدخول
1. `lib/main.dart`
2. `lib/app.dart`
3. `lib/firebase_options.dart`

### 10.2 `lib/core/constants`
1. `lib/core/constants/app_constants.dart`
2. `lib/core/constants/device_config.dart`
3. `lib/core/constants/perfume_constants.dart`
4. `lib/core/constants/theme_constants.dart`

### 10.3 `lib/core/models`
1. `lib/core/models/admin_user_model.dart`
2. `lib/core/models/admin_user_model.freezed.dart`
3. `lib/core/models/admin_user_model.g.dart`
4. `lib/core/models/app_config_model.dart`
5. `lib/core/models/app_version_model.dart`
6. `lib/core/models/eeg_result_model.dart`
7. `lib/core/models/eeg_result_model.freezed.dart`
8. `lib/core/models/eeg_result_model.g.dart`
9. `lib/core/models/store_user_model.dart`
10. `lib/core/models/store_user_model.freezed.dart`
11. `lib/core/models/store_user_model.g.dart`

### 10.4 `lib/core/services`
1. `lib/core/services/firebase_service.dart`
2. `lib/core/services/setup_service.dart`
3. `lib/core/services/telemetry_service.dart`
4. `lib/core/services/update_service.dart`

### 10.5 `lib/core/theme`
1. `lib/core/theme/app_theme.dart`

### 10.6 `lib/core/utils`
1. `lib/core/utils/helpers.dart`
2. `lib/core/utils/logger.dart`
3. `lib/core/utils/prefs_helper.dart`
4. `lib/core/utils/string_helper.dart`
5. `lib/core/utils/validators.dart`

### 10.7 `lib/features/admin`
1. `lib/features/admin/admin_controller.dart`
2. `lib/features/admin/admin_screen.dart`

#### `lib/features/admin/widgets`
1. `lib/features/admin/widgets/perfume_card.dart`
2. `lib/features/admin/widgets/perfume_list.dart`
3. `lib/features/admin/widgets/store_actions.dart`
4. `lib/features/admin/widgets/store_card.dart`

#### `lib/features/admin/screens`
1. `lib/features/admin/screens/add_perfume_screen.dart`
2. `lib/features/admin/screens/add_store_screen.dart`
3. `lib/features/admin/screens/create_store_user_screen.dart`
4. `lib/features/admin/screens/edit_perfume_screen.dart`
5. `lib/features/admin/screens/eeg_stats_screen.dart`
6. `lib/features/admin/screens/manage_store_screen.dart`
7. `lib/features/admin/screens/perfume_management_screen.dart`
8. `lib/features/admin/screens/store_users_screen.dart`
9. `lib/features/admin/screens/telemetry_dashboard.dart`

#### `lib/features/admin/users`
1. `lib/features/admin/users/users_controller.dart`
2. `lib/features/admin/users/users_list_screen.dart`
3. `lib/features/admin/users/users_service.dart`
4. `lib/features/admin/users/widgets/user_card.dart`
5. `lib/features/admin/users/widgets/user_details_screen.dart`

#### `lib/features/admin/reports`
1. `lib/features/admin/reports/reports_controller.dart`
2. `lib/features/admin/reports/reports_screen.dart`
3. `lib/features/admin/reports/reports_service.dart`
4. `lib/features/admin/reports/advanced_reports_controller.dart`
5. `lib/features/admin/reports/advanced_reports_screen.dart`
6. `lib/features/admin/reports/advanced_reports_service.dart`
7. `lib/features/admin/reports/models/user_report_model.dart`
8. `lib/features/admin/reports/screens/user_details_screen.dart`
9. `lib/features/admin/reports/services/reports_data_service.dart`
10. `lib/features/admin/reports/widgets/distribution_charts.dart`
11. `lib/features/admin/reports/widgets/filter_section.dart`
12. `lib/features/admin/reports/widgets/stats_cards.dart`
13. `lib/features/admin/reports/widgets/users_list.dart`

### 10.8 `lib/features/admin_auth`
1. `lib/features/admin_auth/admin_auth_controller.dart`
2. `lib/features/admin_auth/admin_auth_service.dart`
3. `lib/features/admin_auth/admin_login_screen.dart`

### 10.9 `lib/features/auth`
1. `lib/features/auth/auth_controller.dart`
2. `lib/features/auth/auth_service.dart`
3. `lib/features/auth/otp_verification_screen.dart`
4. `lib/features/auth/profile_input_screen.dart`

### 10.10 `lib/features/eeg`
1. `lib/features/eeg/eeg_controller.dart`
2. `lib/features/eeg/eeg_metrics.dart`
3. `lib/features/eeg/eeg_service.dart`
4. `lib/features/eeg/eeg_visualization_screen.dart`
5. `lib/features/eeg/widgets/perfume_test_card.dart`

### 10.11 `lib/features/init`
1. `lib/features/init/init_screen.dart`

### 10.12 `lib/features/questionnaire`
1. `lib/features/questionnaire/question_screen.dart`
2. `lib/features/questionnaire/questionnaire_controller.dart`
3. `lib/features/questionnaire/questionnaire_service.dart`
4. `lib/features/questionnaire/data/questions_data.dart`
5. `lib/features/questionnaire/models/answer_model.dart`
6. `lib/features/questionnaire/models/answer_model.freezed.dart`
7. `lib/features/questionnaire/models/answer_model.g.dart`
8. `lib/features/questionnaire/models/question_model.dart`
9. `lib/features/questionnaire/models/question_model.freezed.dart`
10. `lib/features/questionnaire/models/question_model.g.dart`

### 10.13 `lib/features/recommendation`
1. `lib/features/recommendation/recommendation_controller.dart`
2. `lib/features/recommendation/recommendation_screen.dart`
3. `lib/features/recommendation/recommendation_service.dart`
4. `lib/features/recommendation/widgets/eeg_test_card.dart`

### 10.14 `lib/features/setup`
1. `lib/features/setup/setup_screen.dart`

### 10.15 `lib/features/shared`
1. `lib/features/shared/services/session_service.dart`
2. `lib/features/shared/widgets/excel_upload_button.dart`
3. `lib/features/shared/widgets/inactivity_detector.dart`
4. `lib/features/shared/widgets/new_customer_button.dart`
5. `lib/features/shared/excel/excel_service.dart`
6. `lib/features/shared/excel/file_download_stub.dart`
7. `lib/features/shared/excel/file_download_web.dart`

### 10.16 `lib/features/splash`
1. `lib/features/splash/splash_screen.dart`

### 10.17 `lib/features/store_auth`
1. `lib/features/store_auth/store_auth_controller.dart`
2. `lib/features/store_auth/store_auth_service.dart`
3. `lib/features/store_auth/store_login_screen.dart`

### 10.18 `lib/features/store_dashboard`
1. `lib/features/store_dashboard/store_dashboard_controller.dart`
2. `lib/features/store_dashboard/store_dashboard_screen.dart`
3. `lib/features/store_dashboard/widgets/perfume_grid.dart`
4. `lib/features/store_dashboard/widgets/store_info_card.dart`
5. `lib/features/store_dashboard/screens/add_perfume_screen.dart`
6. `lib/features/store_dashboard/screens/edit_perfume_screen.dart`
7. `lib/features/store_dashboard/screens/edit_store_screen.dart`

### 10.19 `lib/features/stores`
1. `lib/features/stores/store_binding_screen.dart`
2. `lib/features/stores/store_cache_service.dart`
3. `lib/features/stores/store_controller.dart`
4. `lib/features/stores/store_service.dart`

### 10.20 `lib/features/update`
1. `lib/features/update/update_checker.dart`
2. `lib/features/update/update_controller.dart`
3. `lib/features/update/update_screen.dart`
4. `lib/features/update/update_service.dart`

### 10.21 `lib/features/updater`
1. `lib/features/updater/updater_controller.dart`
2. `lib/features/updater/widgets/update_progress_dialog.dart`

### 10.22 `lib/shared/models`
1. `lib/shared/models/perfume_model.dart`
2. `lib/shared/models/perfume_model.freezed.dart`
3. `lib/shared/models/perfume_model.g.dart`
4. `lib/shared/models/personality_profile_model.dart`
5. `lib/shared/models/personality_profile_model.freezed.dart`
6. `lib/shared/models/personality_profile_model.g.dart`
7. `lib/shared/models/recommendation_model.dart`
8. `lib/shared/models/recommendation_model.freezed.dart`
9. `lib/shared/models/recommendation_model.g.dart`
10. `lib/shared/models/store_model.dart`
11. `lib/shared/models/store_model.freezed.dart`
12. `lib/shared/models/store_model.g.dart`
13. `lib/shared/models/user_model.dart`
14. `lib/shared/models/user_model.freezed.dart`
15. `lib/shared/models/user_model.g.dart`

### 10.23 `lib/shared/widgets`
1. `lib/shared/widgets/animated_background.dart`
2. `lib/shared/widgets/animated_button.dart`
3. `lib/shared/widgets/animated_input.dart`
4. `lib/shared/widgets/glass_container.dart`
5. `lib/shared/widgets/glowing_button.dart`
6. `lib/shared/widgets/gradient_background.dart`

## 11) ملفات الجذر المرجعية المهمة

1. `pubspec.yaml` - تعريف الحزم والخطوط والأصول.
2. `pubspec.lock` - نسخ الحزم المقفلة.
3. `firebase.json` - ضبط نشر Firebase.
4. `firestore.rules` - سياسات Firestore.
5. `firestore.indexes.json` - مؤشرات Firestore.
6. `storage.rules` - سياسات Storage.
7. `functions/index.js` - منطق Cloud Functions.
8. `functions/package.json` - تبعيات Functions.
9. `scripts/setup-firebase.sh` - إعداد Firebase الأولي.
10. `scripts/release.sh` - سكربت الإصدار.
11. `scripts/deploy-rules.sh` - نشر القواعد.
12. `REMOTE_UPDATE_GUIDE.md` - دليل OTA.
13. `UPDATE_PROCEDURE.md` - SOP للإصدار.
14. `README.md` - وصف عام للمشروع.
15. `analysis_options.yaml` - قواعد التحليل.
16. `devtools_options.yaml` - إعدادات DevTools.

## 12) ملاحظات تشغيل وإنتاج

1. عند الإنتاج، لا تترك قواعد Firestore/Storage مفتوحة.
2. وحّد مصدر حقيقة الإصدار بين `app_config/android` و`app_updates/latest` لتجنب تضارب.
3. راقب مقاييس Telemetry لضبط performance/fallback.
4. ثبّت إجراء إصدار موحد عبر سكربتات `scripts/`.

## 13) الحالة الحالية والتوسعة

1. المنصة جاهزة تشغيليًا لتجربة توصية كاملة.
2. OTA مهيكل وقابل للتوسع لأعداد أجهزة كبيرة.
3. EEG مدمج كبنية بيانات وتجربة UI، وجاهز للانتقال إلى التكامل الحقيقي (Cortex API) في خطوة تالية.

## 14) ملخص التقييم الهندسي

| المحور | التقييم | التفاصيل |
|---|---|---|
| المعمارية العامة     | ⭐⭐⭐⭐⭐ | Feature-based، نظيفة، قابلة للتوسع |
| نماذج البيانات       | ⭐⭐⭐⭐⭐ | Freezed + JsonSerializable، جاهزة لـ `eeg_results` |
| محرك التوصية         | ⭐⭐⭐⭐⭐ | مرن وقابل لحقن درجات إضافية |
| طبقة EEG الحالية     | ⭐⭐⭐⭐ | `EEGController`، `EEGService`، `EEGResultModel` موجودة |
| إدارة الحالة         | ⭐⭐⭐⭐⭐ | `Provider` منظم بشكل ممتاز |
| التخزين               | ⭐⭐⭐⭐⭐ | Firestore مهيكل مع `eeg_results` و `eeg_stats` |
| الأمان                 | ⭐⭐⭐⭐⭐ |   (إدارة token عبر Cloud Functions) |
| التوثيق               | ⭐⭐⭐⭐ | موجود ويحتاج توسيعًا أكثر لمسارات EEG |
| جاهزية التكامل        | ⭐⭐⭐⭐⭐ | جاهز للتنفيذ الفوري |

## 15) توافق Emotiv Epoc X مع المشروع

جهاز **Emotiv Epoc X** مناسب جدًا لهذا المشروع للأسباب التالية:

| الميزة | Epoc X | استخدامها داخل المشروع |
|---|---|---|
| 14 قناة EEG         | ✅ | رفع دقة القراءة وتحسين التحليل |
| Interest (الاهتمام)  | ✅ | أهم مؤشر لتفضيل العطر |
| Excitement (الإثارة) | ✅ | قياس التفاعل الإيجابي مع العطر |
| Stress (التوتر) | ✅ | اكتشاف النفور أو عدم الراحة |
| Relaxation (الاسترخاء) | ✅ | قياس الراحة أثناء التجربة |
| Engagement (الانخراط) | ✅ | تقييم جودة التجربة الكلية |
| Cortex API | ✅ | متوافق مع WebSocket ويمكن ربطه مع Flutter |
| 20,000+ دراسة | ✅ | موثوقية علمية عالية في الاستخدام |