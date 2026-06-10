import SwiftUI

struct MenuItemRow: View {
    let item: MenuItem
    let restaurant: Restaurant
    @EnvironmentObject private var cartVM: CartViewModel

    private var qty: Int { cartVM.quantityOf(item) }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Text
            VStack(alignment: .leading, spacing: 6) {
                // Badges
                HStack(spacing: 6) {
                    if item.isPopular {
                        Text("Popular")
                            .font(.system(size: 10, weight: .bold)).foregroundColor(AppTheme.primary)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(AppTheme.primary.opacity(0.12), in: Capsule())
                    }
                    if item.isVegetarian {
                        Text("🌱 Veg").font(.system(size: 10, weight: .semibold)).foregroundColor(.green)
                    }
                }
                .fixedSize()

                Text(item.name).font(.system(size: 15, weight: .semibold)).foregroundColor(AppTheme.textPrimary)

                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
                        .lineLimit(2)
                }

                HStack(spacing: 10) {
                    Text(String(format: "$%.2f", item.price))
                        .font(.system(size: 15, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                    if let cal = item.calories {
                        Text("\(cal) cal").font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
                    }
                }
            }

            Spacer()

            // Thumbnail + add/remove
            VStack(alignment: .center, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(AppTheme.primary.opacity(0.09))
                        .frame(width: 88, height: 76)
                    Image(systemName: "fork.knife")
                        .font(.system(size: 26)).foregroundColor(AppTheme.primary.opacity(0.35))
                }

                if qty == 0 {
                    Button {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            cartVM.addItem(item, restaurant: restaurant)
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 30)).foregroundColor(AppTheme.primary)
                            .background(Color.white, in: Circle())
                    }
                    .offset(y: -15)
                } else {
                    HStack(spacing: 12) {
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                cartVM.decreaseItem(item)
                            }
                        } label: {
                            Image(systemName: "minus.circle.fill")
                                .font(.system(size: 26)).foregroundColor(AppTheme.navyLight)
                        }
                        Text("\(qty)").font(.system(size: 15, weight: .bold)).foregroundColor(AppTheme.textPrimary).frame(minWidth: 18)
                        Button {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                cartVM.addItem(item, restaurant: restaurant)
                            }
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 26)).foregroundColor(AppTheme.primary)
                        }
                    }
                    .offset(y: -15)
                }
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 16)
        .background(Color.white)
        .contentShape(Rectangle())
    }
}
