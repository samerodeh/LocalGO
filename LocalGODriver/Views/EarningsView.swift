import SwiftUI

struct EarningsView: View {
    @EnvironmentObject private var vm: DriverViewModel

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    summaryCard.padding(.top, 8)
                    statsRow
                    completedSection
                        .padding(.bottom, 60)
                }
                .padding(.horizontal, 20)
            }
            .background(AppTheme.background)
            .navigationTitle("Earnings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 8) {
            Text("Today's Earnings").font(.system(size: 14, weight: .medium)).foregroundColor(.white.opacity(0.7))
            Text(String(format: "$%.2f", vm.earningsToday)).font(.system(size: 44, weight: .black)).foregroundColor(.white)
            Text("\(vm.deliveriesToday) deliveries completed").font(.system(size: 14)).foregroundColor(AppTheme.primary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(LinearGradient(colors: [AppTheme.navy, AppTheme.navyMid], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
    }

    private var statsRow: some View {
        HStack(spacing: 14) {
            statBox(icon: "shippingbox.fill", value: "\(vm.deliveriesToday)", label: "Deliveries", color: AppTheme.primary)
            statBox(icon: "dollarsign.circle.fill",
                    value: vm.deliveriesToday > 0 ? String(format: "$%.2f", vm.earningsToday / Double(vm.deliveriesToday)) : "$0.00",
                    label: "Avg / trip", color: AppTheme.green)
        }
    }

    private func statBox(icon: String, value: String, label: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon).font(.system(size: 24)).foregroundColor(color)
            Text(value).font(.system(size: 22, weight: .black)).foregroundColor(AppTheme.textPrimary)
            Text(label).font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .cardStyle()
    }

    private var completedSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Completed Today").font(.system(size: 18, weight: .bold)).foregroundColor(AppTheme.textPrimary)
            if vm.completedToday.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "list.bullet.clipboard").font(.system(size: 32)).foregroundColor(AppTheme.textSecondary.opacity(0.4))
                    Text("No completed deliveries yet").font(.system(size: 14)).foregroundColor(AppTheme.textSecondary)
                }
                .frame(maxWidth: .infinity).padding(.vertical, 40).cardStyle()
            } else {
                VStack(spacing: 0) {
                    ForEach(vm.completedToday) { order in
                        HStack {
                            ZStack {
                                Circle().fill(AppTheme.green.opacity(0.15)).frame(width: 38, height: 38)
                                Image(systemName: "checkmark").font(.system(size: 15, weight: .bold)).foregroundColor(AppTheme.green)
                            }
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(order.restaurantName) · \(order.orderNumber)").font(.system(size: 14, weight: .semibold)).foregroundColor(AppTheme.textPrimary)
                                Text(order.customerName).font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
                            }
                            Spacer()
                            Text(String(format: "+$%.2f", order.payout)).font(.system(size: 15, weight: .bold)).foregroundColor(AppTheme.green)
                        }
                        .padding(.horizontal, 16).padding(.vertical, 13)
                        if order.id != vm.completedToday.last?.id { Divider().padding(.horizontal, 16) }
                    }
                }
                .cardStyle()
            }
        }
    }
}
