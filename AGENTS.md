# AGENTS.md — CalculFF Client Engineering Rules

## الهوية ومصدر الحقيقة

- هذا المستودع يبني تطبيق الزبائن **CalculFF Client** باستخدام Flutter وDart.
- معرّف Android المحمي: `com.gm0h1.calculffclient`.
- مستودع `mohamed09090-xmd/calculff` وفرعه `main` هما مصدر الحقيقة لعقود Supabase والجداول وRLS وRPCs.
- migrations وRLS وRPCs تدار حاليًا من المستودع الإداري فقط. يمنع إنشاؤها أو تعديلها من هذا المستودع.

## المعمارية

- استخدم Feature-first architecture.
- لا تضع منطق Auth أو Supabase أو قواعد المجال داخل Widgets.
- عقود المستودعات في `domain` أو `application`، والتنفيذ في `infrastructure`.
- استخدم Riverpod للاعتماديات والحالة و`go_router` للتوجيه المحمي.
- عدّل أقل عدد ممكن من الملفات ولا تضف dependency دون حاجة مثبتة.

## Auth والأمان

- لا تخزن كلمة المرور أو access token أو refresh token أو reset URL في logs أو تخزين نصي.
- جلسة Supabase تستخدم `flutter_secure_storage` فقط.
- يمنع `service_role` و`sb_secret` وأي مفتاح إداري داخل التطبيق أو CI أو الوثائق.
- إعدادات Supabase تمر عبر `String.fromEnvironment` ولا تحفظ قيم حقيقية في Git.
- لا تعرض أخطاء Supabase أو PostgreSQL الخام للمستخدم.
- Logout يجب أن يمسح الجلسة المحلية والبيانات الحساسة في الذاكرة ويمنع بقاء مسار محمي.

## اللغات والوصول

- العربية هي الافتراضية وتعمل RTL، والفرنسية LTR.
- كل النصوص داخل ARB ولا توضع نصوص واجهة مباشرة داخل Widgets باستثناء الاسم التجاري الثابت.
- اختبر الشاشات الصغيرة، تكبير الخط، لوحة المفاتيح، SafeArea، وSemantics.
- لا تعتمد على اللون وحده لشرح الحالة.

## الفروع والاختبارات

- استخدم فرعًا مستقلًا وDraft PR لكل مهمة.
- شغّل: `dart format --output=none --set-exit-if-changed .`، `flutter analyze`، و`flutter test --coverage`.
- يبني CI Debug APK فقط في هذه المرحلة، ولا يمثل توقيعًا أو إصدارًا إنتاجيًا.
- راجع diff وفحص الأسرار قبل كل commit وقبل الدمج.

## الدمج التلقائي

يمكن دمج PR تلقائيًا بــmerge commit فقط بعد نجاح التنسيق والتحليل والاختبارات وCI وبناء Debug APK، وبعد مراجعة diff والتأكد من غياب الأسرار والتغييرات الخارجة عن النطاق.

يجب إبقاء PR كـDraft وعدم الدمج عند الحاجة إلى migration أو RLS أو RPC جديد، تعديل Hosted Supabase، تغيير Application ID، إضافة خدمة خارجية، توقيع إنتاجي، GitHub Release، أو نشر Google Play.
