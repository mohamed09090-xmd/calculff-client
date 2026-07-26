# Architecture

CalculFF Client يستخدم Feature-first architecture.

- `app`: bootstrap، theme، runtime، routing.
- `core`: configuration، secure storage، widgets المشتركة.
- `features/auth`: نماذج وعقود Auth، controller، تنفيذ Supabase، والشاشات.
- `features/catalog`: نماذج الألعاب والعروض، عقد Repository، Supabase gateway، Riverpod controllers، وشاشات الكتالوج.
- `features/profile`: عرض وتحديث الحقول المسموحة بعقد RLS.
- `features/home`: نقطة الدخول بعد المصادقة وإطلاق الكتالوج.
- `features/settings`: locale وtheme state.

## حدود الكتالوج

```text
features/catalog/
├── application/       حالة القوائم ومنع الطلب المتكرر والتحديث
├── domain/            CatalogGame وCatalogOffer وCatalogRepository
├── infrastructure/    mapping صارم وSupabase queries وerror mapping
└── presentation/      الألعاب والعروض والتفاصيل وحالات الواجهة
```

Widgets لا تستدعي Supabase. `AuthRepository` و`CatalogRepository` هما الحد بين application وinfrastructure. `CatalogGateway` يسمح باختبار Repository دون شبكة، و`RouteDecision` دالة مستقلة قابلة للاختبار لمنع loops وnavigation storms وإغلاق المسارات المحمية بعد Logout.
