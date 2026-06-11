import SwiftUI

struct OrderHistoryView: View {
    @EnvironmentObject private var orderService: OrderService
    @EnvironmentObject private var auth: AuthService
    @EnvironmentObject private var cartVM: CartViewModel

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 14) {
                if orderService.orders.isEmpty {
                    emptyState
                } else {
                    ForEach(orderService.orders) { order in
                        orderCard(order)
                    }
                }
            }
            .padding(20)
        }
        .background(AppTheme.background)
        .navigationTitle("Order History")
        .navigationBarTitleDisplayMode(.large)
        .onAppear { orderService.load(for: auth.currentUser?.id) }
    }

    private func orderCard(_ order: OrderRecord) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(order.restaurantName).font(.system(size: 16, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                    Text(order.placedAtFormatted).font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
                Text(String(format: "$%.2f", order.total)).font(.system(size: 16, weight: .black)).foregroundColor(AppTheme.primary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 6) {
                ForEach(order.lines) { line in
                    HStack {
                        Text("\(line.quantity)×").font(.system(size: 13, weight: .semibold)).foregroundColor(AppTheme.primary).frame(width: 26, alignment: .leading)
                        Text(line.itemName).font(.system(size: 13)).foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text(String(format: "$%.2f", line.lineTotal)).font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
                    }
                }
            }

            if let brand = order.paymentBrand, let last4 = order.paymentLast4 {
                Label("\(brand) •••• \(last4)", systemImage: "creditcard.fill")
                    .font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
            }

            Button { reorder(order) } label: {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise")
                    Text("Order Again").font(.system(size: 15, weight: .bold))
                }
                .foregroundColor(.white).frame(maxWidth: .infinity).padding(.vertical, 12)
                .background(AppTheme.primary).clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
        }
        .padding(16).cardStyle()
    }

    private func reorder(_ order: OrderRecord) {
        let menu = RestaurantData.altaib.categories.flatMap(\.items)
        let byName = Dictionary(menu.map { ($0.name, $0) }, uniquingKeysWith: { a, _ in a })
        for line in order.lines {
            guard let item = byName[line.itemName] else { continue }
            for _ in 0..<line.quantity { cartVM.addItem(item, restaurant: RestaurantData.altaib) }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "clock.arrow.circlepath").font(.system(size: 40)).foregroundColor(AppTheme.primary.opacity(0.4))
            Text("No orders yet").font(.system(size: 16, weight: .bold)).foregroundColor(AppTheme.textPrimary)
            Text("Your past orders will appear here.").font(.system(size: 14)).foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity).padding(.vertical, 60)
    }
}
