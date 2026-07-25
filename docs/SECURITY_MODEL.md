# Security model

- publishable key وproject URL يعاملان كإعدادات بناء عامة، لكن لا يحفظان في المستودع وفق سياسة المشروع.
- الأسرار الإدارية و`service_role` و`sb_secret` محظورة داخل Flutter.
- جلسة Supabase تحفظ عبر `flutter_secure_storage`، مع رفض payload يحتوي حقل password.
- Android backup معطل للتطبيق، ولا توجد logs للتوكنات أو reset links.
- أخطاء Auth تحول إلى فئات آمنة ومترجمة.
- RLS في مستودع `calculff` هو الحاجز الأساسي للبيانات؛ التطبيق لا يتجاوز العقود ولا ينشئ direct writes غير ممنوحة.
- Logout يمسح الجلسة والملف من الذاكرة والبيانات المؤقتة.
- CI يستخدم fakes فقط ولا يتصل بالـBackend الحقيقي.
