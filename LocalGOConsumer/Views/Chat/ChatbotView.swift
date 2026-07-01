import SwiftUI

/// The AI assistant screen — a chat interface backed by the multi-agent pipeline.
struct ChatbotView: View {
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var recEngine: RecommendationEngine
    @EnvironmentObject private var orderService: OrderService
    @EnvironmentObject private var auth: AuthService

    @StateObject private var vm = ChatViewModel()
    @FocusState private var inputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                transcript
                inputBar
            }
            .background(AppTheme.background.ignoresSafeArea())
            .navigationTitle("Assistant")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Transcript

    private var transcript: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(vm.messages) { message in
                        ChatBubble(message: message)
                            .id(message.id)
                    }

                    if vm.isResponding {
                        HStack {
                            TypingIndicator()
                            Spacer()
                        }
                        .id("typing")
                    }

                    if vm.showStarters {
                        starterChips
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
            .onChange(of: vm.messages.count) { _ in
                withAnimation { proxy.scrollTo(vm.messages.last?.id, anchor: .bottom) }
            }
            .onChange(of: vm.isResponding) { responding in
                if responding { withAnimation { proxy.scrollTo("typing", anchor: .bottom) } }
            }
        }
    }

    private var starterChips: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(vm.starters, id: \.self) { starter in
                Button {
                    vm.sendStarter(starter, cart: cartVM, recEngine: recEngine, orderService: orderService, auth: auth)
                } label: {
                    Text(starter)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(AppTheme.primary)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(AppTheme.primary.opacity(0.10))
                        .clipShape(Capsule())
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 4)
    }

    // MARK: - Input bar

    private var inputBar: some View {
        HStack(spacing: 10) {
            TextField("Ask about the menu, order, or more…", text: $vm.inputText, axis: .vertical)
                .lineLimit(1...4)
                .focused($inputFocused)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppTheme.buttonRadius, style: .continuous)
                        .stroke(AppTheme.divider, lineWidth: 1)
                )
                .onSubmit(send)

            Button(action: send) {
                Image(systemName: "arrow.up")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 42, height: 42)
                    .background(canSend ? AppTheme.primary : Color.gray.opacity(0.35))
                    .clipShape(Circle())
            }
            .disabled(!canSend)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(AppTheme.surface.ignoresSafeArea(edges: .bottom).shadow(color: .black.opacity(0.05), radius: 8, y: -2))
    }

    private var canSend: Bool {
        !vm.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !vm.isResponding
    }

    private func send() {
        vm.send(cart: cartVM, recEngine: recEngine, orderService: orderService, auth: auth)
    }
}

// MARK: - Bubble

private struct ChatBubble: View {
    let message: ChatMessage

    private var isUser: Bool { message.role == .user }

    var body: some View {
        HStack {
            if isUser { Spacer(minLength: 40) }
            Text(message.text)
                .font(.body)
                .foregroundColor(isUser ? .white : AppTheme.textPrimary)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(isUser ? AppTheme.primary : AppTheme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(isUser ? Color.clear : AppTheme.divider, lineWidth: 1)
                )
                .textSelection(.enabled)
            if !isUser { Spacer(minLength: 40) }
        }
    }
}

// MARK: - Typing indicator

private struct TypingIndicator: View {
    @State private var phase = 0.0

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { i in
                Circle()
                    .fill(AppTheme.textSecondary)
                    .frame(width: 7, height: 7)
                    .opacity(phase == Double(i) ? 1 : 0.3)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(AppTheme.divider, lineWidth: 1)
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: false)) {
                // step the phase 0→1→2 on a timer-free animation proxy
            }
            startCycling()
        }
    }

    private func startCycling() {
        Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { _ in
            phase = (phase + 1).truncatingRemainder(dividingBy: 3)
        }
    }
}
