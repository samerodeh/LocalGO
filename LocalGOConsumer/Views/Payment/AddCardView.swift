import SwiftUI

struct AddCardView: View {
    @EnvironmentObject private var payment: PaymentService
    @Environment(\.dismiss) private var dismiss

    @State private var number = ""
    @State private var expiry = ""
    @State private var cvc = ""
    @State private var error: String?

    private var brand: String { CardValidator.brand(for: number) }
    private var canSave: Bool {
        CardValidator.luhnValid(number) && expiry.count == 5 && cvc.count >= 3
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 18) {
                    cardPreview

                    VStack(spacing: 14) {
                        // Card number
                        HStack(spacing: 12) {
                            Image(systemName: "creditcard.fill").foregroundColor(AppTheme.primary).frame(width: 22)
                            TextField("Card number", text: $number)
                                .keyboardType(.numberPad).font(.system(size: 15))
                                .onChange(of: number) { number = CardValidator.formatNumber($0) }
                            Text(brand).font(.system(size: 12, weight: .bold)).foregroundColor(AppTheme.textSecondary)
                        }
                        .padding(16).cardStyle()

                        HStack(spacing: 12) {
                            // Expiry
                            HStack(spacing: 10) {
                                Image(systemName: "calendar").foregroundColor(AppTheme.primary).frame(width: 22)
                                TextField("MM/YY", text: $expiry)
                                    .keyboardType(.numberPad).font(.system(size: 15))
                                    .onChange(of: expiry) { expiry = formatExpiry($0) }
                            }
                            .padding(16).cardStyle()

                            // CVC
                            HStack(spacing: 10) {
                                Image(systemName: "lock.fill").foregroundColor(AppTheme.primary).frame(width: 22)
                                SecureField("CVC", text: $cvc)
                                    .keyboardType(.numberPad).font(.system(size: 15))
                                    .onChange(of: cvc) { cvc = String($0.filter(\.isNumber).prefix(4)) }
                            }
                            .padding(16).cardStyle()
                        }
                    }

                    if let error {
                        Text(error).font(.system(size: 13, weight: .medium)).foregroundColor(.red)
                    }

                    Button { save() } label: {
                        Text("Add Card").font(.system(size: 16, weight: .bold)).primaryButtonStyle(disabled: !canSave)
                    }
                    .disabled(!canSave)

                    Label("Your card number is never stored — only the brand, last 4 digits, and expiry.",
                          systemImage: "lock.shield.fill")
                        .font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(20)
            }
            .background(AppTheme.background)
            .navigationTitle("Add Card")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: { Image(systemName: "xmark").foregroundColor(AppTheme.textSecondary) }
                }
            }
        }
    }

    private var cardPreview: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(LinearGradient(colors: [AppTheme.navy, AppTheme.navyMid], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(height: 180)
                .shadow(color: .black.opacity(0.18), radius: 14, y: 8)
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Image(systemName: "wave.3.right").foregroundColor(.white.opacity(0.7))
                    Spacer()
                    Text(brand).font(.system(size: 16, weight: .black)).foregroundColor(.white)
                }
                Spacer()
                Text(number.isEmpty ? "•••• •••• •••• ••••" : number)
                    .font(.system(size: 20, weight: .semibold, design: .monospaced)).foregroundColor(.white)
                Spacer()
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("EXPIRES").font(.system(size: 9, weight: .semibold)).foregroundColor(.white.opacity(0.5))
                        Text(expiry.isEmpty ? "MM/YY" : expiry).font(.system(size: 14, weight: .semibold)).foregroundColor(.white)
                    }
                    Spacer()
                    Image(systemName: "location.fill").foregroundColor(AppTheme.primary)
                }
            }
            .padding(20)
            .frame(height: 180)
        }
    }

    private func formatExpiry(_ input: String) -> String {
        let digits = String(input.filter(\.isNumber).prefix(4))
        if digits.count <= 2 { return digits }
        let mm = digits.prefix(2)
        let yy = digits.dropFirst(2)
        return "\(mm)/\(yy)"
    }

    private func save() {
        let digits = number.filter(\.isNumber)
        guard CardValidator.luhnValid(number) else { error = "That card number doesn't look valid."; return }
        let comps = expiry.split(separator: "/")
        guard comps.count == 2, let mm = Int(comps[0]), let yy = Int(comps[1]), (1...12).contains(mm) else {
            error = "Enter a valid expiry date."; return
        }
        payment.addCard(brand: brand, last4: String(digits.suffix(4)), expMonth: mm, expYear: 2000 + yy)
        dismiss()
    }
}
