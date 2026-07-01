import Foundation

/// Answers questions about the user's past orders, grounded in their persisted
/// order history. Mirrors the reference backend's `order_history_agent`.
struct OrderHistoryAgent {
    let llm: LLMClient

    func respond(_ message: String, history: [LLMMessage], context: ChatContext) async -> AgentReply {
        if context.isGuest {
            return AgentReply(text: "You're browsing as a guest, so I don't have any past orders on file. Sign in to keep your order history.")
        }
        guard !context.recentOrders.isEmpty else {
            return AgentReply(text: "You haven't placed any orders with us yet. Want a recommendation to get started?")
        }

        let historyText = context.recentOrders.prefix(8).map { order in
            "- \(order.placedAtFormatted): \(order.summary) — total $\(String(format: "%.2f", order.total))"
        }.joined(separator: "\n")

        let system = """
        You are \(context.restaurant.name)'s order-history assistant.
        Answer the user's question about their past orders using ONLY the data below.
        Be concise and specific (reference dates, items, totals). If they ask to
        reorder, tell them you can add those items to the cart — they just need to confirm.

        \(context.userName.map { "Customer: \($0)" } ?? "")
        PAST ORDERS (most recent first):
        \(historyText)
        """

        let text = await llm.complete(systemPrompt: system, user: message, history: history)
        return AgentReply(text: text)
    }
}
