import Foundation

/// Handles allergy / vegetarian / halal / preference questions, grounded in the
/// menu's dietary flags. Mirrors the reference backend's `dietary_agent`.
struct DietaryAgent {
    let llm: LLMClient

    func respond(_ message: String, history: [LLMMessage], context: ChatContext) async -> AgentReply {
        let vegetarian = context.menuItems.filter { $0.isVegetarian }
        let vegText = vegetarian.map { "- \($0.name) ($\(String(format: "%.2f", $0.price)))" }
            .joined(separator: "\n")
        let isHalal = context.restaurant.tags.contains { $0.lowercased() == "halal" }

        let system = """
        You are \(context.restaurant.name)'s dietary specialist (\(context.restaurant.cuisine)).
        Restaurant-wide facts: \(isHalal ? "All meat is halal." : "Halal status is not specified.")
        Answer dietary questions using ONLY the menu data below. Be clear about what
        is and isn't suitable, and suggest specific items. If you're unsure whether an
        item contains a specific allergen, say so honestly rather than guessing. Keep
        it concise and friendly.

        VEGETARIAN ITEMS:
        \(vegText.isEmpty ? "None flagged." : vegText)

        FULL MENU:
        \(context.menuText)
        """

        let text = await llm.complete(systemPrompt: system, user: message, history: history)
        return AgentReply(text: text)
    }
}
