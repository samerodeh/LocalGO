import SwiftUI

/// Maps each Al Taib menu item to a real, dish-matched food photo.
///
/// Photos are loaded over the network from LoremFlickr (keyword-matched, free
/// Creative-Commons Flickr imagery) so every item shows an appetizing picture
/// without bundling dozens of binaries. To use Al Taib's own photography,
/// replace the URL returned here (e.g. point `url(for:)` at your own CDN, or
/// add a per-item override dictionary).
enum FoodImages {

    /// Keyword tags per menu item (matched on the lowercased item name).
    private static let keywords: [String: String] = [
        // Manakish & pies
        "cheese manakish":               "manakish,cheese",
        "zaatar manakish":               "manakish,zaatar",
        "zaatar & cheese manakish":      "manakish,flatbread",
        "lahmbajine manakish":           "lahmacun,flatbread",
        "lahmbajine & cheese manakish":  "lahmacun,cheese",
        "sojuk manakish":                "flatbread,sausage",
        "spinach pie":                   "spinach,pastry",
        "cheese pie":                    "cheese,pastry",
        "half spinach / half cheese pie":"pastry,baked",
        "falafel sandwich":              "falafel,wrap",
        // Pizza
        "all dressed pizza":             "pizza,supreme",
        "hawaiian pizza":                "pizza,pineapple",
        "mexican pizza":                 "pizza,spicy",
        "chicken pizza":                 "pizza,chicken",
        "pepperoni pizza":               "pizza,pepperoni",
        "cheese pizza":                  "pizza,cheese",
        "vege pizza":                    "pizza,vegetable",
        "spinach pizza":                 "pizza,spinach",
        "tuna pizza":                    "pizza,seafood",
        "nutella chocolate xl pizza (18\")": "nutella,dessert,chocolate",
        // Grill
        "shish taouk sandwich":          "chicken,shish,grill",
        "chicken shawarma trio":         "shawarma,chicken",
        "beef shawarma trio":            "shawarma,beef",
        // Sides & salads
        "hummus":                        "hummus,dip",
        "tabouleh":                      "tabbouleh,salad",
        "fatoush":                       "fattoush,salad",
        "beets salad":                   "beetroot,salad",
        "fries":                         "fries,potato",
        "poutine":                       "poutine,fries",
        "basmati rice":                  "rice,basmati",
        "baklava patisserie":            "baklava,pastry",
        "cheesecake slice":              "cheesecake,dessert",
        // Drinks
        "ayran yoghurt":                 "ayran,yogurt,drink",
        "fresh apple juice":             "apple,juice",
        "red bull":                      "energy,drink,can",
        "perrier":                       "sparkling,water",
        "coke / diet coke":              "cola,soda,can",
        "pepsi / diet pepsi":            "cola,soda,can",
        "7 up / sprite":                 "lemonade,soda,can",
        "fanta":                         "orange,soda,can",
        "root beer":                     "soda,can",
        "water":                         "water,bottle",
    ]

    static func url(for name: String) -> URL? {
        let key = name.lowercased()
        let tags = keywords[key] ?? "lebanese,food,plate"
        let lock = stableLock(key)
        let encoded = tags.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "food"
        return URL(string: "https://loremflickr.com/400/400/\(encoded)?lock=\(lock)")
    }

    /// Deterministic per-name value so each item keeps the same photo between launches.
    private static func stableLock(_ s: String) -> Int {
        var hash: UInt64 = 5381
        for byte in s.utf8 { hash = (hash &* 33) &+ UInt64(byte) }
        return Int(hash % 100_000)
    }
}

/// Reusable thumbnail backed by the cached image pipeline (memory + disk +
/// downsampling). Renders instantly when warm; shows a branded fallback while
/// loading or when offline.
struct FoodThumbnail: View {
    let url: URL?
    let width: CGFloat
    let height: CGFloat
    var corner: CGFloat = 12

    var body: some View {
        CachedAsyncImage(url: url) { image in
            image.resizable().aspectRatio(contentMode: .fill)
        } placeholder: {
            ZStack {
                AppTheme.primary.opacity(0.09)
                Image(systemName: "fork.knife")
                    .font(.system(size: min(width, height) * 0.32))
                    .foregroundColor(AppTheme.primary.opacity(0.35))
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: corner, style: .continuous))
    }

    /// Every menu photo URL across all restaurants — used to warm the cache on launch.
    static var allMenuImageURLs: [URL] {
        let urls = RestaurantData.all
            .flatMap { $0.categories }
            .flatMap { $0.items }
            .compactMap { $0.imageURL }
        return Array(Set(urls))
    }
}
