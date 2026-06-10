import SwiftUI

struct CartItemRow: View {
    let cartItem: CartItem
    @EnvironmentObject private var cartVM: CartViewModel

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle().fill(AppTheme.primary).frame(width: 28, height: 28)
                Text("\(cartItem.quantity)").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(cartItem.item.name).font(.system(size: 15, weight: .semibold)).foregroundColor(AppTheme.textPrimary)
                Text(String(format: "$%.2f each", cartItem.item.price)).font(.system(size: 13)).foregroundColor(AppTheme.textSecondary)
            }

            Spacer()

            HStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { cartVM.decreaseItem(cartItem.item) }
                } label: {
                    Image(systemName: "minus.circle.fill").font(.system(size: 22)).foregroundColor(AppTheme.navyLight)
                }
                Text("\(cartItem.quantity)").font(.system(size: 15, weight: .bold)).frame(minWidth: 18)
                Button {
                    if let r = RestaurantData.all.first(where: { $0.id == cartItem.restaurantId }) {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { cartVM.addItem(cartItem.item, restaurant: r) }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill").font(.system(size: 22)).foregroundColor(AppTheme.primary)
                }
            }

            Text(String(format: "$%.2f", cartItem.lineTotal))
                .font(.system(size: 15, weight: .bold)).foregroundColor(AppTheme.textPrimary).frame(minWidth: 52, alignment: .trailing)
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(Color.white)
    }
}
