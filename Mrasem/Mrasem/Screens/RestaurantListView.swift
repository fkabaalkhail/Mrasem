import SwiftUI

struct RestaurantListView: View {
    @EnvironmentObject private var languageManager: LanguageManager
    @State private var isFavorite: Set<String> = []
    
    let restaurants = [
        Restaurant(
            name: "Le Vesuvio",
            arabicName: "لي فيزوفيو",
            rating: 4.5,
            cuisine: "Italian, Pizza",
            arabicCuisine: "إيطالي، بيتزا",
            imageName: "restaurant-le-vesuvio",
            hasMichelin: false,
            description: "Le Vesuvio offers authentic Italian dining by the waterfront at Jeddah Yacht Club & Marina. Enjoy wood fired pizzas, handmade pastas, and fresh seafood in a modern, elegant setting with stunning marina views. A perfect spot for date nights, gatherings, or a refined evening by the sea.",
            arabicDescription: """
            يقدّم لي فيزوفيو تجربة طعام إيطالية أصيلة على الواجهة البحرية في مرسى ونادي اليخوت بجدة. استمتعوا ببيتزا الحطب، والباستا المصنوعة يدويًا، والمأكولات البحرية الطازجة في أجواء عصرية راقية وإطلالة خلابة على المرسى. المكان المثالي لسهرة راقية، أو موعد عشاء، أو تجمع مميز بجانب البحر.
            """
        ),
        Restaurant(
            name: "ROKA",
            arabicName: "روكا",
            rating: 4.6,
            cuisine: "Japanese",
            arabicCuisine: "ياباني",
            imageName: "restaurant-roka",
            hasMichelin: false,
            description: "ROKA Jeddah brings modern Japanese robatayaki dining to a sleek, contemporary space at Jeddah Walk. The menu features signature grilled dishes, sushi, and bold Japanese flavors, all served in a vibrant, upscale atmosphere perfect for dinners, celebrations, or a stylish night out.",
            arabicDescription: """
            يقدّم ROKA جدة تجربة "روبتاياكي" يابانية عصرية في مساحة أنيقة وحديثة في ممشى جدة. تتضمن القائمة أطباقهم المشوية المميزة، والسوشي، ونكهات يابانية جريئة، جميعها تُقدَّم في أجواء راقية نابضة بالحيوية—مثالية للعشاء، والاحتفالات، أو لقضاء سهرة أنيقة.
            """
        ),
        Restaurant(
            name: "Myazu",
            arabicName: "ميازو",
            rating: 4.5,
            cuisine: "Japanese, Sushi",
            arabicCuisine: "ياباني، سوشي",
            imageName: "restaurant-myazu",
            hasMichelin: true,
            description: "Myazu Jeddah delivers contemporary Japanese fusion dining in a chic, upscale setting. With a menu that spans fresh sushi, sashimi, robata grilled dishes and creative fusion plates, it's a great spot for elegant dinners, special occasions, or a stylish night out.",
            arabicDescription: """
            ميازو يقدّم تجربة طعام يابانية عصرية في أجواء راقية وأنيقة. تشمل قائمته السوشي والساشيمي الطازج، وأطباق الروباتا المشوية، وأطباق يابانية مبتكرة، مما يجعله مكانًا مثاليًا لعشاء فاخر، أو المناسبات الخاصة، أو سهرة أنيقة.
            """
        ),
        Restaurant(
            name: "Pampas",
            arabicName: "بامباز",
            rating: 4.9,
            cuisine: "Latin, Barbecue",
            arabicCuisine: "لاتيني، باربيكيو",
            imageName: "restaurant-pampas",
            hasMichelin: false,
            description: "Pampas offers an authentic South American dining experience with a focus on premium grilled meats and bold Argentine flavors. Set in an elegant, warm atmosphere, it's perfect for steak lovers, celebratory dinners, or anyone looking for a refined Latin inspired night out.",
            arabicDescription: """
            يقدّم بامباس تجربة طعام لاتينية جنوبية أصيلة تركّز على اللحوم المشوية الفاخرة ونكهات الأرجنتين القوية. يتميز بأجواء أنيقة ودافئة، مما يجعله خيارًا مثاليًا لعشّاق الستيك، ولعشاء احتفالي، أو لأي شخص يبحث عن سهرة راقية مستوحاة من المطبخ اللاتيني.
            """
        ),
        Restaurant(
            name: "Rasoi by Vineet",
            arabicName: "راسوي باي فينيت",
            rating: 4.9,
            cuisine: "Indian, Asian",
            arabicCuisine: "هندي، آسيوي",
            imageName: "restaurant-rasoi",
            hasMichelin: true,
            description: "Rasoi by Vineet brings modern Indian fine dining to Jeddah, led by Michelin starred chef Vineet Bhatia. The restaurant blends bold Indian flavors with contemporary presentation, offering creative curries, tandoor specialties, and elegant appetizers in a refined, luxurious setting perfect for special occasions.",
            arabicDescription: """
            يقدّم راسوي باي فينيت تجربة طعام هندية راقية بطابع حديث في جدة، تحت إشراف الشيف الحاصل على نجمة ميشلان فينيت باتيا. يجمع المطعم بين النكهات الهندية القوية والعرض العصري للأطباق، مع توليفة من الكاري الإبداعي، وتخصصات التندور، والمقبلات الأنيقة في أجواء فاخرة وراقية مثالية للمناسبات الخاصة.
            """
        ),
        Restaurant(
            name: "Kuuru",
            arabicName: "كورو",
            rating: 4.5,
            cuisine: "Japanese",
            arabicCuisine: "ياباني",
            imageName: "restaurant-kuuru",
            hasMichelin: false,
            description: "Kuuru in Jeddah offers refined Japanese-fusion dining in a chic, contemporary setting. Expect artfully prepared sushi, sashimi, and fusion dishes, served in a stylish ambiance ideal for elegant dinners, relaxed nights out, or special occasions.",
            arabicDescription: """
            يقدّم كورو جدة تجربة طعام يابانية فاخرة بلمسة فيوجن عصرية، في أجواء أنيقة وحديثة. يتوقع الزوّار سوشي وساشيمي مُحضّر بعناية، وأطباق فيوجن مبتكرة، تُقدَّم في بيئة راقية مثالية لعشاء أنيق، أو سهرة هادئة، أو مناسبة خاصة.
            """
        ),
        Restaurant(
            name: "Shang Palace",
            arabicName: "قصر شانق",
            rating: 4.8,
            cuisine: "Chinese",
            arabicCuisine: "صيني",
            imageName: "restaurant-shang",
            hasMichelin: false,
            description: "Shang Palace brings authentic Cantonese fine dining to Jeddah with elegant interiors, traditional flavors, and refined presentation. The menu features handcrafted dim sum, signature roasted dishes, and classic Cantonese specialties, making it a perfect spot for upscale family dinners, celebrations, or a premium Chinese dining experience.",
            arabicDescription: """
            يقدّم قصر شانق تجربة طعام كانتونية راقية وأصيلة في جدة، مع ديكورات أنيقة ونكهات تقليدية وتقديم متقن للأطباق. تشمل القائمة ديم سام محضّر يدويًا، وأطباقهم المشوية المميزة، وتخصصات كانتونية كلاسيكية، مما يجعله مكانًا مثاليًا لعشاء عائلي فاخر، أو الاحتفالات، أو تجربة طعام صينية راقية.
            """
        ),
        Restaurant(
            name: "Lucky Llama",
            arabicName: "ذا لاكي لاما",
            rating: 4.5,
            cuisine: "Latin, Japanese",
            arabicCuisine: "لاتيني، ياباني",
            imageName: "restaurant-lucky",
            hasMichelin: false,
            description: "The Lucky Llama offers vibrant Nikkei cuisine, blending Peruvian flavors with Japanese techniques. Enjoy ceviche, tiradito, and creative sushi in a lively, stylish setting perfect for casual dinners, date nights, or flavorful nights out.",
            arabicDescription: """
            يقدّم ذا لاكي لاما مطبخ نيكّي النابض بالحياة، الذي يمزج بين النكهات البيروفية والتقنيات اليابانية. استمتع بالسيفيشه، والتيراديتو، والسوشي الإبداعي في أجواء حيوية وأنيقة مثالية لعشاء غير رسمي، أو موعد، أو سهرة مليئة بالنكهات.
            """
        ),
        Restaurant(
            name: "MANIKO",
            arabicName: "مانكو",
            rating: 4.7,
            cuisine: "Peruvian, Asian",
            arabicCuisine: "بيرو، آسيوي",
            imageName: "restaurant-maniko",
            hasMichelin: false,
            description: "Manko Jeddah brings bold Peruvian‑fusion flavors to a stylish, modern setting. Enjoy ceviches, grilled steaks, seafood, sushi‑inspired bites, and inventive small plates, all crafted for sharing. Perfect for casual dinners, nights out with friends, or special occasions.",
            arabicDescription: """
            يقدّم مانكو جدة نكهات بيروفية مبتكرة وجريئة في أجواء عصرية وأنيقة. استمتع بالسيفيشه، والستيكات المشوية، والمأكولات البحرية، وقطع السوشي، وأطباق صغيرة مبتكرة—all مصممة للمشاركة. المكان مثالي لعشاء غير رسمي، أو سهرة مع الأصدقاء، أو مناسبات خاصة.
            """
        ),
        Restaurant(
            name: "Niyyali",
            arabicName: "نيّالي",
            rating: 4.7,
            cuisine: "Lebanese",
            arabicCuisine: "لبناني",
            imageName: "restaurant-niyyali",
            hasMichelin: false,
            description: "Niyyali blends authentic Lebanese cuisine with modern elegance at Shangri La Jeddah, offering mezze, grilled dishes, and rich Levant‑style flavors in a stylish setting by the sea. With indoor dining or a terrace overlooking the Red Sea and the Corniche Circuit, it's ideal for cozy dinners, celebrations, or a vibrant night out.",
            arabicDescription: """
            يقدّم نيّالي تجربة طعام لبنانية أصيلة ممزوجة بالأناقة العصرية في شانغريلا جدة، مع مقبلات مميزة، أطباق مشوية، ونكهات شامية غنية في أجواء أنيقة على البحر. يوفّر المطعم تناول الطعام داخليًا أو على التراس المطل على البحر الأحمر وكورنيش جدة، مما يجعله مثاليًا لعشاء دافئ، أو الاحتفالات، أو سهرة حيوية.
            """
        )
    ]
    
    private let brandBrown = Color(red: 0x31 / 255.0, green: 0x23 / 255.0, blue: 0x1B / 255.0)

    private var topRow: [Restaurant] {
        Array(restaurants.enumerated().filter { $0.offset % 2 == 0 }.map { $0.element })
    }
    
    private var bottomRow: [Restaurant] {
        Array(restaurants.enumerated().filter { $0.offset % 2 == 1 }.map { $0.element })
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.95, green: 0.95, blue: 0.95)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Top brown header with profile + search
                    ZStack(alignment: .top) {
                        brandBrown
                            .ignoresSafeArea(edges: .top)
                            .frame(height: 250)
                        
                        VStack(spacing: 0) {
                            // Profile section
                            HStack(spacing: 8) {
                                if languageManager.current == .arabic {
                                    Button(action: {}) {
                                        Image("menu-icon")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 20)
                                    }
                                    Spacer()
                                    Text("أهلا عبدالله!")
                                        .font(.custom("ExpoArabic-Medium", size: 12))
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    ZStack {
                                        Image("profile-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 42, height: 42)
                                        Image("nav-profile").resizable().aspectRatio(contentMode: .fit).frame(width: 38, height: 38)
                                        Image("layer2").resizable().aspectRatio(contentMode: .fit).frame(width: 36, height: 36)
                                    }
                                } else {
                                    ZStack {
                                        Image("profile-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 42, height: 42)
                                        Image("nav-profile").resizable().aspectRatio(contentMode: .fit).frame(width: 38, height: 38)
                                        Image("layer2").resizable().aspectRatio(contentMode: .fit).frame(width: 36, height: 36)
                                    }
                                    Text("Hi Abdullah")
                                        .font(.custom("ExpoArabic-Medium", size: 12))
                                        .fontWeight(.medium)
                                        .foregroundColor(.white)
                                    Spacer()
                                    Button(action: {}) {
                                        Image("menu-icon")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 24, height: 20)
                                    }
                                }
                            }
                            .padding(.horizontal, 24)
                            .padding(.top, 45)
                            
                            // Search bar
                            HStack {
                                if languageManager.current == .arabic {
                                    Text("ابحث")
                                        .font(.custom("ExpoArabic-Medium", size: 12))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(red: 0xC4 / 255.0, green: 0xC4 / 255.0, blue: 0xC4 / 255.0))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                    Image("search-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 14, height: 14)
                                } else {
                                    Image("search-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 14, height: 14)
                                    Text("Search")
                                        .font(.custom("ExpoArabic-Medium", size: 12))
                                        .fontWeight(.medium)
                                        .foregroundColor(Color(red: 0xC4 / 255.0, green: 0xC4 / 255.0, blue: 0xC4 / 255.0))
                                    Spacer()
                                }
                            }
                            .padding(.horizontal, 15)
                            .frame(width: 327, height: 43)
                            .background(Color.white)
                            .cornerRadius(9)
                            .padding(.top, 14)
                        }
                    }
                    
                    // 2-row restaurant grid (horizontal scroll)
                    ScrollView(.horizontal, showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack(spacing: 16) {
                                ForEach(topRow) { restaurant in
                                    NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                                        GridRestaurantCard(restaurant: restaurant, isArabic: languageManager.current == .arabic)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            HStack(spacing: 16) {
                                ForEach(bottomRow) { restaurant in
                                    NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                                        GridRestaurantCard(restaurant: restaurant, isArabic: languageManager.current == .arabic)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                        }
                        .padding(.horizontal, 21)
                        .padding(.vertical, 16)
                    }
                    .environment(\.layoutDirection, languageManager.current == .arabic ? .rightToLeft : .leftToRight)
                    .padding(.top, -75)
                    
                    // "Nearby Restaurants" section
                    Text(languageManager.current == .arabic ? "مطاعم قريبة" : "Nearby Restaurants")
                        .font(.custom("ExpoArabic-Medium", size: 20))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: languageManager.current == .arabic ? .trailing : .leading)
                        .padding(.horizontal, 21)
                        .padding(.top, 3)
                    
                    // Nearby restaurants horizontal scroll
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(restaurants.prefix(4)) { restaurant in
                                NearbyRestaurantCard(
                                    restaurant: restaurant,
                                    isArabic: languageManager.current == .arabic
                                )
                            }
                        }
                        .padding(.horizontal, 21)
                        .padding(.top, 12)
                    }
                    .environment(\.layoutDirection, languageManager.current == .arabic ? .rightToLeft : .leftToRight)
                    
                    Spacer()
                    
                    // Bottom navigation bar — brown #31231B, 5 icons per Figma
                    ZStack {
                        brandBrown
                            .ignoresSafeArea(edges: .bottom)
                        
                        HStack(spacing: 0) {
                            Spacer()
                            
                            NavigationLink(destination: CategorySelectionView()) {
                                Image("nav-icon-home")
                                    .resizable()
                                    .renderingMode(.original)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 22)
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image("nav-icon-calendar")
                                    .resizable()
                                    .renderingMode(.original)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 21, height: 21)
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image("nav-icon-grid")
                                    .resizable()
                                    .renderingMode(.original)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image("nav-icon-ticket")
                                    .resizable()
                                    .renderingMode(.original)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 23, height: 18)
                            }
                            
                            Spacer()
                            
                            Button(action: {}) {
                                Image("nav-icon-profile")
                                    .resizable()
                                    .renderingMode(.original)
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 20, height: 20)
                            }
                            
                            Spacer()
                        }
                        .padding(.top, 8)
                    }
                    .frame(height: 50)
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct Restaurant: Identifiable {
    let id = UUID().uuidString
    let name: String
    let arabicName: String
    let rating: Double
    let cuisine: String
    let arabicCuisine: String
    let imageName: String
    let hasMichelin: Bool
    let description: String
    let arabicDescription: String
}

// MARK: - Grid Card (151x170, Figma 2-row layout)

struct GridRestaurantCard: View {
    let restaurant: Restaurant
    let isArabic: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topLeading) {
                Image(restaurant.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 142, height: 100)
                    .clipped()
                    .cornerRadius(11)
                    .padding(.top, 4.3)
                    .padding(.horizontal, 4.7)
                
                if restaurant.hasMichelin {
                    Text("MICHELIN")
                        .font(.custom("ExpoArabic-Medium", size: 6))
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 0xA7 / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                        .cornerRadius(3)
                        .padding(.top, 11)
                        .padding(.leading, 9)
                }
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(isArabic ? restaurant.arabicName : restaurant.name)
                    .font(.custom("ExpoArabic-Medium", size: 14))
                    .fontWeight(.medium)
                    .foregroundColor(.black)
                    .lineLimit(1)
                    .padding(.top, 6)
                
                HStack(spacing: 3) {
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    Image("star-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                }
                .padding(.top, 2)
                
                HStack(spacing: 3) {
                    Image("fork-knife-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                    
                    Text(isArabic ? restaurant.arabicCuisine : restaurant.cuisine)
                        .font(.custom("ExpoArabic-Medium", size: 8))
                        .fontWeight(.light)
                        .foregroundColor(.black)
                        .lineLimit(1)
                }
                .padding(.top, 2)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: 151, height: 170)
        .background(Color.white)
        .cornerRadius(16)
        .environment(\.layoutDirection, .leftToRight)
    }
}

// MARK: - Nearby Restaurant Card (258x72, Figma bottom section)

struct NearbyRestaurantCard: View {
    let restaurant: Restaurant
    let isArabic: Bool
    
    var body: some View {
        HStack(spacing: 9) {
            Image(restaurant.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 55)
                .cornerRadius(12)
                .clipped()
                .padding(.leading, 7)
            
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 4) {
                    Text(isArabic ? restaurant.arabicName : restaurant.name)
                        .font(.custom("ExpoArabic-Medium", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .lineLimit(1)
                    
                    if restaurant.hasMichelin {
                        Text("MICHELIN")
                            .font(.custom("ExpoArabic-Medium", size: 8))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 0xA7 / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                            .cornerRadius(4)
                    }
                }
                
                HStack(spacing: 3) {
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    
                    Image("star-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                }
                .padding(.top, 2)
                
                HStack(spacing: 3) {
                    Image("fork-knife-icon")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 10, height: 10)
                    
                    Text(isArabic ? restaurant.arabicCuisine : restaurant.cuisine)
                        .font(.custom("ExpoArabic-Medium", size: 10))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .lineLimit(1)
                }
                .padding(.top, 2)
            }
            
            Spacer()
        }
        .frame(width: 258, height: 72)
        .background(Color.white)
        .cornerRadius(19)
        .environment(\.layoutDirection, .leftToRight)
    }
}

// Keep old cards for detail navigation compatibility
struct RestaurantCard: View {
    let restaurant: Restaurant
    let isFavorite: Bool
    let onToggleFavorite: () -> Void
    let isArabic: Bool
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                Image(restaurant.imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 242, height: 185)
                    .clipped()
                    .cornerRadius(17)
                    .padding(.top, 8)
                    .padding(.horizontal, 8)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top, spacing: 4) {
                        if isArabic {
                            Spacer()
                            if restaurant.hasMichelin {
                                Text("MICHELIN")
                                    .font(.custom("ExpoArabic-Medium", size: 10))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 0xA7 / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                                    .cornerRadius(5)
                            }
                            Text(restaurant.arabicName)
                                .font(.custom("ExpoArabic-Medium", size: 20))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .lineLimit(1)
                        } else {
                            Text(restaurant.name)
                                .font(.custom("ExpoArabic-Medium", size: 20))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                                .lineLimit(1)
                            if restaurant.hasMichelin {
                                Text("MICHELIN")
                                    .font(.custom("ExpoArabic-Medium", size: 10))
                                    .fontWeight(.medium)
                                    .foregroundColor(Color(red: 0xA7 / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0))
                                    .padding(.horizontal, 5)
                                    .padding(.vertical, 2)
                                    .background(Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                                    .cornerRadius(5)
                            }
                        }
                    }
                    .padding(.top, 16)
                    
                    HStack(spacing: 4) {
                        if isArabic {
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.custom("ExpoArabic-Medium", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                            Image("star-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 12, height: 12)
                        } else {
                            Image("star-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 12, height: 12)
                            Text(String(format: "%.1f", restaurant.rating))
                                .font(.custom("ExpoArabic-Medium", size: 16))
                                .fontWeight(.medium)
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.top, 10)
                    .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                    
                    HStack(spacing: 4) {
                        Image("fork-knife-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 12, height: 12)
                        Text(isArabic ? restaurant.arabicCuisine : restaurant.cuisine)
                            .font(.custom("ExpoArabic-Medium", size: 12))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                    .padding(.top, 7)
                    .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                    
                    HStack(spacing: 4) {
                        Image("location-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 10, height: 12)
                        Text(isArabic ? "جدة" : "Jeddah")
                            .font(.custom("ExpoArabic-Medium", size: 10))
                            .fontWeight(.medium)
                            .foregroundColor(.black)
                    }
                    .padding(.top, 4)
                    .frame(maxWidth: .infinity, alignment: isArabic ? .trailing : .leading)
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 16)
            }
            .frame(width: 258, height: 316)
            .background(Color.white)
            .cornerRadius(22)
            
            Button(action: onToggleFavorite) {
                ZStack {
                    Image("heart-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 25, height: 25)
                    Image("base").resizable().aspectRatio(contentMode: .fit).frame(width: 16, height: 16)
                }
            }
            .padding(.top, 15)
            .padding(.trailing, 15)
        }
        .environment(\.layoutDirection, .leftToRight)
    }
}

struct SmallRestaurantCard: View {
    let restaurant: Restaurant
    let isArabic: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(restaurant.imageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 70, height: 70)
                .cornerRadius(12)
                .clipped()
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(isArabic ? restaurant.arabicName : restaurant.name)
                        .font(.custom("ExpoArabic-Medium", size: 16))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .lineLimit(1)
                    if restaurant.hasMichelin {
                        Text("MICHELIN")
                            .font(.custom("ExpoArabic-Medium", size: 8))
                            .fontWeight(.medium)
                            .foregroundColor(Color(red: 0xA7 / 255.0, green: 0x1E / 255.0, blue: 0x1E / 255.0))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color(red: 0xD9 / 255.0, green: 0xD9 / 255.0, blue: 0xD9 / 255.0))
                            .cornerRadius(4)
                    }
                }
                HStack(spacing: 4) {
                    Text(String(format: "%.1f", restaurant.rating))
                        .font(.custom("ExpoArabic-Medium", size: 14))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                    Image("star-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 10, height: 10)
                }
                HStack(spacing: 4) {
                    Image("fork-knife-icon").resizable().aspectRatio(contentMode: .fit).frame(width: 10, height: 10)
                    Text(isArabic ? restaurant.arabicCuisine : restaurant.cuisine)
                        .font(.custom("ExpoArabic-Medium", size: 12))
                        .fontWeight(.medium)
                        .foregroundColor(.black)
                        .lineLimit(1)
                }
            }
            Spacer()
        }
        .frame(width: 220, height: 86)
        .background(Color.white)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    RestaurantListView()
}
