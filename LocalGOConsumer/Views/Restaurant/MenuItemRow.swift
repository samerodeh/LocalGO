import SwiftUI

struct MenuItemRow: View {
    let item: MenuItem
    let restaurant: Restaurant
    @EnvironmentObject private var cartVM: CartViewModel
    @State private var showFullImage = false

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
                FoodThumbnail(url: item.imageURL, width: 88, height: 76)
                    .overlay(alignment: .topLeading) {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(.white)
                            .padding(5)
                            .background(.black.opacity(0.45), in: Circle())
                            .padding(5)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { showFullImage = true }

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
        .fullScreenCover(isPresented: $showFullImage) {
            FullScreenImageView(item: item, restaurant: restaurant)
        }
    }
}
