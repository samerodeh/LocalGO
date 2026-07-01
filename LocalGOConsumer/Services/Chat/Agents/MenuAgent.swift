import Foundation

/// Answers menu, pricing, hours, and general-info questions grounded strictly in
/// the app's real menu. Mirrors the reference backend's `menu_agent`, including
/// its shortcut for "show me the full menu".
struct MenuAgent {
    let llm: LLMClient

    func respond(_ message: String, history: [LLMMessage], context: ChatContext) async -> AgentReply {
        if isFullMenuRequest(message) {
            return AgentReply(text: context.fullMenuText)
        }

        let system = """
        You are \(context.restaurant.name)'s menu expert (\(context.restaurant.cuisine)).
        Restaurant: \(context.restaurant.description)
        Address: \(context.restaurant.address). Delivery: \(context.restaurant.deliveryTime), fee $\(String(format: "%.2f", context.restaurant.deliveryFee)).

        Answer using ONLY the menu below. Never invent items or prices. If an item
        isn't on the menu, say so and suggest the closest item that is. Be concise,
        warm, and helpful (1-3 sentences).

        MENU:
        \(context.menuText)
        """

        let text = await llm.complete(systemPrompt: system, user: message, history: history)
        return AgentReply(text: text)
    }

    private func isFullMenuRequest(_ message: String) -> Bool {
        let normalized = message.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let triggers = [
            "menu", "show menu", "full menu", "show the menu", "show the full menu",
            "show me the menu", "what's on the menu", "what is on the menu",
            "entire menu", "all menu items", "show all items", "see the menu"
        ]
        if triggers.contains(normalized) { return true }
        return ["full menu", "entire menu", "all menu", "show menu", "the whole menu"]
            .contains { normalized.contains($0) }
    }
}
