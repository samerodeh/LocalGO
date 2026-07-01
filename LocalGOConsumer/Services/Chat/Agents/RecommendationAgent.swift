import Foundation

/// Suggests what to eat, grounded in the app's own RecommendationEngine ranking
/// (popularity + trending + personal history). Mirrors the reference backend's
/// `recommendation_agent`, but uses the native engine instead of an apriori model.
struct RecommendationAgent {
    let llm: LLMClient

    func respond(_ message: String, history: [LLMMessage], context: ChatContext) async -> AgentReply {
        let top = Array(context.recommendations.prefix(6))
        guard !top.isEmpty else {
            return AgentReply(text: "I don't have enough data to recommend yet — but our \(context.restaurant.cuisine) plates are always a great start. Want to see the menu?")
        }

        let recContext = top.map { rec in
            "- \(rec.item.name) ($\(String(format: "%.2f", rec.item.price))) — \(rec.reason.label); \(rec.item.description)"
        }.joined(separator: "\n")

        let personalNote = context.isGuest
            ? "The user is a guest with no order history, so recommend based on popularity."
            : "Blend popularity with what \(context.userName ?? "the user") tends to order."

        let system = """
        You are \(context.restaurant.name)'s friendly recommendation assistant (\(context.restaurant.cuisine)).
        \(personalNote)
        Suggest from the ranked items below, naturally and enthusiastically. Mention
        why they're worth trying (popular, trending, or a personal favorite). Keep it
        short (2-4 sentences). Don't suggest anything not listed.

        RANKED RECOMMENDATIONS:
        \(recContext)
        """

        let text = await llm.complete(systemPrompt: system, user: message, history: history)
        return AgentReply(text: text)
    }
}
