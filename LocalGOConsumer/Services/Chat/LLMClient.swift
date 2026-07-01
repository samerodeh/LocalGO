import Foundation

/// Thin async client for Groq's OpenAI-compatible chat completions API.
///
/// This is the Swift counterpart of the reference backend's `agent_utilities.py`
/// (`llm` / `llm_json`): every agent funnels its prompts through here. It runs as
/// an `actor` so all network work happens off the main thread and concurrent
/// agent calls are serialized safely.
actor LLMClient {

    enum LLMError: Error { case notConfigured, badResponse }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    // MARK: - Plain text completion  (≈ llm)

    /// Send a system prompt + history + user turn and return the assistant's text.
    /// On transient failure it retries once, then returns a friendly fallback.
    func complete(systemPrompt: String, user: String, history: [LLMMessage] = []) async -> String {
        var messages = [LLMMessage(role: "system", content: systemPrompt)]
        messages += history
        messages.append(LLMMessage(role: "user", content: user))

        for attempt in 0..<2 {
            do {
                return try await send(messages: messages, json: false)
            } catch LLMError.notConfigured {
                return "The assistant isn't set up yet — add a Groq API key in Config.swift to enable it."
            } catch {
                if attempt == 0 {
                    try? await Task.sleep(nanoseconds: 800_000_000)
                    continue
                }
                return "I'm having trouble reaching the assistant right now. Please try again in a moment."
            }
        }
        return "I'm having trouble reaching the assistant right now. Please try again in a moment."
    }

    // MARK: - JSON completion  (≈ llm_json)

    /// Same as `complete`, but asks the model for a JSON object and decodes it
    /// into `T`. Returns `fallback` if the call or decode fails.
    func completeJSON<T: Decodable>(
        systemPrompt: String,
        user: String,
        history: [LLMMessage] = [],
        as type: T.Type,
        fallback: T
    ) async -> T {
        var messages = [LLMMessage(role: "system", content: systemPrompt)]
        messages += history
        messages.append(LLMMessage(role: "user", content: user))

        for attempt in 0..<2 {
            do {
                let raw = try await send(messages: messages, json: true)
                guard let data = raw.data(using: .utf8),
                      let decoded = try? JSONDecoder().decode(T.self, from: data) else {
                    return fallback
                }
                return decoded
            } catch {
                if attempt == 0 {
                    try? await Task.sleep(nanoseconds: 800_000_000)
                    continue
                }
                return fallback
            }
        }
        return fallback
    }

    // MARK: - Networking

    private func send(messages: [LLMMessage], json: Bool) async throws -> String {
        guard Config.isGroqConfigured, let url = URL(string: Config.groqBaseURL) else {
            throw LLMError.notConfigured
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(Config.groqAPIKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30

        let body = ChatRequest(
            model: Config.groqModel,
            messages: messages,
            response_format: json ? .init(type: "json_object") : nil
        )
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw LLMError.badResponse
        }

        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = decoded.choices.first?.message.content else {
            throw LLMError.badResponse
        }
        return content
    }

    // MARK: - Wire types

    private struct ChatRequest: Encodable {
        struct ResponseFormat: Encodable { let type: String }
        let model: String
        let messages: [LLMMessage]
        let response_format: ResponseFormat?
    }

    private struct ChatResponse: Decodable {
        struct Choice: Decodable {
            struct Message: Decodable { let content: String }
            let message: Message
        }
        let choices: [Choice]
    }
}
