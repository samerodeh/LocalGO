import SwiftUI

struct ActiveDeliveryCard: View {
    let order: DeliveryOrder
    @EnvironmentObject private var vm: DriverViewModel

    private var progressStep: Int {
        switch order.status {
        case .accepted: return 1
        case .pickedUp: return 2
        case .delivered: return 3
        default: return 0
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Status banner
            HStack(spacing: 10) {
                Image(systemName: order.status.icon).font(.system(size: 16)).foregroundColor(.white)
                Text(order.status.rawValue).font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                Spacer()
                Text(order.orderNumber).font(.system(size: 13, weight: .medium)).foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
            .background(LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark], startPoint: .leading, endPoint: .trailing))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            // Progress bar
            HStack(spacing: 6) {
                ForEach(0..<3) { i in
                    Capsule()
                        .fill(i < progressStep ? AppTheme.primary : Color(UIColor.systemGray5))
                        .frame(height: 5)
                }
            }

            // Route
            VStack(alignment: .leading, spacing: 12) {
                routeStop(icon: "fork.knife", color: AppTheme.primary, label: "Pick up from",
                          name: order.restaurantName, address: order.pickupAddress,
                          done: progressStep >= 2)
                routeStop(icon: "person.fill", color: AppTheme.navy, label: "Deliver to",
                          name: order.customerName, address: order.dropoffAddress,
                          done: progressStep >= 3)
            }

            // Items
            VStack(alignment: .leading, spacing: 6) {
                Text("Order items").font(.system(size: 12, weight: .semibold)).foregroundColor(AppTheme.textSecondary)
                ForEach(order.summaryItems, id: \.self) { item in
                    HStack(spacing: 8) {
                        Image(systemName: "circle.fill").font(.system(size: 5)).foregroundColor(AppTheme.primary)
                        Text(item).font(.system(size: 14)).foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(AppTheme.background)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            // Advance button
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { vm.advanceActiveOrder() }
            } label: {
                Text(order.status.actionTitle).font(.system(size: 16, weight: .bold)).primaryButtonStyle()
            }

            if order.status == .accepted {
                Button { withAnimation { vm.cancelActiveOrder() } } label: {
                    Text("Cancel").font(.system(size: 14, weight: .medium)).foregroundColor(.red.opacity(0.7))
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(16)
        .cardStyle()
    }

    private func routeStop(icon: String, color: Color, label: String, name: String, address: String, done: Bool) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle().fill(done ? AppTheme.green.opacity(0.15) : color.opacity(0.12)).frame(width: 40, height: 40)
                Image(systemName: done ? "checkmark" : icon).font(.system(size: 15, weight: .semibold)).foregroundColor(done ? AppTheme.green : color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(AppTheme.textSecondary)
                Text(name).font(.system(size: 15, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                Text(address).font(.system(size: 13)).foregroundColor(AppTheme.textSecondary).lineLimit(1)
            }
            Spacer()
        }
    }
}
