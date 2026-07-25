import 'package:calculff_client/features/auth/application/auth_providers.dart';
import 'package:calculff_client/features/auth/domain/auth_models.dart';
import 'package:calculff_client/features/auth/presentation/auth_screens.dart';
import 'package:calculff_client/features/home/presentation/home_screen.dart';
import 'package:calculff_client/features/profile/presentation/profile_screen.dart';
import 'package:calculff_client/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fakes.dart';

Future<void> pumpLocalized(
  WidgetTester tester,
  Widget child, {
  required TestAuthController controller,
  Locale locale = const Locale('ar'),
  Size? size,
  double textScale = 1,
}) async {
  if (size != null) {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authControllerProvider.overrideWith((ref) => controller)],
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
          child: child,
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('welcome screen is Arabic and RTL', (tester) async {
    final controller = TestAuthController(
      const AuthState(stage: AuthStage.signedOut),
    );
    await pumpLocalized(tester, const WelcomeScreen(), controller: controller);
    expect(find.text('رصيدك وطلباتك في مكان واحد'), findsOneWidget);
    expect(
      Directionality.of(
        tester.element(find.text('رصيدك وطلباتك في مكان واحد')),
      ),
      TextDirection.rtl,
    );
  });

  testWidgets('welcome screen is French and LTR', (tester) async {
    final controller = TestAuthController(
      const AuthState(stage: AuthStage.signedOut),
    );
    await pumpLocalized(
      tester,
      const WelcomeScreen(),
      controller: controller,
      locale: const Locale('fr'),
    );
    expect(
      find.text('Votre crédit et vos commandes, au même endroit'),
      findsOneWidget,
    );
    expect(
      Directionality.of(
        tester.element(
          find.text('Votre crédit et vos commandes, au même endroit'),
        ),
      ),
      TextDirection.ltr,
    );
  });

  testWidgets('login validates fields', (tester) async {
    final controller = TestAuthController(
      const AuthState(stage: AuthStage.signedOut),
    );
    await pumpLocalized(tester, const LoginScreen(), controller: controller);
    await tester.tap(find.widgetWithText(ElevatedButton, 'تسجيل الدخول'));
    await tester.pump();
    expect(find.text('أدخل بريدًا إلكترونيًا صالحًا.'), findsOneWidget);
    expect(find.text('يجب ألا تقل كلمة المرور عن 8 أحرف.'), findsOneWidget);
  });

  testWidgets('signup validates required account fields', (tester) async {
    final controller = TestAuthController(
      const AuthState(stage: AuthStage.signedOut),
    );
    await pumpLocalized(tester, const SignupScreen(), controller: controller);
    await tester.tap(find.widgetWithText(ElevatedButton, 'إنشاء حساب'));
    await tester.pump();
    expect(find.text('أدخل اسمك الكامل.'), findsOneWidget);
    expect(
      find.text('أدخل رقم هاتف صالحًا من 6 إلى 25 محرفًا.'),
      findsOneWidget,
    );
  });

  testWidgets('loading disables repeated login submission', (tester) async {
    final controller = TestAuthController(
      const AuthState(stage: AuthStage.signedOut, isBusy: true),
    );
    await pumpLocalized(tester, const LoginScreen(), controller: controller);
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
    expect(controller.signInInvocations, 0);
  });

  testWidgets('translated error is shown instead of raw exception', (
    tester,
  ) async {
    final controller = TestAuthController(
      const AuthState(
        stage: AuthStage.signedOut,
        failure: AuthFailure(AuthFailureType.invalidCredentials),
      ),
    );
    await pumpLocalized(tester, const LoginScreen(), controller: controller);
    expect(find.text('البريد أو كلمة المرور غير صحيحة.'), findsOneWidget);
  });

  testWidgets('verification, forgot and reset screens render', (tester) async {
    final controller = TestAuthController(
      const AuthState(
        stage: AuthStage.emailUnconfirmed,
        email: 'client@example.com',
      ),
    );
    await pumpLocalized(
      tester,
      const VerifyEmailScreen(),
      controller: controller,
    );
    expect(find.text('أكد بريدك الإلكتروني'), findsOneWidget);

    await pumpLocalized(
      tester,
      const ForgotPasswordScreen(),
      controller: controller,
    );
    expect(find.text('استرجاع كلمة المرور'), findsWidgets);

    await pumpLocalized(
      tester,
      const ResetPasswordScreen(),
      controller: controller,
    );
    expect(find.text('تعيين كلمة مرور جديدة'), findsWidgets);
  });

  testWidgets('home and profile render confirmed user data', (tester) async {
    final controller = TestAuthController(
      const AuthState(
        stage: AuthStage.authenticated,
        session: AuthSessionInfo(
          userId: 'user-1',
          email: 'client@example.com',
          emailConfirmed: true,
        ),
        profile: ClientProfile(
          id: 'user-1',
          email: 'client@example.com',
          fullName: 'Mohamed',
          phone: '+213555000000',
          locale: 'ar',
        ),
      ),
    );
    await pumpLocalized(tester, const HomeScreen(), controller: controller);
    expect(find.text('مرحبًا، Mohamed'), findsOneWidget);

    await pumpLocalized(tester, const ProfileScreen(), controller: controller);
    expect(find.text('بيانات الحساب'), findsOneWidget);
    expect(find.text('client@example.com'), findsOneWidget);
  });

  testWidgets('missing configuration screen is safe', (tester) async {
    final controller = TestAuthController(
      const AuthState(stage: AuthStage.configMissing),
    );
    await pumpLocalized(tester, const SetupScreen(), controller: controller);
    expect(find.text('التطبيق غير مربوط بالمنصة'), findsOneWidget);
    expect(find.textContaining('SUPABASE_URL'), findsOneWidget);
  });

  testWidgets('small screen and large text remain scrollable', (tester) async {
    final controller = TestAuthController(
      const AuthState(stage: AuthStage.signedOut),
    );
    await pumpLocalized(
      tester,
      const WelcomeScreen(),
      controller: controller,
      size: const Size(320, 568),
      textScale: 2,
    );
    expect(tester.takeException(), isNull);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
  });

  testWidgets('login exposes core semantics', (tester) async {
    final semantics = tester.ensureSemantics();
    try {
      final controller = TestAuthController(
        const AuthState(stage: AuthStage.signedOut),
      );
      await pumpLocalized(tester, const LoginScreen(), controller: controller);
      expect(find.bySemanticsLabel('حقل البريد الإلكتروني'), findsOneWidget);
      expect(find.bySemanticsLabel('حقل كلمة المرور'), findsOneWidget);
    } finally {
      semantics.dispose();
    }
  });
}
