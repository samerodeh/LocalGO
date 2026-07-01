import Foundation

/// A snapshot of everything the agents need to answer grounded in the app's real
/// data. Built on the main actor from the live env objects (menu, recommender,
/// order history, user) and handed to the orchestrator as an immutable value.
struct ChatContext {
    let restaurant: Restaurant
    /// Unique menu items across all categories (the menu repeats some in "Featured").
    let menuItems: [MenuItem]
    /// Pre-ranked recommendations from the app's RecommendationEngine.
    let recommendations: [Recommendation]
    /// The signed-in user's recent order history (empty for guests).
    let recentOrders: [OrderRecord]
    let userName: String?
    let isGuest: Bool

    /// A compact, model-friendly listing of the menu — the single source of truth
    /// the agents are told never to deviate from.
    var menuText: String {
        menuItems.map { item in
            let tags = [item.isPopular ? "popular" : nil, item.isVegetarian ? "vegetarian" : nil]
                .compactMap { $0 }
                .joined(separator: ", ")
            let suffix = tags.isEmpty ? "" : " [\(tags)]"
            return "- \(item.name) — $\(String(format: "%.2f", item.price)): \(item.description)\(suffix)"
        }
        .joined(separator: "\n")
    }

    /// The full menu grouped by category, ready to show verbatim.
    var fullMenuText: String {
        var lines = ["Here's our menu at \(restaurant.name):"]
        for category in restaurant.categories {
            lines.append("\n\(category.name):")
            for item in category.items {
                lines.append("• \(item.name) — $\(String(format: "%.2f", item.price))")
            }
        }
        return lines.joined(separator: "\n")
    }
}

/// What an agent produces: text to show, plus any side effects the view model
/// should apply on the main actor (e.g. adding items to the cart).
struct AgentReply {
    var text: String
    var cartAdditions: [CartAddition] = []
}

/// A request from the order agent to add a menu item to the cart.
struct CartAddition {
    let itemName: String
    let quantity: Int
}
