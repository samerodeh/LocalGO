import Foundation

/// Aggregated historical order statistics for Al Taib, keyed by item name.
///
/// In production this table would come from your backend's orders database
/// (a `SELECT item, COUNT(*) ... GROUP BY item` over the order_items table,
/// plus a windowed count for the trailing 7 days). Here it stands in as the
/// seed data the recommendation engine ranks from. The engine then updates
/// these counts live as the user places real orders in-app.
enum SalesData {

    struct Stat {
        let allTime: Int   // total times ordered, all-time
        let recent: Int    // times ordered in the trailing 7 days (trending signal)
    }

    static let stats: [String: Stat] = [
        // Grill — the signature sellers
        "Chicken Shawarma Trio":            Stat(allTime: 1840, recent: 142),
        "Shish Taouk Sandwich":             Stat(allTime: 1620, recent: 128),
        "Beef Shawarma Trio":               Stat(allTime: 990,  recent: 71),

        // Manakish & pies
        "Zaatar Manakish":                  Stat(allTime: 1450, recent: 119),
        "Cheese Manakish":                  Stat(allTime: 1320, recent: 104),
        "Lahmbajine Manakish":              Stat(allTime: 870,  recent: 64),
        "Zaatar & Cheese Manakish":         Stat(allTime: 640,  recent: 44),
        "Falafel Sandwich":                 Stat(allTime: 690,  recent: 49),
        "Sojuk Manakish":                   Stat(allTime: 360,  recent: 22),
        "Spinach Pie":                      Stat(allTime: 340,  recent: 19),
        "Cheese Pie":                       Stat(allTime: 320,  recent: 18),
        "Lahmbajine & Cheese Manakish":     Stat(allTime: 260,  recent: 15),
        "Half Spinach / Half Cheese Pie":   Stat(allTime: 210,  recent: 10),

        // Pizza
        "All Dressed Pizza":                Stat(allTime: 1180, recent: 96),
        "Pepperoni Pizza":                  Stat(allTime: 760,  recent: 52),
        "Chicken Pizza":                    Stat(allTime: 560,  recent: 39),
        "Cheese Pizza":                     Stat(allTime: 480,  recent: 31),
        "Vege Pizza":                       Stat(allTime: 300,  recent: 17),
        "Hawaiian Pizza":                   Stat(allTime: 290,  recent: 16),
        "Mexican Pizza":                    Stat(allTime: 240,  recent: 13),
        "Spinach Pizza":                    Stat(allTime: 220,  recent: 11),
        "Tuna Pizza":                       Stat(allTime: 150,  recent: 8),
        "Nutella Chocolate XL Pizza (18\")": Stat(allTime: 110, recent: 7),

        // Sides & salads
        "Hummus":                           Stat(allTime: 820,  recent: 58),
        "Fries":                            Stat(allTime: 610,  recent: 47),
        "Fatoush":                          Stat(allTime: 510,  recent: 33),
        "Poutine":                          Stat(allTime: 450,  recent: 36),
        "Tabouleh":                         Stat(allTime: 420,  recent: 26),
        "Baklava Patisserie":               Stat(allTime: 400,  recent: 29),
        "Cheesecake Slice":                 Stat(allTime: 200,  recent: 14),
        "Basmati Rice":                     Stat(allTime: 190,  recent: 12),
        "Beets Salad":                      Stat(allTime: 170,  recent: 9),

        // Drinks
        "Water":                            Stat(allTime: 220,  recent: 30),
        "Ayran Yoghurt":                    Stat(allTime: 280,  recent: 24),
        "Coke / Diet Coke":                 Stat(allTime: 160,  recent: 20),
        "Fresh Apple Juice":                Stat(allTime: 140,  recent: 11),
        "Pepsi / Diet Pepsi":               Stat(allTime: 130,  recent: 14),
        "7 Up / Sprite":                    Stat(allTime: 120,  recent: 10),
        "Red Bull":                         Stat(allTime: 100,  recent: 9),
        "Fanta":                            Stat(allTime: 90,   recent: 6),
        "Root Beer":                        Stat(allTime: 70,   recent: 4),
        "Perrier":                          Stat(allTime: 60,   recent: 5),
    ]

    static func stat(for name: String) -> Stat {
        stats[name] ?? Stat(allTime: 0, recent: 0)
    }
}
