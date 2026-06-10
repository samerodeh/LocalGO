import Foundation

// MARK: - Al Taib Restaurant — sourced from altaib.ca & Uber Eats
enum RestaurantData {

    static let altaibID = UUID(uuidString: "A17A1B00-0000-0000-0000-000000000001")!

    static let altaib: Restaurant = Restaurant(
        id: altaibID,
        name: "Al Taib",
        cuisine: "Lebanese · Manakish · Pizza · Grill",
        description: "Authentic Lebanese bakery and grill. Fresh pitas, wood-fired manakish, and shawarma plates made daily.",
        address: "5765 Bd Décarie, Montreal, QC",
        rating: 4.6,
        ratingCount: 320,
        deliveryTime: "25–40 min",
        deliveryFee: 2.99,
        minimumOrder: 12.00,
        isOpen: true,
        tags: ["Lebanese", "Halal", "Manakish", "Pizza"],
        categories: [
            featured,
            manakishAndPies,
            pizza,
            grill,
            sides,
            drinks
        ]
    )

    static var all: [Restaurant] { [altaib] }

    // MARK: - Categories

    private static let featured = MenuCategory(
        id: UUID(uuidString: "CA700001-0000-0000-0000-000000000001")!,
        name: "Featured",
        items: [
            item("Cheese Manakish",          "Kashkaval, akawi cheese, and halloumi baked on granite",        7.50, popular: true,  veg: true),
            item("Zaatar Manakish",          "Classic Lebanese thyme blend on freshly baked flatbread",       4.75, popular: true,  veg: true),
            item("Zaatar & Cheese Manakish", "House thyme blend topped with a mix of Lebanese cheeses",       7.00, popular: true,  veg: true),
            item("Lahmbajine Manakish",      "Ground beef, tomato purée, onions, and seven spices",           7.50, popular: true,  veg: false),
            item("Shish Taouk Sandwich",     "Marinated chicken grilled and served in fresh pita with garlic sauce", 11.00, popular: true, veg: false),
            item("Chicken Shawarma Trio",    "Three mini chicken shawarma wraps with garlic, pickles, and fries", 18.00, popular: true, veg: false),
        ]
    )

    private static let manakishAndPies = MenuCategory(
        id: UUID(uuidString: "CA700002-0000-0000-0000-000000000002")!,
        name: "Manakish & Pies",
        items: [
            item("Zaatar Manakish",              "Classic Lebanese thyme blend on freshly baked flatbread",           4.75, popular: true,  veg: true),
            item("Cheese Manakish",              "Kashkaval, akawi cheese, and halloumi baked on granite",            7.50, popular: true,  veg: true),
            item("Zaatar & Cheese Manakish",     "House thyme blend topped with a mix of Lebanese cheeses",           7.00, popular: false, veg: true),
            item("Lahmbajine Manakish",          "Ground beef, tomato purée, onions, and seven spices",               7.50, popular: true,  veg: false),
            item("Lahmbajine & Cheese Manakish", "Ground beef and tomato base topped with melted cheese",             7.50, popular: false, veg: false),
            item("Sojuk Manakish",               "Spiced beef sujuk sausage with tomatoes on flatbread",              7.50, popular: false, veg: false),
            item("Spinach Pie",                  "Tender spinach filling with lemon and olive oil in flaky dough",    4.75, popular: false, veg: true),
            item("Cheese Pie",                   "Creamy akawi cheese wrapped in golden baked pastry",                4.99, popular: false, veg: true),
            item("Half Spinach / Half Cheese Pie","Half spinach and half cheese — best of both worlds",               4.99, popular: false, veg: true),
            item("Falafel Sandwich",             "Crispy falafel, tahini, tomatoes, pickles, and parsley in pita",   7.99, popular: false, veg: true),
        ]
    )

    private static let pizza = MenuCategory(
        id: UUID(uuidString: "CA700003-0000-0000-0000-000000000003")!,
        name: "Pizza",
        items: [
            item("All Dressed Pizza",              "Sauce, mozzarella, pepperoni, mushrooms, and green pepper",       16.00, popular: true,  veg: false),
            item("Hawaiian Pizza",                 "Sauce, mozzarella, beef, and pineapple",                          17.00, popular: false, veg: false),
            item("Mexican Pizza",                  "Sauce, mozzarella, spicy beef, fresh tomatoes, banana peppers, onions", 17.00, popular: false, veg: false),
            item("Chicken Pizza",                  "Sauce, mozzarella, grilled chicken, and fresh tomatoes",           17.00, popular: false, veg: false),
            item("Pepperoni Pizza",                "Sauce, mozzarella, and generous pepperoni",                        16.00, popular: false, veg: false),
            item("Cheese Pizza",                   "Tangy tomato sauce with a thick layer of mozzarella",             16.00, popular: false, veg: true),
            item("Vege Pizza",                     "Sauce, mozzarella, black olives, mushrooms, green peppers, fresh tomatoes", 17.00, popular: false, veg: true),
            item("Spinach Pizza",                  "Sauce, mozzarella, spinach, and black olives",                     17.00, popular: false, veg: true),
            item("Tuna Pizza",                     "Sauce, mozzarella, tuna, garlic, and fresh tomatoes",              18.00, popular: false, veg: false),
            item("Nutella Chocolate XL Pizza (18\")", "Nutella base with banana, strawberry jam, lotus biscuit, and pineapple", 35.00, popular: false, veg: true),
        ]
    )

    private static let grill = MenuCategory(
        id: UUID(uuidString: "CA700004-0000-0000-0000-000000000004")!,
        name: "Grill",
        items: [
            item("Shish Taouk Sandwich",   "Marinated chicken grilled and served in fresh pita with garlic sauce",   11.00, popular: true,  veg: false),
            item("Chicken Shawarma Trio",  "Three mini chicken shawarma wraps with garlic, pickles, and fries",       18.00, popular: true,  veg: false),
            item("Beef Shawarma Trio",     "Three mini beef shawarma wraps with tahini sauce and fries",              19.00, popular: false, veg: false),
        ]
    )

    private static let sides = MenuCategory(
        id: UUID(uuidString: "CA700005-0000-0000-0000-000000000005")!,
        name: "Sides & Salads",
        items: [
            item("Hummus",           "Classic smooth hummus with olive oil and paprika, served with pita",  6.50, popular: true,  veg: true),
            item("Tabouleh",         "Fresh parsley, tomatoes, bulgur, lemon, and olive oil",               7.00, popular: false, veg: true),
            item("Fatoush",          "Crispy pita, romaine, tomatoes, cucumber, radish, sumac dressing",    7.00, popular: false, veg: true),
            item("Beets Salad",      "Roasted beets with herbs and a light vinaigrette",                    7.00, popular: false, veg: true),
            item("Fries",            "Golden crispy fries seasoned with sea salt",                           6.99, popular: false, veg: true),
            item("Poutine",          "Fries topped with cheese curds and rich gravy",                        10.99, popular: false, veg: true),
            item("Basmati Rice",     "Fragrant long-grain basmati rice",                                     4.50, popular: false, veg: true),
            item("Baklava Patisserie","Flaky phyllo pastry with honey, rose water, and mixed nuts",          3.50, popular: false, veg: true),
            item("Cheesecake Slice", "Creamy New York-style cheesecake slice",                               6.50, popular: false, veg: true),
        ]
    )

    private static let drinks = MenuCategory(
        id: UUID(uuidString: "CA700006-0000-0000-0000-000000000006")!,
        name: "Drinks",
        items: [
            item("Ayran Yoghurt",      "Refreshing cold salted yoghurt drink",  5.50, popular: true,  veg: true),
            item("Fresh Apple Juice",  "Freshly pressed apple juice",            6.00, popular: false, veg: true),
            item("Red Bull",           "250ml energy drink",                     7.00, popular: false, veg: true),
            item("Perrier",            "Sparkling mineral water",                3.00, popular: false, veg: true),
            item("Coke / Diet Coke",   "355ml can",                              2.99, popular: false, veg: true),
            item("Pepsi / Diet Pepsi", "355ml can",                              2.99, popular: false, veg: true),
            item("7 Up / Sprite",      "355ml can",                              2.99, popular: false, veg: true),
            item("Fanta",              "355ml can — orange",                     3.75, popular: false, veg: true),
            item("Root Beer",          "355ml can",                              2.50, popular: false, veg: true),
            item("Water",              "500ml bottle",                           2.50, popular: false, veg: true),
        ]
    )

    // MARK: - Factory helper
    private static func item(
        _ name: String,
        _ description: String,
        _ price: Double,
        popular: Bool = false,
        veg: Bool = false,
        calories: Int? = nil
    ) -> MenuItem {
        MenuItem(
            id: UUID(),
            name: name,
            description: description,
            price: price,
            isPopular: popular,
            isVegetarian: veg,
            calories: calories
        )
    }
}
