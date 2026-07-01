import Foundation

/// The multi-agent pipeline, ported from the reference backend's `RouterAgent`:
///
///     guard  →  router  →  one specialist agent
///
/// The guard rejects off-topic messages; the router classifies intent; the chosen
/// specialist produces the reply (and any cart side effects). Everything is
/// grounded in the live `ChatContext` so the agents never invent menu data.
struct AgentOrchestrator {
    let llm: LLMClient

    init(llm: LLMClient = LLMClient()) {
        self.llm = llm
    }

    func respond(to message: String, history: [LLMMessage], context: ChatContext) async -> AgentReply {
        // Short-circuit before any network if the assistant isn't configured.
        guard Config.isGroqConfigured else {
            return AgentReply(text: "The assistant isn't set up yet. Add a free Groq API key in Config.swift (groqAPIKey) to enable it — get one at console.groq.com/keys.")
        }

        // 1) Guard: is this on-topic?
        if let block = await GuardAgent(llm: llm).check(message, history: history, context: context) {
            return AgentReply(text: block)
        }

        // 2) Router: which specialist?
        let intent = await RouterAgent(llm: llm).route(message, history: history, context: context)

        // 3) Dispatch.
        switch intent {
        case .menu:
            return await MenuAgent(llm: llm).respond(message, history: history, context: context)
        case .order:
            return await OrderAgent(llm: llm).respond(message, history: history, context: context)
        case .recommendation:
            return await RecommendationAgent(llm: llm).respond(message, history: history, context: context)
        case .reservation:
            return await ReservationAgent(llm: llm).respond(message, history: history, context: context)
        case .dietary:
            return await DietaryAgent(llm: llm).respond(message, history: history, context: context)
        case .orderHistory:
            return await OrderHistoryAgent(llm: llm).respond(message, history: history, context: context)
        }
    }
}
