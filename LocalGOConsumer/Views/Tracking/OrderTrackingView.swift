import SwiftUI

struct OrderTrackingView: View {
    let order: Order
    @State private var currentStep = 0
    @Environment(\.dismiss) private var dismiss

    private static let steps = Order.Status.allCases

    var body: some View {
        VStack(spacing: 0) {
            // Hero
            ZStack {
                LinearGradient(colors: [AppTheme.navy, AppTheme.navyMid], startPoint: .top, endPoint: .bottom)
                VStack(spacing: 14) {
                    ZStack {
                        Circle().fill(AppTheme.primary.opacity(0.2)).frame(width: 100, height: 100)
                        Image(systemName: "bag.fill").font(.system(size: 44)).foregroundColor(AppTheme.primary)
                    }
                    Text("Order Confirmed!").font(.system(size: 26, weight: .black)).foregroundColor(.white)
                    Text("Sit tight — your food is on its way!").font(.system(size: 15)).foregroundColor(.white.opacity(0.65))

                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill").font(.system(size: 13))
                        Text(etaString).font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundColor(AppTheme.navy)
                    .padding(.horizontal, 18).padding(.vertical, 10)
                    .background(AppTheme.primary, in: Capsule())
                }
                .padding(.top, 70).padding(.bottom, 40)
            }
            .frame(height: 300)
            .ignoresSafeArea(edges: .top)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Steps
                    VStack(spacing: 0) {
                        ForEach(Array(Self.steps.enumerated()), id: \.offset) { i, status in
                            TrackingStep(
                                title: status.rawValue,
                                subtitle: status.subtitle,
                                icon: status.icon,
                                isCompleted: i <= currentStep,
                                isActive: i == currentStep,
                                isLast: i == Self.steps.count - 1
                            )
                        }
                    }
                    .padding(.horizontal, 24).padding(.top, 28)

                    Divider().padding(.vertical, 24).padding(.horizontal, 20)

                    // Order items
                    orderSummary.padding(.horizontal, 20)

                    // Done
                    Button { dismiss() } label: {
                        Text("Done").font(.system(size: 17, weight: .bold)).primaryButtonStyle()
                    }
                    .padding(.horizontal, 20).padding(.top, 24).padding(.bottom, 48)
                }
            }
        }
        .onAppear { animateSteps() }
    }

    private var etaString: String {
        let f = DateFormatter(); f.timeStyle = .short
        return "Arriving by \(f.string(from: order.estimatedDelivery))"
    }

    private var orderSummary: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Order Summary").font(.system(size: 16, weight: .bold)).foregroundColor(AppTheme.textPrimary)
            VStack(spacing: 0) {
                ForEach(order.items) { ci in
                    HStack {
                        Text("\(ci.quantity)×").font(.system(size: 14, weight: .semibold)).foregroundColor(AppTheme.primary)
                        Text(ci.item.name).font(.system(size: 14)).foregroundColor(AppTheme.textPrimary)
                        Spacer()
                        Text(String(format: "$%.2f", ci.lineTotal)).font(.system(size: 14, weight: .semibold)).foregroundColor(AppTheme.textPrimary)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 12)
                    if ci.id != order.items.last?.id { Divider().padding(.horizontal, 16) }
                }
                Divider().padding(.horizontal, 16)
                HStack {
                    Text("Total paid").font(.system(size: 15, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    Text(String(format: "$%.2f", order.total)).font(.system(size: 16, weight: .black)).foregroundColor(AppTheme.primary)
                }
                .padding(.horizontal, 16).padding(.vertical, 14)
            }
            .cardStyle()
        }
    }

    private func animateSteps() {
        let delays: [Double] = [0, 8, 20, 35]
        for (i, delay) in delays.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { currentStep = i }
            }
        }
    }
}

struct TrackingStep: View {
    let title: String; let subtitle: String; let icon: String
    let isCompleted: Bool; let isActive: Bool; let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                ZStack {
                    if isActive {
                        Circle().stroke(AppTheme.primary.opacity(0.3), lineWidth: 6).frame(width: 52, height: 52)
                    }
                    Circle()
                        .fill(isCompleted ? AppTheme.primary : Color(UIColor.systemGray5))
                        .frame(width: 44, height: 44)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(isCompleted ? .white : AppTheme.textSecondary)
                }
                if !isLast {
                    Rectangle()
                        .fill(isCompleted ? AppTheme.primary.opacity(0.35) : Color(UIColor.systemGray5))
                        .frame(width: 2, height: 44)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(title).font(.system(size: 16, weight: isActive ? .bold : .semibold))
                    .foregroundColor(isCompleted ? AppTheme.textPrimary : AppTheme.textSecondary)
                Text(subtitle).font(.system(size: 13)).foregroundColor(AppTheme.textSecondary).lineLimit(2)
            }
            .padding(.top, 10)
            Spacer()
        }
    }
}
