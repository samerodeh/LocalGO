import Foundation

/// Handles table-reservation requests conversationally. The reference backend
/// persisted reservations to a database; LocalGOConsumer has no reservation
/// store yet, so this agent gathers the details and confirms the request without
/// inventing a booking system it can't honor.
struct ReservationAgent {
    let llm: LLMClient

    func respond(_ message: String, history: [LLMMessage], context: ChatContext) async -> AgentReply {
        let system = """
        You are \(context.restaurant.name)'s reservations host (\(context.restaurant.cuisine)).
        Help the user request a table. Collect three things if you don't have them yet:
        date, time, and party size. Once you have all three, warmly confirm the request
        and let them know the restaurant will follow up to finalize it — be honest that
        in-app booking isn't live yet, so it's a request rather than a guaranteed table.
        Keep replies short and friendly. Don't ask for payment.

        Restaurant hours/info: \(context.restaurant.description)
        Address: \(context.restaurant.address)
        """

        let text = await llm.complete(systemPrompt: system, user: message, history: history)
        return AgentReply(text: text)
    }
}
