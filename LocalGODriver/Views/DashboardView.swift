import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var vm: DriverViewModel

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    header
                    onlineToggle
                        .padding(.horizontal, 20)
                        .padding(.top, 16)

                    if let active = vm.activeOrder {
                        ActiveDeliveryCard(order: active)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                    }

                    ordersSection
                        .padding(.top, 24)
                        .padding(.bottom, 100)
                }
            }
            .background(AppTheme.background)
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
        }
    }

    // MARK: - Header
    private var header: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [AppTheme.navy, AppTheme.navyMid], startPoint: .top, endPoint: .bottom)
                .frame(height: 150)
            ZStack {
                Circle().fill(AppTheme.primary.opacity(0.12)).frame(width: 160).offset(x: 120, y: -20)
                Circle().fill(AppTheme.primary.opacity(0.08)).frame(width: 110).offset(x: -110, y: 10)
            }
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("Driver Dashboard").font(.system(size: 13, weight: .medium)).foregroundColor(.white.opacity(0.6))
                    HStack(spacing: 6) {
                        ZStack {
                            Circle().fill(AppTheme.primary).frame(width: 26, height: 26)
                            Image(systemName: "bicycle").font(.system(size: 12)).foregroundColor(.white)
                        }
                        Text("LocalGO").font(.system(size: 22, weight: .black)).foregroundColor(.white).kerning(-0.5)
                    }
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "$%.2f", vm.earningsToday))
                        .font(.system(size: 22, weight: .black)).foregroundColor(AppTheme.primary)
                    Text("today").font(.system(size: 12)).foregroundColor(.white.opacity(0.6))
                }
            }
            .padding(.horizontal, 20).padding(.bottom, 20).padding(.top, 55)
        }
    }

    // MARK: - Online toggle
    private var onlineToggle: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle().fill((vm.isOnline ? AppTheme.green : AppTheme.textSecondary).opacity(0.15)).frame(width: 46, height: 46)
                Circle().fill(vm.isOnline ? AppTheme.green : AppTheme.textSecondary).frame(width: 14, height: 14)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(vm.isOnline ? "You're Online" : "You're Offline")
                    .font(.system(size: 16, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                Text(vm.isOnline ? "Receiving delivery requests" : "Go online to start earning")
                    .font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
            }
            Spacer()
            Toggle("", isOn: Binding(
                get: { vm.isOnline },
                set: { $0 ? vm.goOnline() : vm.goOffline() }
            ))
            .labelsHidden()
            .tint(AppTheme.green)
        }
        .padding(16)
        .cardStyle()
    }

    // MARK: - Orders
    private var ordersSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("Available Deliveries")
                    .font(.system(size: 19, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                Spacer()
                if !vm.availableOrders.isEmpty {
                    Text("\(vm.availableOrders.count)")
                        .font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                        .padding(.horizontal, 9).padding(.vertical, 3)
                        .background(AppTheme.primary, in: Capsule())
                }
            }
            .padding(.horizontal, 20)

            if !vm.isOnline {
                emptyState(icon: "moon.zzz.fill", title: "You're offline", subtitle: "Toggle online to see delivery requests")
            } else if vm.activeOrder != nil {
                emptyState(icon: "checkmark.circle.fill", title: "Finish your active delivery", subtitle: "New requests appear once you're done")
            } else if vm.availableOrders.isEmpty {
                emptyState(icon: "tray.fill", title: "No deliveries right now", subtitle: "Hang tight — new orders come in fast")
            } else {
                ForEach(vm.availableOrders) { order in
                    AvailableOrderCard(order: order)
                        .padding(.horizontal, 20)
                }
            }
        }
    }

    private func emptyState(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle().fill(AppTheme.primary.opacity(0.08)).frame(width: 90, height: 90)
                Image(systemName: icon).font(.system(size: 36)).foregroundColor(AppTheme.primary.opacity(0.5))
            }
            Text(title).font(.system(size: 17, weight: .bold)).foregroundColor(AppTheme.textPrimary)
            Text(subtitle).font(.system(size: 14)).foregroundColor(AppTheme.textSecondary).multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40).padding(.horizontal, 20)
    }
}

// MARK: - Available order card
struct AvailableOrderCard: View {
    let order: DeliveryOrder
    @EnvironmentObject private var vm: DriverViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(order.restaurantName).font(.system(size: 17, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                    Text("Order \(order.orderNumber) · \(order.itemCount) items").font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "$%.2f", order.payout)).font(.system(size: 20, weight: .black)).foregroundColor(AppTheme.green)
                    Text("payout").font(.system(size: 11)).foregroundColor(AppTheme.textSecondary)
                }
            }

            routeRow(icon: "fork.knife", color: AppTheme.primary, label: "Pickup", value: order.pickupAddress)
            routeRow(icon: "house.fill", color: AppTheme.navy, label: "Dropoff", value: order.dropoffAddress)

            HStack(spacing: 16) {
                Label(String(format: "%.1f km", order.distanceKm), systemImage: "location.fill")
                    .font(.system(size: 13, weight: .medium)).foregroundColor(AppTheme.textSecondary)
                Label(String(format: "$%.2f order", order.orderTotal), systemImage: "bag")
                    .font(.system(size: 13, weight: .medium)).foregroundColor(AppTheme.textSecondary)
            }

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { vm.accept(order) }
            } label: {
                Text("Accept Delivery").font(.system(size: 16, weight: .bold)).primaryButtonStyle()
            }
        }
        .padding(16)
        .cardStyle()
    }

    private func routeRow(icon: String, color: Color, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8).fill(color.opacity(0.12)).frame(width: 34, height: 34)
                Image(systemName: icon).font(.system(size: 14)).foregroundColor(color)
            }
            VStack(alignment: .leading, spacing: 1) {
                Text(label).font(.system(size: 11, weight: .medium)).foregroundColor(AppTheme.textSecondary)
                Text(value).font(.system(size: 14, weight: .medium)).foregroundColor(AppTheme.textPrimary).lineLimit(1)
            }
            Spacer()
        }
    }
}
