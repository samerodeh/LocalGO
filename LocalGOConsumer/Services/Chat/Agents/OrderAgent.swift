import Foundation

/// Helps the user build an order and, on confirmation, returns the items to add
/// to the cart. Mirrors the reference backend's `order_agent`: a confirmation
/// check followed by a guided ordering reply. Real checkout still happens through
/// the existing Cart → Checkout flow, so "confirm" here means "add to cart".
struct OrderAgent {
    let llm: LLMClient

    private struct Confirmation: Decodable {
        struct Line: Decodable {
            let name: String
            let quantity: Int?
        }
        let confirmed: Bool
        let items: [Line]
    }

    func respond(_ message: String, history: [LLMMessage], context: ChatContext) async -> AgentReply {
        // 1) Has the user just confirmed an order we've been assembling?
        let confirmation = await llm.completeJSON(
            systemPrompt: """
            You detect whether the customer is confirming their final order, based on
            the conversation. Respond with JSON only.
            If they clearly say yes/confirm/place order/go ahead/add it:
            {"confirmed": true, "items": [{"name": "<exact menu item name>", "quantity": 1}]}
            Otherwise:
            {"confirmed": false, "items": []}
            Only use item names that appear in this menu:
            \(context.menuText)
            """,
            user: message,
            history: history,
            as: Confirmation.self,
            fallback: Confirmation(confirmed: false, items: [])
        )

        if confirmation.confirmed, !confirmation.items.isEmpty {
            // Resolve names against the real menu so we never add a phantom item.
            let additions: [CartAddition] = confirmation.items.compactMap { line in
                guard let match = resolve(line.name, in: context.menuItems) else { return nil }
                return CartAddition(itemName: match.name, quantity: max(1, line.quantity ?? 1))
            }
            if !additions.isEmpty {
                let summary = additions.map { "\($0.quantity)× \($0.itemName)" }.joined(separator: ", ")
                return AgentReply(
                    text: "Added \(summary) to your cart 🛒 Head to the Cart tab to review and check out whenever you're ready.",
                    cartAdditions: additions
                )
            }
        }

        // 2) Otherwise, guide them through ordering.
        let system = """
        You are \(context.restaurant.name)'s order assistant (\(context.restaurant.cuisine)).
        Help the customer build an order using ONLY the menu below.
        Rules:
        - If a requested item isn't on the menu, say so and suggest the closest match.
        - Confirm item names and quantities, then ask the customer to confirm before adding to cart.
        - Keep replies brief (1-2 sentences).

        MENU:
        \(context.menuText)
        """

        let text = await llm.complete(systemPrompt: system, user: message, history: history)
        return AgentReply(text: text)
    }

    /// Case-insensitive exact match first, then a contains-based fallback.
    private func resolve(_ name: String, in menu: [MenuItem]) -> MenuItem? {
        let needle = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if let exact = menu.first(where: { $0.name.lowercased() == needle }) { return exact }
        return menu.first { $0.name.lowercased().contains(needle) || needle.contains($0.name.lowercased()) }
    }
}
