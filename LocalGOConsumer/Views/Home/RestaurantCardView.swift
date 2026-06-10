import SwiftUI

struct RestaurantCardView: View {
    let restaurant: Restaurant

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Cover
            ZStack(alignment: .bottomLeading) {
                LinearGradient(
                    colors: [AppTheme.navy, AppTheme.navyMid],
                    startPoint: .topLeading, endPoint: .bottomTrailing
                )
                .frame(height: 175)
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))

                // Decorative orbs
                ZStack {
                    Circle().fill(AppTheme.primary.opacity(0.10)).frame(width: 100).offset(x: 110, y: -60)
                    Circle().fill(AppTheme.primary.opacity(0.07)).frame(width: 70).offset(x: -60, y: 30)
                }
                .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))

                Text("🫓").font(.system(size: 64))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                // Badges
                HStack {
                    if restaurant.isOpen {
                        Label("Open", systemImage: "checkmark.circle.fill")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 10).padding(.vertical, 6)
                            .background(Color.green.opacity(0.85), in: Capsule())
                    }
                    Spacer()
                    Text(restaurant.deliveryFee == 0 ? "Free delivery" : String(format: "$%.2f delivery", restaurant.deliveryFee))
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(AppTheme.primary, in: Capsule())
                }
                .padding(12)
            }
            .frame(height: 175)

            // Info
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(restaurant.name)
                            .font(.system(size: 18, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                        Text(restaurant.cuisine)
                            .font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
                    }
                    Spacer()
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill").font(.system(size: 11)).foregroundColor(.orange)
                        Text(String(format: "%.1f", restaurant.rating))
                            .font(.system(size: 14, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                        Text("(\(restaurant.ratingCount)+)")
                            .font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
                    }
                }

                HStack(spacing: 18) {
                    Label(restaurant.deliveryTime, systemImage: "clock")
                        .font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
                    Label(String(format: "Min. $%.0f", restaurant.minimumOrder), systemImage: "cart")
                        .font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
                }

                // Tags
                HStack(spacing: 8) {
                    ForEach(restaurant.tags.prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(AppTheme.primary)
                            .padding(.horizontal, 9).padding(.vertical, 4)
                            .background(AppTheme.primary.opacity(0.10), in: Capsule())
                    }
                }
            }
            .padding(16)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
    }
}
