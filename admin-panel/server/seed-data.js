const bcrypt = require('bcryptjs');

// Admin password hashed synchronously
const adminPasswordHash = bcrypt.hashSync(process.env.ADMIN_PASSWORD || 'change-me', 10);

// ─── Restaurants (34 total) ─────────────────────────────────────────────────
const restaurants = [
  // Jeddah (10)
  {
    name: 'Le Vesuvio',
    arabic_name: 'لي فيزوفيو',
    rating: 4.5,
    cuisine: 'Italian, Pizza',
    arabic_cuisine: 'إيطالي، بيتزا',
    image_name: 'restaurant-le-vesuvio',
    has_michelin: 0,
    description: 'Le Vesuvio offers authentic Italian dining by the waterfront at Jeddah Yacht Club & Marina. Enjoy wood fired pizzas, handmade pastas, and fresh seafood in a modern, elegant setting with stunning marina views. A perfect spot for date nights, gatherings, or a refined evening by the sea.',
    arabic_description: 'يقدّم لي فيزوفيو تجربة طعام إيطالية أصيلة على الواجهة البحرية في مرسى ونادي اليخوت بجدة. استمتعوا ببيتزا الحطب، والباستا المصنوعة يدويًا، والمأكولات البحرية الطازجة في أجواء عصرية راقية وإطلالة خلابة على المرسى. المكان المثالي لسهرة راقية، أو موعد عشاء، أو تجمع مميز بجانب البحر.',
    city: 'Jeddah',
    arabic_city: 'جدة'
  },
  {
    name: 'ROKA',
    arabic_name: 'روكا',
    rating: 4.6,
    cuisine: 'Japanese',
    arabic_cuisine: 'ياباني',
    image_name: 'restaurant-roka',
    has_michelin: 0,
    description: 'ROKA Jeddah brings modern Japanese robatayaki dining to a sleek, contemporary space at Jeddah Walk. The menu features signature grilled dishes, sushi, and bold Japanese flavors, all served in a vibrant, upscale atmosphere perfect for dinners, celebrations, or a stylish night out.',
    arabic_description: 'يقدّم ROKA جدة تجربة "روبتاياكي" يابانية عصرية في مساحة أنيقة وحديثة في ممشى جدة. تتضمن القائمة أطباقهم المشوية المميزة، والسوشي، ونكهات يابانية جريئة، جميعها تُقدَّم في أجواء راقية نابضة بالحيوية—مثالية للعشاء، والاحتفالات، أو لقضاء سهرة أنيقة.',
    city: 'Jeddah',
    arabic_city: 'جدة'
  },
  {
    name: 'Myazu',
    arabic_name: 'ميازو',
    rating: 4.5,
    cuisine: 'Japanese, Sushi',
    arabic_cuisine: 'ياباني، سوشي',
    image_name: 'restaurant-myazu',
    has_michelin: 1,
    description: "Myazu Jeddah delivers contemporary Japanese fusion dining in a chic, upscale setting. With a menu that spans fresh sushi, sashimi, robata grilled dishes and creative fusion plates, it's a great spot for elegant dinners, special occasions, or a stylish night out.",
    arabic_description: 'ميازو يقدّم تجربة طعام يابانية عصرية في أجواء راقية وأنيقة. تشمل قائمته السوشي والساشيمي الطازج، وأطباق الروباتا المشوية، وأطباق يابانية مبتكرة، مما يجعله مكانًا مثاليًا لعشاء فاخر، أو المناسبات الخاصة، أو سهرة أنيقة.',
    city: 'Jeddah',
    arabic_city: 'جدة'
  },
  {
    name: 'Pampas',
    arabic_name: 'بامباز',
    rating: 4.9,
    cuisine: 'Latin, Barbecue',
    arabic_cuisine: 'لاتيني، باربيكيو',
    image_name: 'restaurant-pampas',
    has_michelin: 0,
    description: 'Pampas offers an authentic South American dining experience with a focus on premium grilled meats and bold Argentine flavors. Set in an elegant, warm atmosphere, it\'s perfect for steak lovers, celebratory dinners, or anyone looking for a refined Latin inspired night out.',
    arabic_description: 'يقدّم بامباس تجربة طعام لاتينية جنوبية أصيلة تركّز على اللحوم المشوية الفاخرة ونكهات الأرجنتين القوية. يتميز بأجواء أنيقة ودافئة، مما يجعله خيارًا مثاليًا لعشّاق الستيك، ولعشاء احتفالي، أو لأي شخص يبحث عن سهرة راقية مستوحاة من المطبخ اللاتيني.',
    city: 'Jeddah',
    arabic_city: 'جدة'
  },
  {
    name: 'Rasoi by Vineet',
    arabic_name: 'راسوي باي فينيت',
    rating: 4.9,
    cuisine: 'Indian, Asian',
    arabic_cuisine: 'هندي، آسيوي',
    image_name: 'restaurant-rasoi',
    has_michelin: 1,
    description: 'Rasoi by Vineet brings modern Indian fine dining to Jeddah, led by Michelin starred chef Vineet Bhatia. The restaurant blends bold Indian flavors with contemporary presentation, offering creative curries, tandoor specialties, and elegant appetizers in a refined, luxurious setting perfect for special occasions.',
    arabic_description: 'يقدّم راسوي باي فينيت تجربة طعام هندية راقية بطابع حديث في جدة، تحت إشراف الشيف الحاصل على نجمة ميشلان فينيت باتيا. يجمع المطعم بين النكهات الهندية القوية والعرض العصري للأطباق، مع توليفة من الكاري الإبداعي، وتخصصات التندور، والمقبلات الأنيقة في أجواء فاخرة وراقية مثالية للمناسبات الخاصة.',
    city: 'Jeddah',
    arabic_city: 'جدة'
  },
  {
    name: 'Kuuru',
    arabic_name: 'كورو',
    rating: 4.5,
    cuisine: 'Japanese',
    arabic_cuisine: 'ياباني',
    image_name: 'restaurant-kuuru',
    has_michelin: 0,
    description: 'Kuuru in Jeddah offers refined Japanese-fusion dining in a chic, contemporary setting. Expect artfully prepared sushi, sashimi, and fusion dishes, served in a stylish ambiance ideal for elegant dinners, relaxed nights out, or special occasions.',
    arabic_description: 'يقدّم كورو جدة تجربة طعام يابانية فاخرة بلمسة فيوجن عصرية، في أجواء أنيقة وحديثة. يتوقع الزوّار سوشي وساشيمي مُحضّر بعناية، وأطباق فيوجن مبتكرة، تُقدَّم في بيئة راقية مثالية لعشاء أنيق، أو سهرة هادئة، أو مناسبة خاصة.',
    city: 'Jeddah',
    arabic_city: 'جدة'
  },
  {
    name: 'Shang Palace',
    arabic_name: 'قصر شانق',
    rating: 4.8,
    cuisine: 'Chinese',
    arabic_cuisine: 'صيني',
    image_name: 'restaurant-shang',
    has_michelin: 0,
    description: 'Shang Palace brings authentic Cantonese fine dining to Jeddah with elegant interiors, traditional flavors, and refined presentation. The menu features handcrafted dim sum, signature roasted dishes, and classic Cantonese specialties, making it a perfect spot for upscale family dinners, celebrations, or a premium Chinese dining experience.',
    arabic_description: 'يقدّم قصر شانق تجربة طعام كانتونية راقية وأصيلة في جدة، مع ديكورات أنيقة ونكهات تقليدية وتقديم متقن للأطباق. تشمل القائمة ديم سام محضّر يدويًا، وأطباقهم المشوية المميزة، وتخصصات كانتونية كلاسيكية، مما يجعله مكانًا مثاليًا لعشاء عائلي فاخر، أو الاحتفالات، أو تجربة طعام صينية راقية.',
    city: 'Jeddah',
    arabic_city: 'جدة'
  },
  {
    name: 'Lucky Llama',
    arabic_name: 'ذا لاكي لاما',
    rating: 4.5,
    cuisine: 'Latin, Japanese',
    arabic_cuisine: 'لاتيني، ياباني',
    image_name: 'restaurant-lucky',
    has_michelin: 0,
    description: 'The Lucky Llama offers vibrant Nikkei cuisine, blending Peruvian flavors with Japanese techniques. Enjoy ceviche, tiradito, and creative sushi in a lively, stylish setting perfect for casual dinners, date nights, or flavorful nights out.',
    arabic_description: 'يقدّم ذا لاكي لاما مطبخ نيكّي النابض بالحياة، الذي يمزج بين النكهات البيروفية والتقنيات اليابانية. استمتع بالسيفيشه، والتيراديتو، والسوشي الإبداعي في أجواء حيوية وأنيقة مثالية لعشاء غير رسمي، أو موعد، أو سهرة مليئة بالنكهات.',
    city: 'Jeddah',
    arabic_city: 'جدة'
  },
  {
    name: 'MANIKO',
    arabic_name: 'مانكو',
    rating: 4.7,
    cuisine: 'Peruvian, Asian',
    arabic_cuisine: 'بيرو، آسيوي',
    image_name: 'restaurant-maniko',
    has_michelin: 0,
    description: 'Manko Jeddah brings bold Peruvian\u2011fusion flavors to a stylish, modern setting. Enjoy ceviches, grilled steaks, seafood, sushi\u2011inspired bites, and inventive small plates, all crafted for sharing. Perfect for casual dinners, nights out with friends, or special occasions.',
    arabic_description: 'يقدّم مانكو جدة نكهات بيروفية مبتكرة وجريئة في أجواء عصرية وأنيقة. استمتع بالسيفيشه، والستيكات المشوية، والمأكولات البحرية، وقطع السوشي، وأطباق صغيرة مبتكرة—all مصممة للمشاركة. المكان مثالي لعشاء غير رسمي، أو سهرة مع الأصدقاء، أو مناسبات خاصة.',
    city: 'Jeddah',
    arabic_city: 'جدة'
  },
  {
    name: 'Niyyali',
    arabic_name: 'نيّالي',
    rating: 4.7,
    cuisine: 'Lebanese',
    arabic_cuisine: 'لبناني',
    image_name: 'restaurant-niyyali',
    has_michelin: 0,
    description: 'Niyyali blends authentic Lebanese cuisine with modern elegance at Shangri La Jeddah, offering mezze, grilled dishes, and rich Levant\u2011style flavors in a stylish setting by the sea. With indoor dining or a terrace overlooking the Red Sea and the Corniche Circuit, it\'s ideal for cozy dinners, celebrations, or a vibrant night out.',
    arabic_description: 'يقدّم نيّالي تجربة طعام لبنانية أصيلة ممزوجة بالأناقة العصرية في شانغريلا جدة، مع مقبلات مميزة، أطباق مشوية، ونكهات شامية غنية في أجواء أنيقة على البحر. يوفّر المطعم تناول الطعام داخليًا أو على التراس المطل على البحر الأحمر وكورنيش جدة، مما يجعله مثاليًا لعشاء دافئ، أو الاحتفالات، أو سهرة حيوية.',
    city: 'Jeddah',
    arabic_city: 'جدة'
  },
  // Riyadh (9)
  {
    name: 'Robata',
    arabic_name: 'روباتا',
    rating: 4.7,
    cuisine: 'Japanese',
    arabic_cuisine: 'ياباني',
    image_name: 'riyadh-robata',
    has_michelin: 0,
    description: 'Inspired by the Ainu tradition of Robatayaki, the classic Japanese \u201Cfireside cooking,\u201D Robata brings its simple yet refined flavors to Riyadh. Located at The Canopy with a stunning open-air terrace, Robata offers an experience that truly lives up to its name.',
    arabic_description: 'مستوحى من تقاليد الأينو في الروباتاياكي، يقدّم روباتا نكهاته البسيطة والراقية في الرياض. يقع في ذا كانوبي مع تراس مفتوح مذهل.',
    city: 'Riyadh',
    arabic_city: 'الرياض'
  },
  {
    name: 'Les Deux Magots',
    arabic_name: 'لي دو ماغو',
    rating: 4.6,
    cuisine: 'French',
    arabic_cuisine: 'فرنسي',
    image_name: 'riyadh-les-deux-magots',
    has_michelin: 0,
    description: 'Les Deux Magots Via Riyadh celebrates the spirit of the original Parisian landmark with a heartfelt tribute to its rich heritage. The menu honors classic French bistro cuisine, featuring simple, seasonal dishes served from breakfast through dinner \u2014 from the iconic tarte tatin to the comforting croque monsieur.',
    arabic_description: 'يحتفي لي دو ماغو في الرياض بروح المعلم الباريسي الأصلي مع تكريم صادق لتراثه العريق. تقدّم القائمة المأكولات الفرنسية الكلاسيكية.',
    city: 'Riyadh',
    arabic_city: 'الرياض'
  },
  {
    name: 'Myazu',
    arabic_name: 'ميازو',
    rating: 4.5,
    cuisine: 'Japanese, Sushi',
    arabic_cuisine: 'ياباني، سوشي',
    image_name: 'riyadh-myazu',
    has_michelin: 1,
    description: 'Myazu Riyadh delivers contemporary Japanese fusion dining in a chic, upscale setting. With a menu that spans fresh sushi, sashimi, robata grilled dishes and creative fusion plates, it\u2019s a great spot for elegant dinners, special occasions, or a stylish night out.',
    arabic_description: 'يقدّم ميازو الرياض تجربة طعام يابانية عصرية في أجواء راقية وأنيقة مع سوشي وساشيمي طازج وأطباق فيوجن مبتكرة.',
    city: 'Riyadh',
    arabic_city: 'الرياض'
  },
  {
    name: 'Vega Cigar Lounge',
    arabic_name: 'فيغا سيجار لاونج',
    rating: 4.9,
    cuisine: 'Lounge Bites',
    arabic_cuisine: 'مقبلات لاونج',
    image_name: 'riyadh-vega-cigar',
    has_michelin: 0,
    description: 'Vega Cigar Lounge offers members and their guests a curated selection of premium cigars and accessories, including rare and limited editions from renowned brands. With its refined atmosphere, luxurious design, and attentive service, the lounge delivers an exceptional and memorable experience.',
    arabic_description: 'يقدّم فيغا سيجار لاونج لأعضائه وضيوفهم مجموعة مختارة من السيجار الفاخر والإكسسوارات، بما في ذلك إصدارات نادرة ومحدودة.',
    city: 'Riyadh',
    arabic_city: 'الرياض'
  },
  {
    name: 'Madeo',
    arabic_name: 'ماديو',
    rating: 4.5,
    cuisine: 'Italian, Pizza',
    arabic_cuisine: 'إيطالي، بيتزا',
    image_name: 'riyadh-madeo',
    has_michelin: 0,
    description: 'Madeo Ristorante is a fine dining destination that has been serving Italian cuisine for over 35 years. Its menu highlights Tuscan specialties, combining fresh local ingredients with premium European products to create a truly exceptional dining experience.',
    arabic_description: 'ماديو ريستورانتي وجهة طعام فاخرة تقدّم المطبخ الإيطالي منذ أكثر من 35 عامًا مع تخصصات توسكانية.',
    city: 'Riyadh',
    arabic_city: 'الرياض'
  },
  {
    name: 'Coya',
    arabic_name: 'كويا',
    rating: 4.5,
    cuisine: 'Peruvian',
    arabic_cuisine: 'بيروفي',
    image_name: 'riyadh-coya',
    has_michelin: 0,
    description: 'COYA is a vibrant destination inspired by Peru, offering exceptional cuisine, creative pisco infusions, and lively cultural experiences. More than a restaurant, it\u2019s an immersive journey into the spirit of Latin America.',
    arabic_description: 'كويا وجهة نابضة بالحياة مستوحاة من بيرو، تقدّم مأكولات استثنائية وتجارب ثقافية حية. أكثر من مطعم، إنها رحلة غامرة.',
    city: 'Riyadh',
    arabic_city: 'الرياض'
  },
  {
    name: 'Gulnaz Khanum',
    arabic_name: 'غولناز خانم',
    rating: 4.8,
    cuisine: 'Persian',
    arabic_cuisine: 'فارسي',
    image_name: 'riyadh-gulnaz',
    has_michelin: 0,
    description: 'A refined Persian dining experience where authentic flavors of Persia blend seamlessly with the warmth and hospitality of Shamieh.',
    arabic_description: 'تجربة طعام فارسية راقية حيث تمتزج نكهات فارس الأصيلة مع دفء وضيافة الشاميّة.',
    city: 'Riyadh',
    arabic_city: 'الرياض'
  },
  {
    name: 'Haret Abu Issam',
    arabic_name: 'حارة أبو عصام',
    rating: 4.5,
    cuisine: 'Syrian, Lebanese',
    arabic_cuisine: 'سوري، لبناني',
    image_name: 'riyadh-haret',
    has_michelin: 0,
    description: 'A Syrian restaurant that brings the spirit of old Damascus to life. Surrounded by authentic details and embraced by genuine Damascene hospitality, Haret Abu Issam offers more than a meal \u2014 here, you experience the story.',
    arabic_description: 'مطعم سوري يُحيي روح دمشق القديمة. محاط بتفاصيل أصيلة وضيافة دمشقية حقيقية، حارة أبو عصام يقدّم أكثر من وجبة.',
    city: 'Riyadh',
    arabic_city: 'الرياض'
  },
  {
    name: 'Signor Sassi',
    arabic_name: 'سينيور ساسي',
    rating: 4.7,
    cuisine: 'Italian',
    arabic_cuisine: 'إيطالي',
    image_name: 'riyadh-signor-sassi',
    has_michelin: 0,
    description: 'Signor Sassi in Riyadh brings the flavors of Italy to the city with a refined menu of classic and modern Italian dishes. Its elegant interior and welcoming atmosphere make every meal a memorable experience.',
    arabic_description: 'يقدّم سينيور ساسي في الرياض نكهات إيطاليا مع قائمة راقية من الأطباق الإيطالية الكلاسيكية والحديثة.',
    city: 'Riyadh',
    arabic_city: 'الرياض'
  },
  // Mecca (5)
  {
    name: 'Alqandeel Restaurant',
    arabic_name: 'مطعم القنديل',
    rating: 4.9,
    cuisine: 'International, Middle Eastern',
    arabic_cuisine: 'عالمي، شرق أوسطي',
    image_name: 'mecca-alqandeel',
    has_michelin: 0,
    description: 'Enjoy contemporary design and a state-of-the-art kitchen at our all-day dining restaurant. Located on the mezzanine level with seating for 302 guests, it offers a diverse food and beverage experience, featuring buffet selections and live cooking stations.',
    arabic_description: 'استمتع بتصميم عصري ومطبخ حديث في مطعمنا المفتوح طوال اليوم. يقع في الطابق الميزانين ويتسع لـ302 ضيف، ويقدّم تجربة طعام متنوعة مع بوفيهات ومحطات طهي حية.',
    city: 'Mecca',
    arabic_city: 'مكة'
  },
  {
    name: 'Prime Restaurant',
    arabic_name: 'مطعم برايم',
    rating: 4.9,
    cuisine: 'Healthy',
    arabic_cuisine: 'صحي',
    image_name: 'mecca-prime',
    has_michelin: 0,
    description: 'Indulge in unforgettable flavors and experience the pinnacle of luxury dining at Conrad Jabal Omar Makkah.',
    arabic_description: 'انغمس في نكهات لا تُنسى واستمتع بقمة الطعام الفاخر في كونراد جبل عمر مكة.',
    city: 'Mecca',
    arabic_city: 'مكة'
  },
  {
    name: 'Sahtein Restaurant',
    arabic_name: 'مطعم صحتين',
    rating: 5.0,
    cuisine: 'Lebanese, Mediterranean',
    arabic_cuisine: 'لبناني، متوسطي',
    image_name: 'mecca-sahtein',
    has_michelin: 0,
    description: 'Sahtein Restaurant in Mecca offers a welcoming dining experience with a diverse menu that blends local favorites and international flavors. Known for its warm hospitality and relaxed atmosphere, it\u2019s a great choice for families and visitors looking to enjoy a satisfying meal in a comfortable setting.',
    arabic_description: 'يقدّم مطعم صحتين في مكة تجربة طعام ترحيبية مع قائمة متنوعة تمزج بين المأكولات المحلية والنكهات العالمية. معروف بضيافته الدافئة وأجوائه المريحة.',
    city: 'Mecca',
    arabic_city: 'مكة'
  },
  {
    name: 'Zafaran Restaurant',
    arabic_name: 'مطعم زعفران',
    rating: 4.9,
    cuisine: 'International, Mediterranean',
    arabic_cuisine: 'عالمي، متوسطي',
    image_name: 'mecca-zafaran',
    has_michelin: 0,
    description: 'At Zafran Restaurant, our all-day dining menu offers a delightful selection for every moment of the day \u2014 from fluffy pancakes and made-to-order omelets to gourmet sandwiches, fresh salads, pasta, and perfectly grilled meats. Whether you\u2019re craving a hearty breakfast at noon or a light dinner in the afternoon, there\u2019s something to satisfy every appetite.',
    arabic_description: 'في مطعم زعفران، تقدّم قائمتنا طوال اليوم مجموعة رائعة لكل لحظة من اليوم — من الفطائر الهشّة والأومليت المحضّر حسب الطلب إلى السندويشات الفاخرة والسلطات الطازجة والباستا واللحوم المشوية.',
    city: 'Mecca',
    arabic_city: 'مكة'
  },
  {
    name: 'Al Shorfa',
    arabic_name: 'الشرفة',
    rating: 4.3,
    cuisine: 'International, Mediterranean',
    arabic_cuisine: 'عالمي، متوسطي',
    image_name: 'mecca-alshorfa',
    has_michelin: 0,
    description: 'Al Shorfa at Conrad Jabal Omar Makkah offers Oriental and international cuisine in a stunning setting overlooking the Holy Kaaba. Located on the 11th-floor terrace, it features panoramic views, freshly prepared dishes, and both \u00E0 la carte and buffet options creating a truly memorable dining experience.',
    arabic_description: 'تقدّم الشرفة في كونراد جبل عمر مكة المأكولات الشرقية والعالمية في إطلالة خلابة على الكعبة المشرفة. تقع في تراس الطابق الحادي عشر مع إطلالات بانورامية.',
    city: 'Mecca',
    arabic_city: 'مكة'
  },
  // AlUla (5)
  {
    name: 'Harrat',
    arabic_name: 'حرّات',
    rating: 4.9,
    cuisine: 'Middle Eastern, Arabic',
    arabic_cuisine: 'شرق أوسطي، عربي',
    image_name: 'alula-harrat',
    has_michelin: 1,
    description: 'From seaside flavors to Middle Eastern mezze, our menu celebrates AlUla\u2019s heritage using seasonal ingredients from local sustainable farms. Perfect for any occasion, from relaxed lunches to lively dinners.',
    arabic_description: 'من نكهات البحر إلى المزة الشرق أوسطية، تحتفي قائمتنا بتراث العلا باستخدام مكونات موسمية من مزارع محلية مستدامة. مثالي لكل مناسبة.',
    city: 'AlUla',
    arabic_city: 'العلا'
  },
  {
    name: 'Somewhere AlUla',
    arabic_name: 'سموير العلا',
    rating: 4.7,
    cuisine: 'Mediterranean, Middle Eastern',
    arabic_cuisine: 'متوسطي، شرق أوسطي',
    image_name: 'alula-somewhere',
    has_michelin: 0,
    description: 'Tucked within AlUla\u2019s lush palms, Somewhere offers a creative Mediterranean-fusion menu designed for sharing. From signature wagyu baos to towering beetroot rice, enjoy a vibrant dining experience set against the stunning backdrop of the Al-Jadidah District.',
    arabic_description: 'يقع بين نخيل العلا الوارفة، ويقدّم قائمة فيوجن متوسطية إبداعية مصممة للمشاركة. من باو الواغيو المميز إلى أرز الشمندر، استمتع بتجربة طعام نابضة بالحيوية.',
    city: 'AlUla',
    arabic_city: 'العلا'
  },
  {
    name: 'Tama Restaurant',
    arabic_name: 'مطعم تاما',
    rating: 4.0,
    cuisine: 'Middle Eastern, Arabic',
    arabic_cuisine: 'شرق أوسطي، عربي',
    image_name: 'alula-tama',
    has_michelin: 0,
    description: 'Experience the \u201Chere and now\u201D at Tama, where ancient history meets contemporary cuisine. We celebrate the region\u2019s flavors by infusing local harvests with spices from the historic Incense Route. Join us for a meal overlooking the infinity pool, perfectly framed by the dramatic landscapes of the Ashar Valley.',
    arabic_description: 'عش تجربة «هنا والآن» في تاما، حيث يلتقي التاريخ العريق بالمطبخ المعاصر. نحتفي بنكهات المنطقة من خلال دمج المحاصيل المحلية مع توابل طريق البخور التاريخي.',
    city: 'AlUla',
    arabic_city: 'العلا'
  },
  {
    name: 'Saffron',
    arabic_name: 'زعفران',
    rating: 4.7,
    cuisine: 'Asian, Thai, Healthy',
    arabic_cuisine: 'آسيوي، تايلندي، صحي',
    image_name: 'alula-saffron',
    has_michelin: 0,
    description: 'Experience Banyan Tree\u2019s signature flavors, where Thai chefs blend traditional soul with contemporary flair. From fragrant lemongrass to rich coconut milk, every dish is a curated work of art perfect for intimate celebrations.',
    arabic_description: 'استمتع بنكهات بانيان تري المميزة، حيث يمزج الطهاة التايلنديون بين الروح التقليدية واللمسة المعاصرة. كل طبق عمل فني مثالي للاحتفالات الحميمة.',
    city: 'AlUla',
    arabic_city: 'العلا'
  },
  {
    name: 'Joontos Restaurant',
    arabic_name: 'مطعم جونتوس',
    rating: 5.0,
    cuisine: 'Spanish, Arabic',
    arabic_cuisine: 'إسباني، عربي',
    image_name: 'alula-joontos',
    has_michelin: 0,
    description: 'Located within the historic Dar Tantora, Joontos celebrates the art of local dining. Led by a Michelin-starred touch, the menu focuses on \u201COasis-to-table\u201D freshness, sourcing ingredients directly from AlUla\u2019s sustainable farms. It\u2019s a soulful culinary journey that honors the traditions of the Old Town while embracing modern refinement.',
    arabic_description: 'يقع في دار طنطورة التاريخية، ويحتفي جونتوس بفن الطعام المحلي. تركّز القائمة على نضارة «من الواحة إلى المائدة» مع مكونات من مزارع العلا المستدامة.',
    city: 'AlUla',
    arabic_city: 'العلا'
  },
  // Southern Provence (4)
  {
    name: 'Le Voyage',
    arabic_name: 'لو فوياج',
    rating: 4.5,
    cuisine: 'French',
    arabic_cuisine: 'فرنسي',
    image_name: 'southern-le-voyage',
    has_michelin: 0,
    description: 'Le Voyage Abha is a fine-dining restaurant in Abha, blending traditional Saudi flavors with contemporary international cuisine. Set in an elegant space with attentive service, it\u2019s perfect for intimate dinners or special occasions, offering fresh, locally sourced dishes and a memorable culinary experience.',
    arabic_description: 'لو فوياج أبها مطعم راقٍ يمزج بين النكهات السعودية التقليدية والمطبخ الدولي المعاصر في أجواء أنيقة وخدمة متميزة.',
    city: 'Southern Provence',
    arabic_city: 'المنطقة الجنوبية'
  },
  {
    name: 'Farfalli',
    arabic_name: 'فارفالي',
    rating: 4.6,
    cuisine: 'Italian',
    arabic_cuisine: 'إيطالي',
    image_name: 'southern-farfalli',
    has_michelin: 0,
    description: 'Farfalli Caf\u00E9 and Restaurant is a family-friendly Italian restaurant and caf\u00E9 located on King Fahd Road in Alarin, Abha, Asir, Saudi Arabia. Known for its warm ambiance and authentic Italian cuisine, the restaurant has become a popular dining destination for residents and visitors seeking classic dishes and relaxed service in a comfortable setting.',
    arabic_description: 'فارفالي مقهى ومطعم إيطالي عائلي يقع على طريق الملك فهد في العرين بأبها. يشتهر بأجوائه الدافئة والمأكولات الإيطالية الأصيلة.',
    city: 'Southern Provence',
    arabic_city: 'المنطقة الجنوبية'
  },
  {
    name: 'Jorry Elite',
    arabic_name: 'جوري إيليت',
    rating: 4.5,
    cuisine: 'International',
    arabic_cuisine: 'عالمي',
    image_name: 'southern-jorry-elite',
    has_michelin: 0,
    description: 'Jorry Elite delivers contemporary fusion dining in a chic, upscale setting. With a menu that spans fresh sushi, sashimi, robata grilled dishes and creative fusion plates, it\u2019s a great spot for elegant dinners, special occasions, or a stylish night out.',
    arabic_description: 'جوري إيليت يقدم تجربة طعام فيوجن معاصرة في أجواء راقية وعصرية. قائمة متنوعة تشمل السوشي والساشيمي والأطباق المشوية المبتكرة.',
    city: 'Southern Provence',
    arabic_city: 'المنطقة الجنوبية'
  },
  {
    name: 'Ala Bali Restaurant',
    arabic_name: 'مطعم على بالي',
    rating: 4.5,
    cuisine: 'International',
    arabic_cuisine: 'عالمي',
    image_name: 'southern-ala-bali',
    has_michelin: 0,
    description: 'Ala Bali Restaurant offers a cozy setting ideal for family and friends, serving a variety of Lebanese and Italian dishes, drinks, and snacks. Guests can relax on the terrace overlooking Abha\u2019s mountains or enjoy the charming indoor balconies for a comfortable, laid-back experience.',
    arabic_description: 'مطعم على بالي يوفر أجواء دافئة مثالية للعائلة والأصدقاء، مع تشكيلة من الأطباق اللبنانية والإيطالية والوجبات الخفيفة.',
    city: 'Southern Provence',
    arabic_city: 'المنطقة الجنوبية'
  }
];

// ─── Activities (26 total) ──────────────────────────────────────────────────
const activities = [
  // Jeddah (7)
  { name: 'Scuba Diving', rating: 4.5, category: 'Free Diving', image_name: 'rectangle10', location: 'Jeddah, Saudi Arabia', description: 'Explore the Red Sea with a professional 5-hour diving experience from Jeddah.', city: 'Jeddah' },
  { name: 'Desert Safari', rating: 4.7, category: '4WD Tours', image_name: 'rectangle8', location: 'Jeddah, Saudi Arabia', description: 'Experience the thrill of a Desert Safari Quad Bike Tour.', city: 'Jeddah' },
  { name: 'Half day Boat Trip', rating: 4.9, category: 'On The Water', image_name: 'rectangle11', location: 'Jeddah, Saudi Arabia', description: "Explore the Red Sea Coast and experience Jeddah's local maritime life.", city: 'Jeddah' },
  { name: 'Full day Private Tour', rating: 4.8, category: 'Private Sightseeing Tour', image_name: 'rectangle12', location: 'Jeddah, Saudi Arabia', description: 'Discover the charm of Jeddah on a private day tour with a local guide.', city: 'Jeddah' },
  { name: 'Historic Tour', rating: 4.8, category: 'Half-Day Tour', image_name: 'rectangle7', location: 'Jeddah, Saudi Arabia', description: "Discover Al-Balad, Jeddah's historic UNESCO World Heritage district.", city: 'Jeddah' },
  { name: 'Moon Mountain Hike', rating: 4.6, category: 'Car Tour', image_name: 'rectangle9', location: 'Jeddah, Saudi Arabia', description: 'Hike through the otherworldly Moon Valley.', city: 'Jeddah' },
  { name: 'Horse Riding', rating: 4.5, category: 'Pack Animal Tour', image_name: 'rectangle13', location: 'Jeddah, Saudi Arabia', description: "Feel the thrill of Jeddah's landscapes on horseback!", city: 'Jeddah' },
  // Riyadh (4)
  { name: 'Luxury Royal Camp', rating: 4.9, category: 'Camping', image_name: 'riyadh-royal-camp', location: 'Riyadh, Saudi Arabia', description: 'A spacious and inviting desert camp for over 150 guests, perfect for family gatherings, events, and special occasions, set in the serene heart of the Red Sands.', city: 'Riyadh' },
  { name: 'Wrangler Safari', rating: 4.7, category: '4WD Tour', image_name: 'riyadh-wrangler-safari', location: 'Riyadh, Saudi Arabia', description: 'Discover the beauty of the Red Sands on a luxury Wrangler safari, led by expert guides who navigate the dunes with skill and confidence. Feel the thrill as you journey across sweeping landscapes, taking in the golden horizons and the raw, untouched charm of the desert in comfort and style.', city: 'Riyadh' },
  { name: 'Camel Riding', rating: 4.5, category: 'Pack Animal Tours', image_name: 'riyadh-camel-riding', location: 'Riyadh, Saudi Arabia', description: 'Experience a traditional Bedouin-style camel ride through breathtaking desert landscapes, where golden dunes stretch endlessly beneath the open sky. Let the gentle rhythm of the camel carry you across the sands as you take in the peaceful beauty and timeless spirit of the desert.', city: 'Riyadh' },
  { name: 'Horse Riding', rating: 4.6, category: 'Pack Animal Tours', image_name: 'riyadh-horse-riding', location: 'Riyadh, Saudi Arabia', description: 'Enjoy a traditional horseback ride across the red dunes, inspired by the proud spirit of Arabian horsemanship. Feel the connection between rider and horse as you journey through sweeping desert landscapes, embracing the grace, strength, and timeless heritage that define this noble tradition.', city: 'Riyadh' },
  // Mecca (5)
  { name: 'A Spiritual Journey', rating: 4.8, category: 'Tours', image_name: 'mecca-spiritual-journey', location: 'Mecca, Saudi Arabia', description: 'Experience a spiritual journey through Makkah, visiting Arafat, Muzdalifah, and Mina, including Jamarat Bridge and Al-Khaif Mosque. Conclude at Jabal al-Nour and Hira Cave, followed by the Revelation Exhibition, a journey of heritage and spirituality.', city: 'Mecca' },
  { name: 'Clock Tower Museum', rating: 4.7, category: 'Museum', image_name: 'mecca-clock-tower', location: 'Mecca, Saudi Arabia', description: "Experience the Makkah Clock Tower Museum, offering stunning views of the Holy Mosque. Perched 480 m above the Grand Mosque in Abraj Al-Bait, the museum takes you on an interactive journey through astronomy, timekeeping, Makkah's history, and the Holy Mosque's development, concluding with a panoramic balcony and telescopes overlooking the Kaaba.", city: 'Mecca' },
  { name: 'Life of the Prophet', rating: 4.9, category: 'Tours', image_name: 'mecca-life-prophet', location: 'Mecca, Saudi Arabia', description: 'Embark on a spiritual and historical journey tracing the footsteps of the Prophet Muhammad, peace be upon him. Begin at Jabal Thawr, descend into the valley of Prophet Ibrahim, and conclude at Jabal al-Nour.', city: 'Mecca' },
  { name: 'Kiswah Factory Tour', rating: 4.8, category: 'Tours', image_name: 'mecca-kiswah-factory', location: 'Mecca, Saudi Arabia', description: "Explore Makkah's rich Islamic heritage on this exclusive tour. Visit the Kiswah Factory exhibition to learn about the history and significance of the Kaaba's sacred covering through an informative documentary. Then, visit the historic Al Hudaibiya, site of the pivotal Treaty of Hudaibiya, and discover its ruins and spiritual significance. A knowledgeable guide brings the history of these iconic locations to life.", city: 'Mecca' },
  { name: 'Discover Hira Tour', rating: 4.6, category: 'Tours', image_name: 'mecca-hira-tour', location: 'Mecca, Saudi Arabia', description: 'Today, explore the Hira district in Makkah, beginning with the Revelation Exhibition Prophet Muhammad (SAW). Next, visit the Museum of the Holy Quran\'s impact. The tour concludes with a climb to Jabal al-Nour and the blessed Cave of Hira, offering breathtaking views and deep spiritual significance, before returning to the hotel.', city: 'Mecca' },
  // AlUla (5)
  { name: 'Hegra Day Tour', rating: 4.9, category: 'Tours', image_name: 'alula-hegra-tour', location: 'AlUla, Saudi Arabia', description: "Step into the past at Saudi Arabia's premier UNESCO site. Guided by local Rawis, you'll discover the majestic tombs and sacred halls of the Nabataean civilization. An immersive, storytelling-led tour featuring AlUla's most iconic landmarks, including the monumental Qasr Al-Farid.", city: 'AlUla' },
  { name: 'Gharameel Stargazing', rating: 4.8, category: 'Nature and Outdoors', image_name: 'alula-gharameel-stargazing', location: 'AlUla, Saudi Arabia', description: 'Escape to Gharameel for a breathtaking view of the Milky Way, framed by ancient rock formations and zero light pollution. Whether you\'re exploring the landscape by moonlight or tracking constellations on darker nights, the experience concludes with a traditional grilled dinner around a warm campfire.', city: 'AlUla' },
  { name: 'Madakhel Garden Hike', rating: 4.7, category: 'Adventure', image_name: 'alula-madakhel-hike', location: 'AlUla, Saudi Arabia', description: 'Hike through the shaded trails of Shaaran Nature Reserve, a paradise of diverse wildlife and striking geology. Discover the beauty of the canyon as you trek beneath a lush green canopy framed by towering sandstone walls.', city: 'AlUla' },
  { name: 'Wheels Bike Hub', rating: 4.6, category: 'Adventure', image_name: 'alula-wheels-bike', location: 'AlUla, Saudi Arabia', description: 'Rent a bike at Wheels Bike Hub and hit the scenic 26km path from AlAtheeb to Hegra. Whether you need a quick 30-minute ride or a 2-hour adventure, we provide rentals, road assistance, and expert servicing. Finish your journey at our Bike Hub Cafe with a fresh juice or coffee.', city: 'AlUla' },
  { name: 'Archaeology Tour', rating: 4.8, category: 'Tour', image_name: 'alula-archaeology-tour', location: 'AlUla, Saudi Arabia', description: 'Join an expert-led journey to explore hidden sites and live excavations not yet open to the public. This premium experience features vintage Land Rover tours, professional archaeological insights, and a gourmet lunch in the Oasis.', city: 'AlUla' },
  // Southern Provence (5)
  { name: 'Historical Tour', rating: 4.9, category: 'Tours', image_name: 'southern-historical-tour', location: 'Alsoudah, Saudi Arabia', description: 'Explore the 900-year-old Rijal Almaa Village near Abha on a small-group tour with included transportation. Enjoy a day of hiking, sightseeing, and local dining while discovering the rich heritage of Saudi Arabia.', city: 'Southern Provence' },
  { name: 'Trip to Hima Wells', rating: 4.8, category: 'Trips', image_name: 'southern-hima-wells', location: 'Najran, Saudi Arabia', description: "Join a day tour to explore Al-Ukhdood Archaeological City, an ancient Himyarite site with ruins and inscriptions, then visit Hima Wells, a UNESCO site famous for historic water sources and rock carvings. Guided by local experts, this tour offers an authentic and meaningful journey through southern Arabia\u2019s history and culture.", city: 'Southern Provence' },
  { name: 'Coffee Plantation Tour', rating: 4.7, category: 'Tours', image_name: 'southern-coffee-plantation', location: 'Abha, Saudi Arabia', description: 'Experience a local coffee plantation with farmers and discover how coffee shapes southern culture. Then enjoy an off-road adventure through the mountains to the highest peak of the Black Mountain.', city: 'Southern Provence' },
  { name: 'Soudah Hiking', rating: 4.8, category: 'Adventures', image_name: 'southern-soudah-hiking', location: 'Abha, Saudi Arabia', description: "Hike an optional 8 km trail at 3,000 m above sea level in Abha\u2019s Sawda Mountains. This 250-year-old path winds to the mountain base, surrounded by lush, perennial juniper trees, a symbol of the region.", city: 'Southern Provence' },
  { name: 'Fatima Museum', rating: 4.6, category: 'Museum', image_name: 'southern-fatima-museum', location: 'Abha, Saudi Arabia', description: "The Fatima Museum showcases the rich cultural heritage of Saudi Arabia through a curated collection of traditional artifacts, clothing, crafts, and historical exhibits. Visitors can explore the country\u2019s history, customs, and artistic traditions in an engaging and educational environment that celebrates Saudi heritage.", city: 'Southern Provence' }
];

// ─── Season Events (19 total) ───────────────────────────────────────────────
const seasonEvents = [
  // Jeddah (6)
  { name: 'Winter Wonderland', category: 'Seasonal Attraction', image_name: 'season-winter-wonderland', location: 'Jeddah, Saudi Arabia', description: 'Step into a magical winter experience in the heart of Jeddah. Winter Wonderland brings snow, festive lights, rides, and live entertainment for the whole family. A seasonal must-visit with food stalls, games, and unforgettable holiday vibes.', city: 'Jeddah' },
  { name: 'Balad Beast', category: 'Live music', image_name: 'season-balad-beast', location: 'Jeddah, Saudi Arabia', description: "Experience the ultimate music festival in Jeddah's historic Al-Balad district. Balad Beast features international and regional artists, electrifying performances, and an unforgettable atmosphere under the stars.", city: 'Jeddah' },
  { name: 'The Snow Dome', category: 'Seasonal Attraction', image_name: 'season-snow-dome', location: 'Jeddah, Saudi Arabia', description: 'Escape the heat and enjoy real snow in Jeddah! The Snow Dome offers snow tubing, ice slides, snowball fights, and a winter wonderland atmosphere perfect for families and friends.', city: 'Jeddah' },
  { name: 'Ice Rink', category: 'Seasonal Attraction', image_name: 'season-ice-rink', location: 'Jeddah, Saudi Arabia', description: "Glide across the ice at Jeddah's premier seasonal ice rink. Perfect for beginners and experienced skaters alike, with professional instructors, music, and a festive atmosphere.", city: 'Jeddah' },
  { name: 'Tropical Land', category: 'Adventure', image_name: 'season-tropical-land', location: 'Jeddah, Saudi Arabia', description: 'Dive into a tropical adventure with water rides, jungle-themed attractions, and exotic experiences. Tropical Land is the ultimate destination for thrill-seekers and families looking for fun.', city: 'Jeddah' },
  { name: 'Notat Watar', category: 'Karaoke', image_name: 'season-notat-watar', location: 'Jeddah, Saudi Arabia', description: "Sing your heart out at Notat Watar, Jeddah's premier karaoke and live music venue. Enjoy an evening of Arabic and international hits in a vibrant, social atmosphere.", city: 'Jeddah' },
  // Riyadh (4)
  { name: 'Almasar', category: 'Seasonal Attraction', image_name: 'riyadh-almasar', location: 'Riyadh, Saudi Arabia', description: 'Celebrate Ramadan at the elegant Almasar Ramadan Tent at Sports Boulevard \u2013 Arts Tower (Almasar). A warm and refined setting for Iftar and Suhoor, perfect for families, friends, and corporate gatherings, with curated dining and bespoke menu options available upon request.', city: 'Riyadh' },
  { name: 'VUZ Dome \u2013 Immersive Cinema', category: 'Cinema', image_name: 'riyadh-dome-cinema', location: 'Riyadh, Saudi Arabia', description: 'VUZ Dome takes you to another world with a fully immersive 360\u00B0 cinema experience. With a Premium Ticket, enjoy comfortable seating and choose from magical animations, thrilling adventures, and breathtaking documentaries. Book now and feel the thrill from every angle.', city: 'Riyadh' },
  { name: 'Layali Al-Diriyah', category: 'Seasonal Attraction', image_name: 'riyadh-layali-diriyah', location: 'Riyadh, Saudi Arabia', description: 'In the historic Al-Murayih district, Layali Al-Diriyah shines with global flavors and refined ambiance that blend tradition and modernity. Enjoy exclusive dining, live performances, and a vibrant celebration of Saudi hospitality in the heart of Diriyah.', city: 'Riyadh' },
  { name: 'Khemah The Groves', category: 'Seasonal Attraction', image_name: 'riyadh-khemah-groves', location: 'Riyadh, Saudi Arabia', description: 'From the first call to Iftar to the calm of Sahoor, Khemah The Groves Village invites you to live buffet cottages surrounded by nature and inspired by Saudi heritage. Enjoy indoor and outdoor seating with a relaxed Kashta-style Iftar, perfect for memorable Ramadan gatherings.', city: 'Riyadh' },
  // Mecca (1)
  { name: 'Mirkaz', category: 'Seasonal Attraction', image_name: 'mecca-mirkaz', location: 'Mecca, Saudi Arabia', description: 'Celebrate Ramadan at the elegant Merkaz Albalad Almeen. A warm and refined setting for Iftar and Suhoor, perfect for families, friends, and corporate gatherings, with curated dining and bespoke menu options available upon request.', city: 'Mecca' },
  // AlUla (6)
  { name: 'AlUla Skyrise', category: 'Seasonal Attraction', image_name: 'alula-skyrise', location: 'AlUla, Saudi Arabia', description: 'Join AlUla Skyrise for a breathtaking mass ballooning event featuring 30 balloons rising together. Guests enjoy door-to-door luxury transfers from select 4- and 5-star hotels and pre-flight refreshments. Once airborne, spend an hour soaking in 360-degree views of the historic landscape before a smooth return to your starting point.', city: 'AlUla' },
  { name: 'Balloon Glow Show', category: 'Seasonal Attraction', image_name: 'alula-balloon-glow', location: 'AlUla, Saudi Arabia', description: 'Experience a spectacular fusion of light, music, and motion at the Hot Air Balloon Glow Show. Watch as 12 balloons glow in perfect choreography, accompanied by acrobats and stunning projections. With live DJ sets and local food stalls, it\'s a full-sensory evening for the whole family.', city: 'AlUla' },
  { name: 'AlUla Desert Blaze', category: 'Seasonal Attraction', image_name: 'alula-desert-blaze', location: 'AlUla, Saudi Arabia', description: "Desert Blaze 2025 challenged runners to conquer AlUla's summer terrain across four intense distances. From premium race kits to the vibrant finish line, it was a true journey of endurance. Coming back in 2026\u2014stay updated via the Experience AlUla app and our social channels to secure your spot.", city: 'AlUla' },
  { name: 'Tethered Hot Air Balloon', category: 'Seasonal Attraction', image_name: 'alula-tethered-balloon', location: 'AlUla, Saudi Arabia', description: "Take to the skies with the Tethered Hot Air Balloon Experience. Ascend 50 meters above Al Manshiyah Plaza for 20 minutes of breathtaking, 360-degree views. It's the perfect way to witness AlUla's unique landscape from a new perspective while staying safely moored.", city: 'AlUla' },
  { name: 'Skies Festival Concert', category: 'Seasonal Attraction', image_name: 'alula-skies-concert', location: 'AlUla, Saudi Arabia', description: "Join us at Thanaya for an unforgettable evening as Arabic pop icon Nancy Ajram takes the stage under AlUla's starlit sky. Set against a backdrop of dramatic desert landscapes, this AlUla Skies Festival performance promises a vibrant night of music, emotion, and celebration with one of the region's most beloved stars.", city: 'AlUla' },
  { name: 'Incense Road Journey', category: 'Seasonal Attraction', image_name: 'alula-incense-road', location: 'AlUla, Saudi Arabia', description: "Winner of Best Arts & Culture Event at the 2025 Saudi Events Awards, this two-hour journey brings AlUla's mud-brick history to life. Through live performances and cutting-edge tech, you'll uncover the secrets and living memories of the desert's ancient communities.", city: 'AlUla' },
  // Southern Provence (2)
  { name: 'Wasal Festival', category: 'Seasonal Attraction', image_name: 'southern-wasal-festival', location: 'Abha, Saudi Arabia', description: 'A vibrant food festival celebrating the rich flavors of Asir heritage, featuring traditional dishes and authentic local cuisine. Held in Al-Meftaha district in Abha, the festival offers visitors a true taste of Asiri culture in a lively and welcoming atmosphere.', city: 'Southern Provence' },
  { name: 'Al-Masqi Heritage Village', category: 'Seasonal Attraction', image_name: 'southern-masqi-village', location: 'Abha, Saudi Arabia', description: 'A cultural destination featuring traditional folk performances, handcrafted arts, and an authentic heritage atmosphere that beautifully reflects the history and traditions of the region.', city: 'Southern Provence' }
];

// ─── Sample Users ───────────────────────────────────────────────────────────
const sampleUsers = [
  { phone: '+966559035417' },
  { phone: '+966588762140' },
  { phone: '+966500111222' }
];

// ─── Sample Bookings (5 total: 2 pending, 2 approved, 1 rejected) ──────────
const sampleBookings = [
  {
    ticket_code: '11223344556677',
    user_id: 1,
    place_title: 'Myazu Restaurant',
    subtitle: 'Japanese, Sushi',
    image_name: 'restaurant-myazu',
    date_display: 'Jan 3',
    time_display: '8:00PM',
    branch: 'Albasateen Mall, Alrawdha',
    qr_payload: 'MRASEM|11223344556677|Myazu Restaurant',
    event_date: '2025-01-03',
    status: 'pending',
    uses_fork_subtitle_icon: 1
  },
  {
    ticket_code: '22334455667788',
    user_id: 2,
    place_title: 'Scuba Diving',
    subtitle: 'Free Diving',
    image_name: 'rectangle10',
    date_display: 'Jan 10',
    time_display: '10:00AM',
    branch: 'Red Sea Marina',
    qr_payload: 'MRASEM|22334455667788|Scuba Diving',
    event_date: '2025-01-10',
    status: 'approved',
    uses_fork_subtitle_icon: 0
  },
  {
    ticket_code: '33445566778899',
    user_id: 1,
    place_title: 'Winter Wonderland',
    subtitle: 'Seasonal Attraction',
    image_name: 'season-winter-wonderland',
    date_display: 'Feb 14',
    time_display: '6:00PM',
    branch: 'Jeddah Waterfront',
    qr_payload: 'MRASEM|33445566778899|Winter Wonderland',
    event_date: '2025-02-14',
    status: 'approved',
    uses_fork_subtitle_icon: 0
  },
  {
    ticket_code: '44556677889900',
    user_id: 3,
    place_title: 'Le Vesuvio',
    subtitle: 'Italian, Pizza',
    image_name: 'restaurant-le-vesuvio',
    date_display: 'Mar 1',
    time_display: '7:30PM',
    branch: 'Jeddah Yacht Club & Marina',
    qr_payload: 'MRASEM|44556677889900|Le Vesuvio',
    event_date: '2025-03-01',
    status: 'rejected',
    uses_fork_subtitle_icon: 1
  },
  {
    ticket_code: '55667788990011',
    user_id: 2,
    place_title: 'Hegra Day Tour',
    subtitle: 'Tours',
    image_name: 'alula-hegra-tour',
    date_display: 'Mar 15',
    time_display: '9:00AM',
    branch: 'AlUla Visitor Center',
    qr_payload: 'MRASEM|55667788990011|Hegra Day Tour',
    event_date: '2025-03-15',
    status: 'pending',
    uses_fork_subtitle_icon: 0
  }
];

// ─── Sample Sent Invitations (3: pending, accepted, declined) ───────────────
const sampleSentInvitations = [
  {
    id: 'sent-inv-001',
    outcome: 'pending',
    place_title: 'Myazu Restaurant',
    subtitle: 'Japanese, Sushi',
    image_name: 'restaurant-myazu',
    date_display: 'Jan 3',
    time_display: '8:00PM',
    branch: 'Albasateen Mall, Alrawdha',
    recipient_phone: '+966588762140'
  },
  {
    id: 'sent-inv-002',
    outcome: 'accepted',
    place_title: 'Myazu Restaurant',
    subtitle: 'Japanese, Sushi',
    image_name: 'restaurant-myazu',
    date_display: 'Jan 3',
    time_display: '8:00PM',
    branch: 'Albasateen Mall, Alrawdha',
    recipient_phone: '+966500111222'
  },
  {
    id: 'sent-inv-003',
    outcome: 'declined',
    place_title: 'Myazu Restaurant',
    subtitle: 'Japanese, Sushi',
    image_name: 'restaurant-myazu',
    date_display: 'Jan 3',
    time_display: '8:00PM',
    branch: 'Albasateen Mall, Alrawdha',
    recipient_phone: '+966500333444'
  }
];

// ─── Sample Received Invitations (1: awaiting) ─────────────────────────────
const sampleReceivedInvitations = [
  {
    id: 'recv-inv-001',
    user_response: 'awaiting',
    place_title: 'Khemah The Groves',
    subtitle: 'Outdoor dining',
    image_name: 'riyadh-khemah-groves',
    date_display: 'Feb 12',
    time_display: '7:00PM',
    branch: 'Riyadh Park',
    inviter_phone: '+966555010203'
  }
];

// ─── Seed Function ──────────────────────────────────────────────────────────
function seedDatabase(db) {
  // Only seed if tables are empty
  const adminCount = db.prepare('SELECT COUNT(*) as count FROM admin_users').get().count;
  if (adminCount > 0) return;

  // Admin user
  db.prepare('INSERT INTO admin_users (email, password_hash) VALUES (?, ?)').run(
    'admin@mrasem.com',
    adminPasswordHash
  );

  // Restaurants
  const insertRestaurant = db.prepare(`
    INSERT INTO restaurants (name, arabic_name, rating, cuisine, arabic_cuisine, image_name, has_michelin, description, arabic_description, city, arabic_city)
    VALUES (@name, @arabic_name, @rating, @cuisine, @arabic_cuisine, @image_name, @has_michelin, @description, @arabic_description, @city, @arabic_city)
  `);
  for (const r of restaurants) {
    insertRestaurant.run(r);
  }

  // Activities
  const insertActivity = db.prepare(`
    INSERT INTO activities (name, rating, category, image_name, location, description, city)
    VALUES (@name, @rating, @category, @image_name, @location, @description, @city)
  `);
  for (const a of activities) {
    insertActivity.run(a);
  }

  // Season Events
  const insertSeasonEvent = db.prepare(`
    INSERT INTO season_events (name, category, image_name, location, description, city)
    VALUES (@name, @category, @image_name, @location, @description, @city)
  `);
  for (const e of seasonEvents) {
    insertSeasonEvent.run(e);
  }

  // Users
  const insertUser = db.prepare('INSERT INTO users (phone) VALUES (@phone)');
  for (const u of sampleUsers) {
    insertUser.run(u);
  }

  // Bookings
  const insertBooking = db.prepare(`
    INSERT INTO bookings (ticket_code, user_id, place_title, subtitle, image_name, date_display, time_display, branch, qr_payload, event_date, status, uses_fork_subtitle_icon)
    VALUES (@ticket_code, @user_id, @place_title, @subtitle, @image_name, @date_display, @time_display, @branch, @qr_payload, @event_date, @status, @uses_fork_subtitle_icon)
  `);
  for (const b of sampleBookings) {
    insertBooking.run(b);
  }

  // Sent Invitations
  const insertSentInv = db.prepare(`
    INSERT INTO sent_invitations (id, outcome, place_title, subtitle, image_name, date_display, time_display, branch, recipient_phone)
    VALUES (@id, @outcome, @place_title, @subtitle, @image_name, @date_display, @time_display, @branch, @recipient_phone)
  `);
  for (const s of sampleSentInvitations) {
    insertSentInv.run(s);
  }

  // Received Invitations
  const insertRecvInv = db.prepare(`
    INSERT INTO received_invitations (id, user_response, place_title, subtitle, image_name, date_display, time_display, branch, inviter_phone)
    VALUES (@id, @user_response, @place_title, @subtitle, @image_name, @date_display, @time_display, @branch, @inviter_phone)
  `);
  for (const r of sampleReceivedInvitations) {
    insertRecvInv.run(r);
  }
}

module.exports = {
  restaurants,
  activities,
  seasonEvents,
  sampleUsers,
  sampleBookings,
  sampleSentInvitations,
  sampleReceivedInvitations,
  seedDatabase
};
