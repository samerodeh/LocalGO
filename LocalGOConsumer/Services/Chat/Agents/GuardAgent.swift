import Foundation

/// First stage of the pipeline: decides whether the message is on-topic for the
/// restaurant assistant. Mirrors the reference backend's `guard_agent`.
struct GuardAgent {
    let llm: LLMClient

    private struct Decision: Decodable {
        let decision: String          // "allowed" | "not allowed"
        let message: String?
    }

    /// Returns a block message if the request is off-topic, or `nil` to proceed.
    func check(_ message: String, history: [LLMMessage], context: ChatContext) async -> String? {
        let system = """
        You are the safety guard for \(context.restaurant.name)'s assistant, a \(context.restaurant.cuisine) restaurant.
        Decide whether the user's message is relevant to the restaurant.

        The user IS allowed to:
        1. Ask about the restaurant (location, hours, delivery, general info).
        2. Ask about menu items (ingredients, details, prices).
        3. Place or adjust an order.
        4. Ask for recommendations.
        5. Ask about or request a table reservation.
        6. Ask about their previous orders.
        7. Ask about dietary needs, allergies, vegetarian or halal options.

        The user is NOT allowed to:
        1. Ask about anything unrelated to the restaurant.
        2. Ask how to cook a dish or about staff.
        3. Send rude or offensive messages.

        Respond with JSON only:
        {
          "decision": "allowed" or "not allowed",
          "message": "" if allowed, otherwise a short polite redirect
        }
        """

        let result = await llm.completeJSON(
            systemPrompt: system,
            user: message,
            history: history,
            as: Decision.self,
            fallback: Decision(decision: "allowed", message: "")
        )

        if result.decision == "not allowed" {
            let fallback = "Sorry, I can only help with \(context.restaurant.name) — menu, orders, recommendations, and reservations. What can I get started for you?"
            let msg = result.message ?? ""
            return msg.isEmpty ? fallback : msg
        }
        return nil
    }
}
