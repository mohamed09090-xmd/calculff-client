# CalculFF Client

تطبيق Android مخصص لزبائن منصة CalculFF، منفصل عن تطبيق الإدارة المحلي.

## الحالة الحالية

المرحلة الحالية تنفذ Foundation + Authentication فقط:

- Bootstrap آمن مع حالة واضحة عند غياب إعداد Supabase.
- تسجيل الدخول وإنشاء الحساب وتأكيد البريد.
- طلب استرجاع كلمة المرور والتعامل مع deep link لإعادة التعيين.
- جلسة Supabase محفوظة في `flutter_secure_storage`.
- ملف شخصي يقرأ ويحدّث `full_name` و`phone` و`locale` وفق RLS الحالي.
- Home هيكلي دون عروض أو طلبات وهمية.
- العربية RTL والفرنسية LTR، مع الوضع الفاتح والداكن.

لم تُنفذ بعد: كتالوج الألعاب والعروض، إنشاء الطلبات، الدفع، الإشعارات، أو أي تعديل Backend.

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

العقد المستخدم حاليًا:

- `profiles(id, email, full_name, phone, locale)`.
- trigger ينشئ profile بالبريد عند إنشاء Auth user.
- المستخدم المصادق يقرأ صفه ويحدّث فقط `full_name`, `phone`, `locale`.
- إكمال الملف مطلوب لاحقًا قبل `create_order`.

## التشغيل دون إعداد Supabase

```bash
flutter pub get
flutter run
```

يفتح التطبيق شاشة إعداد آمنة ولا يجري اتصالًا شبكيًا.

لأن ملف Gradle wrapper الثنائي لا يحفظ في المستودع، نفّذ مرة واحدة بعد الاستنساخ:

```bash
flutter create --platforms=android --org com.gm0h1 --project-name calculff_client .
```

ثم تحقق أن `android/app/build.gradle` ما زال يستخدم `com.gm0h1.calculffclient`.

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
lib/features/home/presentation
lib/features/profile/presentation
lib/features/settings/application
lib/l10n
```

راجع `docs/ARCHITECTURE.md` و`docs/AUTHENTICATION.md` و`docs/SECURITY_MODEL.md`.

## منع الأسرار

لا تضع `.env` أو URL حقيقيًا أو مفاتيح Supabase أو tokens أو `key.properties` أو keystore داخل المستودع أو Issues أو Artifacts.
