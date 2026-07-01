import Foundation

/// A single message in the assistant conversation.
struct ChatMessage: Identifiable, Equatable {
    enum Role { case user, assistant }

    let id: UUID
    let role: Role
    var text: String
    let timestamp: Date

    init(id: UUID = UUID(), role: Role, text: String, timestamp: Date = Date()) {
        self.id = id
        self.role = role
        self.text = text
        self.timestamp = timestamp
    }
}

/// Lightweight role/content pair sent to the LLM as prior conversation turns.
/// Mirrors the OpenAI/Groq chat message shape.
struct LLMMessage: Codable {
    let role: String      // "system" | "user" | "assistant"
    let content: String
}
