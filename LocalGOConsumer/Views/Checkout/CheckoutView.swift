import SwiftUI
import StripePaymentSheet

struct CheckoutView: View {
    @EnvironmentObject private var cartVM: CartViewModel
    @StateObject private var vm = CheckoutViewModel()
    @StateObject private var orderSvc = OrderService()
    @State private var placedOrder: Order? = nil
    @State private var showTracking = false
    @Environment(\.dismiss) private var dismiss

    private var restaurant: Restaurant? {
        RestaurantData.all.first(where: { $0.id == cartVM.currentRestaurantId })
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 20) {
                        deliverySection
                        orderItemsSection
                        priceSection
                        paymentSection
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 110)
                }
                .background(AppTheme.background)

                placeOrderButton.padding(20)
            }
            .navigationTitle("Checkout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark").foregroundColor(AppTheme.textSecondary)
                    }
                }
            }
            .alert("Payment Error", isPresented: Binding(
                get: { vm.errorMessage != nil },
                set: { if !$0 { vm.errorMessage = nil } }
            )) {
                Button("OK") { vm.errorMessage = nil }
            } message: {
                Text(vm.errorMessage ?? "")
            }
            .fullScreenCover(isPresented: $showTracking) {
                if let order = placedOrder {
                    OrderTrackingView(order: order)
                }
            }
        }
    }

    // MARK: - Delivery
    private var deliverySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Delivery Address")
            VStack(spacing: 10) {
                field(icon: "mappin.circle.fill", placeholder: "Enter delivery address", text: $vm.deliveryAddress)
                field(icon: "note.text", placeholder: "Delivery instructions (optional)", text: $vm.deliveryInstructions)
            }
            .padding(.horizontal, 20)
        }
    }

    private func field(icon: String, placeholder: String, text: Binding<String>) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.system(size: 20)).foregroundColor(AppTheme.primary)
            TextField(placeholder, text: text).font(.system(size: 15))
        }
        .padding(16).cardStyle()
    }

    // MARK: - Items
    private var orderItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Your Order")
            VStack(spacing: 0) {
                ForEach(cartVM.items) { ci in
                    HStack {
                        Text("\(ci.quantity)×").font(.system(size: 14, weight: .semibold)).foregroundColor(AppTheme.primary).frame(width: 26)
                        Text(ci.item.name).font(.system(size: 14)).foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text(String(format: "$%.2f", ci.lineTotal)).font(.system(size: 14, weight: .semibold)).foregroundColor(AppTheme.textPrimary)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    if ci.id != cartVM.items.last?.id { Divider().padding(.horizontal, 16) }
                }
            }
            .cardStyle()
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Price
    private var priceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Price Details")
            VStack(spacing: 0) {
                priceRow("Subtotal",    String(format: "$%.2f", cartVM.subtotal))
                Divider().padding(.horizontal, 16)
                priceRow("Delivery",   String(format: "$%.2f", cartVM.deliveryFee))
                Divider().padding(.horizontal, 16)
                priceRow("Tax & fees", String(format: "$%.2f", cartVM.tax))
                Divider().padding(.horizontal, 16)
                HStack {
                    Text("Total").font(.system(size: 16, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    Text(String(format: "$%.2f", cartVM.total)).font(.system(size: 18, weight: .black)).foregroundColor(AppTheme.primary)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
            }
            .cardStyle()
            .padding(.horizontal, 20)
        }
    }

    private func priceRow(_ t: String, _ v: String) -> some View {
        HStack {
            Text(t).font(.system(size: 14)).foregroundColor(AppTheme.textSecondary)
            Spacer()
            Text(v).font(.system(size: 14, weight: .semibold)).foregroundColor(AppTheme.textPrimary)
        }
        .padding(.horizontal, 16).padding(.vertical, 12)
    }

    // MARK: - Payment
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Payment")
            HStack(spacing: 14) {
                Image(systemName: "creditcard.fill").font(.system(size: 22)).foregroundColor(AppTheme.navy)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Pay by Card").font(.system(size: 15, weight: .semibold)).foregroundColor(AppTheme.textPrimary)
                    Text("Secure payment powered by Stripe").font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
                Image(systemName: "checkmark.circle.fill").foregroundColor(AppTheme.primary)
            }
            .padding(16)
            .cardStyle()
            .overlay(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous).stroke(AppTheme.primary.opacity(0.3), lineWidth: 1.5))
            .padding(.horizontal, 20)
        }
    }

    // MARK: - CTA
    private var placeOrderButton: some View {
        Button { handleOrder() } label: {
            HStack(spacing: 10) {
                if vm.isLoading {
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white)).scaleEffect(0.9)
                } else {
                    Image(systemName: "lock.fill").font(.system(size: 14))
                    Text(String(format: "Place Order  ·  $%.2f", cartVM.total)).font(.system(size: 17, weight: .bold))
                }
            }
            .primaryButtonStyle(disabled: vm.isLoading || vm.deliveryAddress.trimmingCharacters(in: .whitespaces).isEmpty)
        }
        .disabled(vm.isLoading || vm.deliveryAddress.trimmingCharacters(in: .whitespaces).isEmpty)
    }

    private func sectionHeader(_ t: String) -> some View {
        Text(t).font(.system(size: 17, weight: .bold)).foregroundColor(AppTheme.textPrimary).padding(.horizontal, 20)
    }

    // MARK: - Order flow
    private func handleOrder() {
        Task {
            await vm.preparePayment(amountCents: Int(cartVM.total * 100))
            guard let sheet = vm.paymentSheet else { return }

            await MainActor.run {
                guard let vc = UIApplication.shared.topKeyWindowViewController else { return }
                sheet.present(from: vc) { result in
                    switch result {
                    case .completed:
                        guard let r = restaurant else { return }
                        let order = orderSvc.placeOrder(
                            items: cartVM.items,
                            restaurant: r,
                            address: vm.deliveryAddress,
                            total: cartVM.total
                        )
                        placedOrder = order
                        cartVM.clearCart()
                        showTracking = true
                    case .failed(let err):
                        vm.errorMessage = err.localizedDescription
                    case .canceled:
                        break
                    }
                }
            }
        }
    }
}

// MARK: - UIApplication helper
extension UIApplication {
    var topKeyWindowViewController: UIViewController? {
        guard let windowScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else { return nil }
        var top = window.rootViewController
        while let presented = top?.presentedViewController { top = presented }
        return top
    }
}
