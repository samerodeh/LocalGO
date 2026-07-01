import Foundation

/// The set of specialists the router can dispatch to. Raw values match the
/// decision strings the model is asked to emit.
enum AgentIntent: String, Decodable {
    case menu = "menu_agent"
    case order = "order_agent"
    case recommendation = "recommendation_agent"
    case reservation = "reservation_agent"
    case dietary = "dietary_agent"
    case orderHistory = "order_history_agent"
}

/// Second stage: classifies an on-topic message and picks the specialist agent.
/// Mirrors the reference backend's `router_agent`.
struct RouterAgent {
    let llm: LLMClient

    private struct Decision: Decodable {
        let decision: AgentIntent
    }

    func route(_ message: String, history: [LLMMessage], context: ChatContext) async -> AgentIntent {
        let system = """
        You are the router for \(context.restaurant.name), a \(context.restaurant.cuisine) restaurant assistant.
        Determine which specialist should handle the user's message. Choose one:

        1. menu_agent: questions about menu items, ingredients, prices, location, hours, or general info.
        2. order_agent: the user wants to place, modify, or confirm an order.
        3. recommendation_agent: the user asks what to eat or for suggestions.
        4. reservation_agent: the user wants a table reservation.
        5. dietary_agent: the user asks about allergies, vegetarian, halal, or food preferences.
        6. order_history_agent: the user asks about their previous orders.

        Respond with JSON only:
        {
          "chain_of_thought": "brief reasoning",
          "decision": "menu_agent" | "order_agent" | "recommendation_agent" | "reservation_agent" | "dietary_agent" | "order_history_agent"
        }
        """

        let result = await llm.completeJSON(
            systemPrompt: system,
            user: message,
            history: history,
            as: Decision.self,
            fallback: Decision(decision: .menu)
        )
        return result.decision
    }
}
