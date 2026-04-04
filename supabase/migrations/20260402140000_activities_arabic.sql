-- Localized Arabic copy for activities (Figma Arabic frames; city filter keys stay English in app).

alter table public.activities add column if not exists arabic_name text;
alter table public.activities add column if not exists arabic_category text;
alter table public.activities add column if not exists arabic_description text;
alter table public.activities add column if not exists arabic_location text;

-- Jeddah — copy aligned with Figma node 1449:9870 (activity detail strings)
update public.activities set
  arabic_name = 'تجربة الغوص',
  arabic_category = 'الغوص الحر',
  arabic_location = 'جدة، السعودية',
  arabic_description = 'اكتشف أعماق البحر الأحمر مع تجربة غوص احترافية لمدة 5 ساعات من جدة. اسبح بين الشعاب المرجانية الملوّنة والكائنات البحرية النابضة بالحياة، برفقة مدرّبين معتمدين وفي مواقع غوص مناسبة لجميع المستويات. مجموعات صغيرة، معدات عالية الجودة، ومياه صافية تجعل من التجربة مغامرة تحت الماء لا تُنسى. رحلتك في البحر الأحمر تبدأ من هنا.'
where id = 1;

update public.activities set
  arabic_name = 'رحلة سفاري في الصحراء',
  arabic_category = 'جولات الدفع الرباعي (4×4)',
  arabic_location = 'جدة، السعودية',
  arabic_description = 'عِش إثارة جولة سفاري بالدراجات الرباعية في الصحراء، وانطلق فوق الكثبان الرملية الذهبية مع الاستمتاع بالمناظر الصحراوية الخلابة. اشعر بالأدرينالين، التقط أجمل المشاهد، وانغمس في جمال وهدوء الصحراء لتجربة مغامرة لا تُنسى.'
where id = 2;

update public.activities set
  arabic_name = 'رحلة لنصف يوم بالقارب',
  arabic_category = 'على الماء',
  arabic_location = 'جدة، السعودية',
  arabic_description = 'اكتشف ساحل البحر الأحمر وتجربة الحياة البحرية المحلية في جدة. انضم إلى العائلات والسكان المحليين في المرسى، وتفاعل مع المجتمع المحلي، وتعرف على الكنوز البحرية الفريدة من خلال قادة السفن المتحمسين. هذه الجولة مناسبة طوال العام بفضل شتاء جدة المعتدل.'
where id = 3;

update public.activities set
  arabic_name = 'جولة خاصة ليوم كامل',
  arabic_category = 'جولة سياحية خاصة',
  arabic_location = 'جدة، السعودية',
  arabic_description = 'اكتشف سحر جدة في جولة خاصة ليوم كامل مع مرشد محلي. تجوّل في الأحياء العصرية، المقاهي، جلسات الشيشة، والمعالم الشهيرة مثل كورنيش البحر الأحمر، المسجد العائم، وأعلى سارية علم. عش تجربة المدينة كما يفعل السكان المحليون واكتشف كنوزها المخفية.'
where id = 4;

update public.activities set
  arabic_name = 'جولة في الحي التاريخي بجدة مع مرشد محلي',
  arabic_category = 'جولة لنصف يوم',
  arabic_location = 'جدة، السعودية',
  arabic_description = 'اكتشف البلد، الحي التاريخي المسجّل في قائمة التراث العالمي لليونسكو في جدة. تجوّل بين البيوت المبنية من الحجر المرجاني، واستكشف المتاحف والمعارض والكنوز المخفية برفقة مرشد محلي معتمد. عِش التاريخ الغني، والثقافة الحيوية، والجمال الخالد لهذا الحي العريق في جولة لا تُنسى.'
where id = 5;

update public.activities set
  arabic_name = 'رحلة تسلق جبل القمر',
  arabic_category = 'جولة بالسيارة',
  arabic_location = 'جدة، السعودية',
  arabic_description = 'تنزه في وادي القمر الساحر واستمتع بالطبيعة السعودية بطريقة فريدة. هذا المسار المميز يوفر هروبًا هادئًا من صخب المدينة، مثالي لمن يبحث عن وقت ممتع في الهواء الطلق.'
where id = 6;

update public.activities set
  arabic_name = 'تجربة ركوب الخيل',
  arabic_category = 'جولات على ظهور الحيوانات',
  arabic_location = 'جدة، السعودية',
  arabic_description = 'استمتع بإثارة مناظر جدة الطبيعية على ظهور الخيل! امتطِ الخيل على طول ساحل شاطئ خليج سلمان الجميل، حيث تلتقي مياه البحر الأحمر الفيروزية بالرمال الناعمة. استمتع بإطلالات البحر، نسيمه العليل، وتجربة هادئة وممتعة على هذا الشاطئ الخلاب.'
where id = 7;

-- Riyadh
update public.activities set
  arabic_name = 'مخيم رويال الفاخر',
  arabic_category = 'تخييم',
  arabic_location = 'الرياض، السعودية',
  arabic_description = 'مخيم صحراوي فسيح يستضيف أكثر من 150 ضيفًا، مثالي للعائلات والفعاليات والمناسبات الخاصة في قلب رمال الرمال الحمراء الهادئة.'
where id = 8;

update public.activities set
  arabic_name = 'سفاري رانغلر',
  arabic_category = 'جولة 4×4',
  arabic_location = 'الرياض، السعودية',
  arabic_description = 'اكتشف جمال الرمال الحمراء في جولة فاخرة بمركبة رانغلر مع مرشدين خبراء يجوبون الكثبان بثقة وراحة.'
where id = 9;

update public.activities set
  arabic_name = 'ركوب الجمال',
  arabic_category = 'جولات على الحيوانات',
  arabic_location = 'الرياض، السعودية',
  arabic_description = 'جرب ركوب الجمال على الطريقة البدوية بين مناظر صحراوية خلابة وكثبان ذهبية لا تنتهي.'
where id = 10;

update public.activities set
  arabic_name = 'ركوب الخيل',
  arabic_category = 'جولات على الحيوانات',
  arabic_location = 'الرياض، السعودية',
  arabic_description = 'استمتع بركوب الخيل عبر الكثبان الحمراء بأسلوب الفروسية العربية الأصيلة.'
where id = 11;

-- Mecca
update public.activities set
  arabic_name = 'رحلة روحانية',
  arabic_category = 'جولات',
  arabic_location = 'مكة المكرمة، السعودية',
  arabic_description = 'جولة روحانية في مكة تشمل عرفات ومزدلفة ومِنى وجسر الجمرات ومسجد الخيف، ثم جبل النور وغار حراء، وختامًا معرض الوحي.'
where id = 12;

update public.activities set
  arabic_name = 'متحف برج الساعة',
  arabic_category = 'متحف',
  arabic_location = 'مكة المكرمة، السعودية',
  arabic_description = 'استمتع بإطلالات بانورامية على الحرم من متحف برج الساعة في أبراج البيت، مع رحلة تفاعلية حول الفلك وتطور مكة.'
where id = 13;

update public.activities set
  arabic_name = 'حياة النبي',
  arabic_category = 'جولات',
  arabic_location = 'مكة المكرمة، السعودية',
  arabic_description = 'رحلة تاريخية وروحانية تتبع خطى النبي محمد ﷺ من جبل ثور ووادي إبراهيم إلى جبل النور.'
where id = 14;

update public.activities set
  arabic_name = 'جولة مصنع الكسوة',
  arabic_category = 'جولات',
  arabic_location = 'مكة المكرمة، السعودية',
  arabic_description = 'تعرّف على تراث الكسوة الشريفة ثم زر موقع الحديبية التاريخي مع مرشدٍ متمكن.'
where id = 15;

update public.activities set
  arabic_name = 'جولة اكتشاف حراء',
  arabic_category = 'جولات',
  arabic_location = 'مكة المكرمة، السعودية',
  arabic_description = 'استكشف حي حراء مع معرض الوحي ومتحف أثر القرآن، ثم تسلّق جبل النور وغار حراء.'
where id = 16;

-- AlUla
update public.activities set
  arabic_name = 'جولة يوم في الحجر',
  arabic_category = 'جولات',
  arabic_location = 'العلا، السعودية',
  arabic_description = 'اخترق تاريخ الأنباط في موقع اليونسكو مع رواة محليين وقصر الفريد ومعالم العلا الأيقونية.'
where id = 17;

update public.activities set
  arabic_name = 'مراقبة النجوم في الغراميل',
  arabic_category = 'الطبيعة والهواء الطلق',
  arabic_location = 'العلا، السعودية',
  arabic_description = 'أفق درب التبانة وسط تشكيلات صخرية بعيدًا عن التلوث الضوئي، مع عشاء مشوي حول نار.'
where id = 18;

update public.activities set
  arabic_name = 'مشي مضمار مداخل',
  arabic_category = 'مغامرة',
  arabic_location = 'العلا، السعودية',
  arabic_description = 'امشِ في مسارات محمية شعبان بين الطبيعة والتكوينات الرملية الخلابة.'
where id = 19;

update public.activities set
  arabic_name = 'مركز ويلز للدراجات',
  arabic_category = 'مغامرة',
  arabic_location = 'العلا، السعودية',
  arabic_description = 'أجر دراجة وانطلق على مسار 26 كم بين العذيب والحجر مع دعم وصيانة وكافيه في النهاية.'
where id = 20;

update public.activities set
  arabic_name = 'جولة أثرية',
  arabic_category = 'جولة',
  arabic_location = 'العلا، السعودية',
  arabic_description = 'اكتشف مواقع تنقيب حية مع خبراء وعشاء فاخر في الواحة.'
where id = 21;

-- Southern
update public.activities set
  arabic_name = 'جولة تاريخية',
  arabic_category = 'جولات',
  arabic_location = 'السودة، السعودية',
  arabic_description = 'استكشف قرية رجال ألمع التاريخية قرب أبها مع تنقّل ووجبات محلية في مجموعة صغيرة.'
where id = 22;

update public.activities set
  arabic_name = 'رحلة إلى آبار حمى',
  arabic_category = 'رحلات',
  arabic_location = 'نجران، السعودية',
  arabic_description = 'جولة إلى الأخدود وآبار حماء اليونسكو مع نقوش وتاريخ جنوب الجزيرة.'
where id = 23;

update public.activities set
  arabic_name = 'جولة مزرعة القهوة',
  arabic_category = 'جولات',
  arabic_location = 'أبها، السعودية',
  arabic_description = 'تعرّف على زراعة القهوة في الجنوب ثم مغامرة بسيارات الدفع الرباعي نحو أعلى القمم.'
where id = 24;

update public.activities set
  arabic_name = 'مشي سودة',
  arabic_category = 'مغامرات',
  arabic_location = 'أبها، السعودية',
  arabic_description = 'مسار اختياري 8 كم على ارتفاع 3000 متر بين أشجار العرعر الدائمة الخضرة.'
where id = 25;

update public.activities set
  arabic_name = 'متحف فاطمة',
  arabic_category = 'متحف',
  arabic_location = 'أبها، السعودية',
  arabic_description = 'معرض تراثي يعرض قطعًا وحرفًا وتقاليد المملكة في أجواء تعليمية ممتعة.'
where id = 26;
