-- Localized Arabic copy for season_events (grid + detail cards when app language is Arabic).

alter table public.season_events add column if not exists arabic_name text;
alter table public.season_events add column if not exists arabic_category text;
alter table public.season_events add column if not exists arabic_description text;
alter table public.season_events add column if not exists arabic_location text;

update public.season_events set
  arabic_name = 'أرض الشتاء السحرية',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'جدة، المملكة العربية السعودية'
where name = 'Winter Wonderland';

update public.season_events set
  arabic_name = 'وحش البلد',
  arabic_category = 'موسيقى حية',
  arabic_location = 'جدة، المملكة العربية السعودية'
where name = 'Balad Beast';

update public.season_events set
  arabic_name = 'قبة الثلج',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'جدة، المملكة العربية السعودية'
where name = 'The Snow Dome';

update public.season_events set
  arabic_name = 'حلبة التزلج',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'جدة، المملكة العربية السعودية'
where name = 'Ice Rink';

update public.season_events set
  arabic_name = 'الأرض الاستوائية',
  arabic_category = 'مغامرة',
  arabic_location = 'جدة، المملكة العربية السعودية'
where name = 'Tropical Land';

update public.season_events set
  arabic_name = 'نوتات وطر',
  arabic_category = 'كاريوكي',
  arabic_location = 'جدة، المملكة العربية السعودية'
where name = 'Notat Watar';

update public.season_events set
  arabic_name = 'المسار',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'الرياض، المملكة العربية السعودية'
where name = 'Almasar';

update public.season_events set
  arabic_name = 'قبة فوز – سينما غامرة',
  arabic_category = 'سينما',
  arabic_location = 'الرياض، المملكة العربية السعودية'
where name = 'VUZ Dome – Immersive Cinema';

update public.season_events set
  arabic_name = 'ليالي الديرة',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'الرياض، المملكة العربية السعودية'
where name = 'Layali Al-Diriyah';

update public.season_events set
  arabic_name = 'خيمة الغروفز',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'الرياض، المملكة العربية السعودية'
where name = 'Khemah The Groves';

update public.season_events set
  arabic_name = 'مركز',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'مكة المكرمة، المملكة العربية السعودية'
where name = 'Mirkaz';

update public.season_events set
  arabic_name = 'سكاي رايز العلا',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'العلا، المملكة العربية السعودية'
where name = 'AlUla Skyrise';

update public.season_events set
  arabic_name = 'عرض توهج المناطيد',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'العلا، المملكة العربية السعودية'
where name = 'Balloon Glow Show';

update public.season_events set
  arabic_name = 'لهيب صحراء العلا',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'العلا، المملكة العربية السعودية'
where name = 'AlUla Desert Blaze';

update public.season_events set
  arabic_name = 'منطاد هوائي مربوط',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'العلا، المملكة العربية السعودية'
where name = 'Tethered Hot Air Balloon';

update public.season_events set
  arabic_name = 'حفل مهرجان السماء',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'العلا، المملكة العربية السعودية'
where name = 'Skies Festival Concert';

update public.season_events set
  arabic_name = 'رحلة طريق البخور',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'العلا، المملكة العربية السعودية'
where name = 'Incense Road Journey';

update public.season_events set
  arabic_name = 'مهرجان وصل',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'أبها، المملكة العربية السعودية'
where name = 'Wasal Festival';

update public.season_events set
  arabic_name = 'قرية المسقي التراثية',
  arabic_category = 'مناسبة موسمية',
  arabic_location = 'أبها، المملكة العربية السعودية'
where name = 'Al-Masqi Heritage Village';
