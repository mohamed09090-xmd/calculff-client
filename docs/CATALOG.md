# Customer Catalog

## النطاق

هذه المرحلة تعرض كتالوج CalculFF الحقيقي للزبون المصادق دون إنشاء طلب أو دفع. مصدر الحقيقة للعقد هو `mohamed09090-xmd/calculff` وفرع `main`.

## الجداول المقروءة

### `public.games`

الأعمدة المقروءة فقط:

- `id`
- `slug`
- `name_ar`
- `name_fr`
- `reward_unit_code`
- `reward_unit_name_ar`
- `reward_unit_name_fr`
- `is_active`
- `sort_order`

الاستعلام يطلب `is_active = true` ويرتب حسب `sort_order ASC, id ASC`. RLS يسمح للمستخدم المصادق بالألعاب النشطة فقط.

### `public.public_offers`

الأعمدة المقروءة فقط:

- `id`
- `game_id`
- `name_ar`
- `name_fr`
- `reward_quantity`
- `sale_price_dzd`
- `is_published`
- `sort_order`

الاستعلام يقيّد `game_id` و`is_published = true` ويرتب حسب `sort_order ASC, id ASC`. RLS يسمح للمستخدم المصادق بالعروض المنشورة فقط عندما تكون اللعبة المرتبطة نشطة.

## الأمان

- لا يستطيع `anon` قراءة الكتالوج.
- لا يستخدم التطبيق `service_role` أو أي مفتاح إداري.
- RLS هو حاجز الأمان الأساسي.
- يكرر Repository قواعد النشاط والنشر وربط العرض باللعبة كفلترة دفاعية، لكنه لا يستبدل RLS.
- الموديلات لا تحتوي تكلفة أو ربحًا أو مخزونًا أو timestamps أو بيانات إدارية.
- أخطاء Supabase لا تظهر خامًا للمستخدم.
- انتهاء الجلسة يستدعي Logout الآمن ويغلق المسارات المحمية.
- لم يُعدّل Hosted Supabase، ولم تُنشأ migration أو policy أو RPC.

## المعمارية

```text
catalog/
├── application/       Riverpod state وcontrollers
├── domain/            الألعاب والعروض وCatalogRepository والفشل الآمن
├── infrastructure/    Supabase gateway وDTO mapping وRepository
└── presentation/      الألعاب والعروض والتفاصيل والحالات المشتركة
```

Widgets لا تستدعي Supabase. `CatalogGateway` قابل للاستبدال في الاختبارات، لذلك لا يصل CI إلى Hosted Supabase.

## تجربة الاستخدام

- Home هو نقطة الدخول.
- قائمة الألعاب النشطة.
- عروض اللعبة المنشورة.
- تفاصيل العرض العامة عند توفر البيانات.
- العربية تستخدم النص العربي وRTL، والفرنسية تستخدم النص الفرنسي وLTR.
- Pull-to-refresh وretry وحالات loading وempty وerror.
- منع طلب جديد أثناء وجود طلب قيد التنفيذ.
- حفظ حالة القائمة داخل مزودات Riverpod أثناء الرجوع من التفاصيل.
- Semantics، شاشات صغيرة، ونص مكبر.

## غير منفذ

- إنشاء الطلب.
- وسائل الدفع أو إثبات الدفع.
- المفضلة والإشعارات وRealtime.
- بحث شبكي متقدم.
- cache دائم دون اتصال.
- أي تعديل Backend أو Hosted Supabase.
