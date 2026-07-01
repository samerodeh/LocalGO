import Foundation
import SwiftUI

/// Drives the assistant screen: owns the transcript, builds a `ChatContext` from
/// the live app state, runs the multi-agent pipeline, and applies any cart side
/// effects back on the main actor.
@MainActor
final class ChatViewModel: ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var inputText: String = ""
    @Published private(set) var isResponding = false

    private let orchestrator = AgentOrchestrator()
    private let restaurant = RestaurantData.altaib

    /// Conversational suggestions shown as quick-tap chips when the chat is fresh.
    let starters = [
        "Show me the menu",
        "What do you recommend?",
        "Any vegetarian options?",
        "I'd like to order Cheese Manakish"
    ]

    init() {
        messages = [
            ChatMessage(
                role: .assistant,
                text: "Hi! I'm the \(restaurant.name) assistant 🌟 Ask about the menu, get a recommendation, start an order, or check your past orders."
            )
        ]
    }

    var showStarters: Bool { messages.count <= 1 && !isResponding }

    func sendStarter(_ text: String, cart: CartViewModel, recEngine: RecommendationEngine, orderService: OrderService, auth: AuthService) {
        inputText = text
        send(cart: cart, recEngine: recEngine, orderService: orderService, auth: auth)
    }

    func send(cart: CartViewModel, recEngine: RecommendationEngine, orderService: OrderService, auth: AuthService) {
        let text = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty, !isResponding else { return }

        inputText = ""
        messages.append(ChatMessage(role: .user, text: text))
        isResponding = true

        let context = makeContext(recEngine: recEngine, orderService: orderService, auth: auth)
        let history = makeHistory()

        Task {
            let reply = await orchestrator.respond(to: text, history: history, context: context)
            applyCartAdditions(reply.cartAdditions, cart: cart)
            messages.append(ChatMessage(role: .assistant, text: reply.text))
            isResponding = false
        }
    }

    // MARK: - Context & history

    private func makeContext(recEngine: RecommendationEngine, orderService: OrderService, auth: AuthService) -> ChatContext {
        var seen = Set<String>()
        let uniqueItems = restaurant.categories
            .flatMap(\.items)
            .filter { seen.insert($0.name).inserted }

        let user = auth.currentUser
        return ChatContext(
            restaurant: restaurant,
            menuItems: uniqueItems,
            recommendations: recEngine.recommendations(for: restaurant, limit: 8),
            recentOrders: orderService.orders,
            userName: user?.name,
            isGuest: user?.isGuest ?? true
        )
    }

    /// Prior turns (everything before the message we just appended), capped to the
    /// last 10 to keep the prompt small.
    private func makeHistory() -> [LLMMessage] {
        messages
            .dropLast()                      // the in-flight user message
            .suffix(10)
            .map { LLMMessage(role: $0.role == .user ? "user" : "assistant", content: $0.text) }
    }

    // MARK: - Side effects

    private func applyCartAdditions(_ additions: [CartAddition], cart: CartViewModel) {
        guard !additions.isEmpty else { return }
        let menu = Dictionary(
            restaurant.categories.flatMap(\.items).map { ($0.name, $0) },
            uniquingKeysWith: { first, _ in first }
        )
        for addition in additions {
            guard let item = menu[addition.itemName] else { continue }
            for _ in 0..<max(1, addition.quantity) {
                cart.addItem(item, restaurant: restaurant)
            }
        }
    }
}
