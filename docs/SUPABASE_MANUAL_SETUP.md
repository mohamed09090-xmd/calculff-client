# Supabase manual setup

هذه المهمة لم تعدل Hosted Supabase.

## Dart defines

- `SUPABASE_URL`: HTTPS URL لمشروع CalculFF الحالي.
- `SUPABASE_PUBLISHABLE_KEY`: publishable/anon-compatible key فقط، وليس `service_role` أو `sb_secret`.

## Dashboard operations المطلوبة يدويًا

1. أضف `calculffclient://auth-callback` إلى Auth Redirect URLs.
2. راجع Site URL وسياسة تأكيد البريد.
3. فعّل SMTP حقيقيًا عند الحاجة واختبر التسليم خارج CI.
4. اختبر Android deep link على نسخة مربوطة بالمشروع الفعلي.

CI لا يملك URL أو مفاتيح حقيقية ولا يتصل بمشروع Supabase.
