import SwiftUI

struct CartView: View {
    var isModal: Bool = false
    @EnvironmentObject private var cartVM: CartViewModel
    @State private var showCheckout = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Group {
                if cartVM.items.isEmpty { emptyState } else { filledCart }
            }
            .navigationTitle("Your Cart")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                if isModal {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button { dismiss() } label: {
                            Image(systemName: "xmark").foregroundColor(AppTheme.textSecondary)
                        }
                    }
                }
                if !cartVM.items.isEmpty {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Clear") { cartVM.clearCart() }
                            .foregroundColor(.red.opacity(0.75))
                            .font(.system(size: 14))
                    }
                }
            }
            .sheet(isPresented: $showCheckout) { CheckoutView() }
        }
    }

    // MARK: - Empty
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle().fill(AppTheme.primary.opacity(0.08)).frame(width: 120, height: 120)
                Image(systemName: "cart").font(.system(size: 48)).foregroundColor(AppTheme.primary.opacity(0.4))
            }
            Text("Your cart is empty").font(.system(size: 20, weight: .bold)).foregroundColor(AppTheme.textPrimary)
            Text("Add items from a restaurant to get started")
                .font(.system(size: 15)).foregroundColor(AppTheme.textSecondary).multilineTextAlignment(.center)
            Spacer()
        }
        .padding(32)
        .background(AppTheme.background)
    }

    // MARK: - Filled
    private var filledCart: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    restaurantHeader
                    itemList
                    promoRow
                    summaryCard
                        .padding(.bottom, 110)
                }
                .padding(.top, 8)
            }
            .background(AppTheme.background)

            checkoutBtn.padding(20)
        }
    }

    private var restaurantHeader: some View {
        Group {
            if let rid = cartVM.currentRestaurantId,
               let r = RestaurantData.all.first(where: { $0.id == rid }) {
                HStack(spacing: 14) {
                    Text("🫓").font(.system(size: 30))
                        .frame(width: 54, height: 54)
                        .background(AppTheme.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(alignment: .leading, spacing: 3) {
                        Text(r.name).font(.system(size: 16, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                        Text(r.address).font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                }
                .padding(16)
                .cardStyle()
                .padding(.horizontal, 20)
            }
        }
    }

    private var itemList: some View {
        VStack(spacing: 0) {
            ForEach(cartVM.items) { ci in
                CartItemRow(cartItem: ci)
                if ci.id != cartVM.items.last?.id {
                    Divider().padding(.leading, 20)
                }
            }
        }
        .cardStyle()
        .padding(.horizontal, 20)
    }

    private var promoRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "tag.fill").foregroundColor(AppTheme.primary)
            TextField("Promo code", text: $cartVM.promoCode).font(.system(size: 15))
            Button("Apply") {}
                .font(.system(size: 14, weight: .semibold)).foregroundColor(AppTheme.primary)
        }
        .padding(16)
        .cardStyle()
        .padding(.horizontal, 20)
    }

    private var summaryCard: some View {
        VStack(spacing: 0) {
            summaryRow("Subtotal",    String(format: "$%.2f", cartVM.subtotal))
            Divider().padding(.horizontal, 16)
            summaryRow("Delivery fee", String(format: "$%.2f", cartVM.deliveryFee))
            Divider().padding(.horizontal, 16)
            summaryRow("Tax & fees",  String(format: "$%.2f", cartVM.tax))
            if cartVM.promoDiscount > 0 {
                Divider().padding(.horizontal, 16)
                summaryRow("Discount", String(format: "-$%.2f", cartVM.promoDiscount), valueColor: .green)
            }
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

    private func summaryRow(_ title: String, _ value: String, valueColor: Color = AppTheme.textPrimary) -> some View {
        HStack {
            Text(title).font(.system(size: 14)).foregroundColor(AppTheme.textSecondary)
            Spacer()
            Text(value).font(.system(size: 14, weight: .semibold)).foregroundColor(valueColor)
        }
        .padding(.horizontal, 16).padding(.vertical, 13)
    }

    private var checkoutBtn: some View {
        Button { showCheckout = true } label: {
            HStack {
                Text("Go to Checkout").font(.system(size: 17, weight: .bold))
                Spacer()
                Text(String(format: "$%.2f", cartVM.total)).font(.system(size: 17, weight: .bold))
            }
            .primaryButtonStyle()
        }
    }
}
