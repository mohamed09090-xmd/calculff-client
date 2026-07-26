# CalculFF Client

تطبيق Android مخصص لزبائن منصة CalculFF، منفصل عن تطبيق الإدارة المحلي.

## الحالة الحالية

النسخة الحالية تنفذ Foundation + Authentication + Customer Catalog:

- Bootstrap آمن مع حالة واضحة عند غياب إعداد Supabase.
- تسجيل الدخول وإنشاء الحساب وتأكيد البريد.
- طلب استرجاع كلمة المرور والتعامل مع deep link لإعادة التعيين.
- جلسة Supabase محفوظة في `flutter_secure_storage`.
- ملف شخصي يقرأ ويحدّث `full_name` و`phone` و`locale` وفق RLS الحالي.
- كتالوج حقيقي يقرأ الألعاب النشطة والعروض المنشورة من Supabase الحالي.
- شاشة ألعاب، شاشة عروض اللعبة، وتفاصيل العرض العامة.
- Pull-to-refresh وloading وempty وerror وretry.
- العربية RTL والفرنسية LTR، مع الوضع الفاتح والداكن.

لم تُنفذ بعد: إنشاء الطلبات، اختيار وسيلة الدفع، رفع إثبات الدفع، المفضلة، الإشعارات، Realtime، أو cache دائم للكتالوج.

## الهوية والمتطلبات

- Project name: `calculff_client`
- Display name: `CalculFF Client`
- Android Application ID: `com.gm0h1.calculffclient`
- Version: `0.1.0+1`
- Android minSdk: 23
- Java: 17
- Flutter CI: `3.44.0`

## العلاقة مع calculff

`mohamed09090-xmd/calculff` هو مصدر الحقيقة للجداول وRLS وRPCs. هذا المستودع لا يدير migrations ولا يعدل Hosted Supabase.

العقود المستخدمة:

- `profiles(id, email, full_name, phone, locale)`.
- `games(id, slug, name_ar, name_fr, reward_unit_code, reward_unit_name_ar, reward_unit_name_fr, is_active, sort_order)`.
- `public_offers(id, game_id, name_ar, name_fr, reward_quantity, sale_price_dzd, is_published, sort_order)`.
- المستخدم المصادق يقرأ الألعاب النشطة فقط.
- المستخدم المصادق يقرأ العرض المنشور فقط عندما تكون لعبته نشطة.
- `public_offers` لا يحتوي أعمدة تكلفة أو ربح أو مخزون، ولا يعرض التطبيق أي بيانات إدارية.
- RLS في PostgreSQL هو حاجز الأمان الأساسي، مع فلاتر دفاعية إضافية داخل Repository.

راجع `docs/CATALOG.md` للتفاصيل.

## التشغيل دون إعداد Supabase

```bash
flutter pub get
flutter run
```

يفتح التطبيق شاشة إعداد آمنة ولا يجري اتصالًا شبكيًا. ملفات Flutter metadata وGradle wrapper المطلوبة محفوظة في المستودع، لذلك لا يحتاج الاستنساخ إلى إعادة توليد المشروع.

## التشغيل بإعداد حقيقي

لا تحفظ القيم في ملف أو commit:

```bash
flutter run \
  --dart-define=SUPABASE_URL="<HTTPS_URL>" \
  --dart-define=SUPABASE_PUBLISHABLE_KEY="<PUBLISHABLE_KEY>"
```

يرفض التطبيق HTTP، القيم ذات المسافات التالفة، `service_role`، و`sb_secret`.

## Auth flow

`initializing → config missing / signed out → email unconfirmed → authenticated`

حدث `passwordRecovery` يوجه إلى شاشة كلمة المرور الجديدة. Deep link المستخدم:

```text
calculffclient://auth-callback
```

يجب إضافته يدويًا إلى Redirect URLs في Supabase Dashboard مع إعداد SMTP عند الحاجة.

## Catalog flow

`Home → active games → published offers → offer details`

كل مسارات الكتالوج محمية. انتهاء الجلسة أو Logout يعيد المستخدم إلى Auth ولا يبقي مسار الكتالوج مفتوحًا. الاستعلامات تستخدم ترتيبًا مستقرًا حسب `sort_order` ثم `id`، ولا تستخدم بيانات وهمية أو Hosted Supabase داخل الاختبارات.

## الأوامر

```bash
flutter pub get
flutter gen-l10n
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test --coverage
flutter build apk --debug
```

CI لا يستخدم Supabase حقيقيًا ويرفع `coverage/lcov.info` وDebug APK كـArtifacts. Debug APK ليس إصدارًا إنتاجيًا ولا يستخدم مفاتيح توقيع التطبيق الإداري.

## المعمارية

```text
lib/app
lib/core
lib/features/auth/{application,domain,infrastructure,presentation}
lib/features/catalog/{application,domain,infrastructure,presentation}
lib/features/home/presentation
lib/features/profile/presentation
lib/features/settings/application
lib/l10n
```

Widgets لا تستدعي Supabase مباشرة. راجع `docs/ARCHITECTURE.md` و`docs/AUTHENTICATION.md` و`docs/SECURITY_MODEL.md` و`docs/CATALOG.md`.

## منع الأسرار

لا تضع `.env` أو URL حقيقيًا أو مفاتيح Supabase أو tokens أو `key.properties` أو keystore داخل المستودع أو Issues أو Artifacts.
