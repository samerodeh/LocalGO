import SwiftUI
import StripePaymentSheet

struct CheckoutView: View {
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var recEngine: RecommendationEngine
    @EnvironmentObject private var orderService: OrderService
    @EnvironmentObject private var paymentService: PaymentService
    @EnvironmentObject private var auth: AuthService
    @StateObject private var vm = CheckoutViewModel()

    @State private var placedOrder: Order? = nil
    @State private var showTracking = false
    @State private var showLocationPicker = false
    @State private var showPaymentMethods = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    private var restaurant: Restaurant? {
        RestaurantData.all.first(where: { $0.id == cartVM.currentRestaurantId })
    }
    private var addressSet: Bool { !vm.deliveryAddress.trimmingCharacters(in: .whitespaces).isEmpty }
    private var canPlace: Bool { addressSet && paymentService.selectedMethod != nil && !vm.isLoading }

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
            .alert("Checkout", isPresented: Binding(
                get: { errorMessage != nil }, set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK") { errorMessage = nil }
            } message: { Text(errorMessage ?? "") }
            .sheet(isPresented: $showLocationPicker) {
                LocationPickerView { vm.deliveryAddress = $0 }
            }
            .sheet(isPresented: $showPaymentMethods) {
                NavigationStack { PaymentMethodsView(selectable: true) }
            }
            .fullScreenCover(isPresented: $showTracking, onDismiss: { dismiss() }) {
                if let order = placedOrder { OrderTrackingView(order: order) }
            }
            .onAppear { paymentService.load(for: auth.currentUser?.id) }
        }
    }

    // MARK: - Delivery (map picker)
    private var deliverySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Delivery Address")
            VStack(spacing: 10) {
                Button { showLocationPicker = true } label: {
                    HStack(spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10).fill(AppTheme.primary.opacity(0.12)).frame(width: 42, height: 42)
                            Image(systemName: "map.fill").foregroundColor(AppTheme.primary)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(addressSet ? "Deliver to" : "Set your location")
                                .font(.system(size: 12, weight: .medium)).foregroundColor(AppTheme.textSecondary)
                            Text(addressSet ? vm.deliveryAddress : "Pick on the map")
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(addressSet ? AppTheme.textPrimary : AppTheme.primary)
                                .lineLimit(2).multilineTextAlignment(.leading)
                        }
                        Spacer()
                        Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(AppTheme.textSecondary.opacity(0.5))
                    }
                    .padding(16).cardStyle()
                }
                .buttonStyle(.plain)

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

    // MARK: - Payment (selectable)
    private var paymentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Payment")
            Button { showPaymentMethods = true } label: {
                HStack(spacing: 14) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8).fill(AppTheme.navy).frame(width: 46, height: 32)
                        Image(systemName: "creditcard.fill").font(.system(size: 14)).foregroundColor(.white)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        if let m = paymentService.selectedMethod {
                            Text(m.displayName).font(.system(size: 15, weight: .semibold)).foregroundColor(AppTheme.textPrimary)
                            Text("Expires \(m.expiry)").font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
                        } else {
                            Text("Add a payment method").font(.system(size: 15, weight: .semibold)).foregroundColor(AppTheme.primary)
                            Text("Required to place your order").font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
                        }
                    }
                    Spacer()
                    Image(systemName: "chevron.right").font(.system(size: 13, weight: .semibold)).foregroundColor(AppTheme.textSecondary.opacity(0.5))
                }
                .padding(16).cardStyle()
                .overlay(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous)
                    .stroke(AppTheme.primary.opacity(0.3), lineWidth: 1.5))
            }
            .buttonStyle(.plain)
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
            .primaryButtonStyle(disabled: !canPlace)
        }
        .disabled(!canPlace)
    }

    private func sectionHeader(_ t: String) -> some View {
        Text(t).font(.system(size: 17, weight: .bold)).foregroundColor(AppTheme.textPrimary).padding(.horizontal, 20)
    }

    // MARK: - Order flow
    private func handleOrder() {
        guard addressSet else { errorMessage = "Please set your delivery address."; return }
        guard paymentService.selectedMethod != nil else { errorMessage = "Please add a payment method."; return }

        if Config.isStripeConfigured {
            payWithStripe()
        } else {
            // No backend configured → authorize locally so the full flow works.
            finalizeOrder()
        }
    }

    private func finalizeOrder() {
        guard let r = restaurant else { return }
        vm.isLoading = true
        let order = orderService.placeOrder(
            userId: auth.currentUser?.id,
            items: cartVM.items,
            restaurant: r,
            address: vm.deliveryAddress,
            total: cartVM.total,
            payment: paymentService.selectedMethod
        )
        recEngine.recordOrder(cartVM.items)   // feed the order back into rankings
        placedOrder = order
        cartVM.clearCart()
        vm.isLoading = false
        showTracking = true
    }

    private func payWithStripe() {
        Task {
            await vm.preparePayment(amountCents: Int(cartVM.total * 100))
            guard let sheet = vm.paymentSheet else {
                errorMessage = vm.errorMessage ?? "Couldn't start payment."
                return
            }
            await MainActor.run {
                guard let vc = UIApplication.shared.topKeyWindowViewController else { return }
                sheet.present(from: vc) { result in
                    switch result {
                    case .completed: finalizeOrder()
                    case .failed(let err): errorMessage = err.localizedDescription
                    case .canceled: break
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
