# Architecture

CalculFF Client يستخدم Feature-first architecture.

- `app`: bootstrap، theme، runtime، routing.
- `core`: configuration، secure storage، widgets المشتركة.
- `features/auth`: نماذج وعقود Auth، controller، تنفيذ Supabase، والشاشات.
- `features/profile`: عرض وتحديث الحقول المسموحة بعقد RLS.
- `features/home`: هيكل ما بعد الدخول دون بيانات تجريبية.
- `features/settings`: locale وtheme state.

Widgets لا تستدعي Supabase. `AuthRepository` هو الحد بين application وinfrastructure. `RouteDecision` دالة مستقلة قابلة للاختبار لمنع loops وnavigation storms.
