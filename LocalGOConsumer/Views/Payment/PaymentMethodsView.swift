import SwiftUI

struct PaymentMethodsView: View {
    @EnvironmentObject private var payment: PaymentService
    @EnvironmentObject private var auth: AuthService
    var selectable: Bool = false
    @Environment(\.dismiss) private var dismiss

    @State private var showAddCard = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                if payment.methods.isEmpty {
                    emptyState
                } else {
                    ForEach(payment.methods) { method in
                        methodRow(method)
                    }
                }

                Button { showAddCard = true } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "plus")
                        Text("Add Payment Method").font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(AppTheme.primary)
                    .frame(maxWidth: .infinity).padding(.vertical, 16)
                    .background(AppTheme.primary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(AppTheme.primary.opacity(0.4), style: StrokeStyle(lineWidth: 1.5, dash: [6])))
                }
                .padding(.top, 4)

                Text("Card details are validated and tokenized — your full card number is never stored on the device.")
                    .font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center).padding(.top, 8).padding(.horizontal, 12)
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle("Payment Methods")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddCard) {
            AddCardView().environmentObject(payment)
        }
        .onAppear { payment.load(for: auth.currentUser?.id) }
    }

    private func methodRow(_ method: PaymentMethod) -> some View {
        Button {
            if selectable {
                payment.selectedMethodId = method.id
                dismiss()
            }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(AppTheme.navy).frame(width: 46, height: 32)
                    Image(systemName: "creditcard.fill").font(.system(size: 14)).foregroundColor(.white)
                }
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(method.displayName).font(.system(size: 15, weight: .semibold)).foregroundColor(AppTheme.textPrimary)
                        if method.isDefault {
                            Text("Default").font(.system(size: 10, weight: .bold)).foregroundColor(AppTheme.primary)
                                .padding(.horizontal, 6).padding(.vertical, 2)
                                .background(AppTheme.primary.opacity(0.12), in: Capsule())
                        }
                    }
                    Text("Expires \(method.expiry)").font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
                if selectable && payment.selectedMethod?.id == method.id {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(AppTheme.primary)
                } else {
                    Menu {
                        if !method.isDefault {
                            Button("Set as Default") { payment.setDefault(method) }
                        }
                        Button("Remove", role: .destructive) { payment.delete(method) }
                    } label: {
                        Image(systemName: "ellipsis").foregroundColor(AppTheme.textSecondary)
                            .frame(width: 32, height: 32)
                    }
                }
            }
            .padding(16).cardStyle()
        }
        .buttonStyle(.plain)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "creditcard").font(.system(size: 40)).foregroundColor(AppTheme.primary.opacity(0.4))
            Text("No payment methods yet").font(.system(size: 16, weight: .bold)).foregroundColor(AppTheme.textPrimary)
            Text("Add a card to check out faster.").font(.system(size: 14)).foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 40)
    }
}
