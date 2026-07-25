# Authentication

## الحالات

- Config missing
- Initializing
- Signed out
- Signed in but email unconfirmed
- Signed in and confirmed
- Password recovery
- Recoverable startup error

يستعيد التطبيق الجلسة من secure storage قبل توجيه المستخدم. Auth events تحدّث الحالة المركزية، و`go_router` يطبق القرار دون وضع منطق Supabase في الصفحات.

## التسجيل والملف

Backend ينشئ `profiles` بالبريد فقط ولا يقرأ user metadata. لذلك يحفظ التطبيق مؤقتًا `full_name`, `phone`, و`locale` داخل secure storage دون كلمة المرور، ثم يحدث صف profile بعد توفر جلسة مصادق عليها. عند فشل التسجيل أو Logout تمسح البيانات المؤقتة.

## تأكيد البريد والاسترجاع

إعادة الإرسال تطبق cooldown محليًا. طلب الاسترجاع يعرض جوابًا موحدًا لا يكشف وجود الحساب. حدث Supabase `passwordRecovery` يوجه إلى شاشة تحديث كلمة المرور.

Redirect URL المطلوب: `calculffclient://auth-callback`.
