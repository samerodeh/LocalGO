import SwiftUI

struct RestaurantView: View {
    let restaurant: Restaurant
    @EnvironmentObject private var cartVM: CartViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: UUID? = nil
    @State private var showCart = false
    @State private var scrollProxy: ScrollViewProxy? = nil

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView(showsIndicators: false) {
                ScrollViewReader { proxy in
                    VStack(spacing: 0) {
                        header
                        stickyTabs
                        menuBody
                            .padding(.bottom, cartVM.items.isEmpty ? 40 : 110)
                    }
                    .onAppear {
                        scrollProxy = proxy
                        selectedCategory = restaurant.categories.first?.id
                    }
                }
            }
            .ignoresSafeArea(edges: .top)

            if !cartVM.items.isEmpty {
                floatingCart
                    .padding(.horizontal, 20).padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .overlay(alignment: .topLeading) {
            backButton.padding(.top, 58).padding(.leading, 20)
        }
        .sheet(isPresented: $showCart) {
            CartView(isModal: true)
        }
    }

    // MARK: - Header
    private var header: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [AppTheme.navy, AppTheme.navyMid], startPoint: .top, endPoint: .bottom)
                .frame(height: 290)

            ZStack {
                Circle().fill(AppTheme.primary.opacity(0.08)).frame(width: 220).offset(x: 90, y: -60)
                Circle().fill(AppTheme.primary.opacity(0.06)).frame(width: 150).offset(x: -80, y: 20)
            }

            Text("🫓").font(.system(size: 88)).offset(y: -80)

            VStack(alignment: .leading, spacing: 14) {
                Text(restaurant.name)
                    .font(.system(size: 28, weight: .black)).foregroundColor(.white)
                Text(restaurant.description)
                    .font(.system(size: 14)).foregroundColor(.white.opacity(0.65)).lineLimit(2)

                HStack(spacing: 22) {
                    InfoPill(icon: "star.fill",   text: String(format: "%.1f (%d+)", restaurant.rating, restaurant.ratingCount), color: .yellow)
                    InfoPill(icon: "clock.fill",  text: restaurant.deliveryTime, color: .white)
                    InfoPill(icon: "bag.fill",    text: String(format: "$%.2f delivery", restaurant.deliveryFee), color: AppTheme.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 22).padding(.bottom, 24)
        }
    }

    // MARK: - Category tabs
    private var stickyTabs: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(restaurant.categories) { cat in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedCategory = cat.id
                        }
                        scrollProxy?.scrollTo(cat.id, anchor: .top)
                    } label: {
                        VStack(spacing: 8) {
                            Text(cat.name)
                                .font(.system(size: 14, weight: selectedCategory == cat.id ? .bold : .medium))
                                .foregroundColor(selectedCategory == cat.id ? AppTheme.primary : AppTheme.textSecondary)
                                .padding(.horizontal, 16).padding(.top, 14)
                            Rectangle()
                                .fill(selectedCategory == cat.id ? AppTheme.primary : Color.clear)
                                .frame(height: 3).cornerRadius(2)
                        }
                        .animation(.easeInOut(duration: 0.2), value: selectedCategory)
                    }
                }
            }
            .padding(.horizontal, 4)
        }
        .background(Color.white)
        .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    // MARK: - Menu
    private var menuBody: some View {
        LazyVStack(alignment: .leading, spacing: 0) {
            ForEach(restaurant.categories) { cat in
                Text(cat.name)
                    .font(.system(size: 18, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                    .padding(.horizontal, 20).padding(.top, 28).padding(.bottom, 14)
                    .id(cat.id)

                ForEach(cat.items) { item in
                    MenuItemRow(item: item, restaurant: restaurant)
                    if item.id != cat.items.last?.id {
                        Divider().padding(.horizontal, 20)
                    }
                }
            }
        }
    }

    // MARK: - Floating cart
    private var floatingCart: some View {
        Button { showCart = true } label: {
            HStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 8).fill(Color.white.opacity(0.2)).frame(width: 32, height: 28)
                    Text("\(cartVM.totalItems)").font(.system(size: 13, weight: .bold)).foregroundColor(.white)
                }
                Text("View Cart").font(.system(size: 16, weight: .bold)).foregroundColor(.white)
                Spacer()
                Text(String(format: "$%.2f", cartVM.subtotal)).font(.system(size: 16, weight: .bold)).foregroundColor(.white)
            }
            .padding(.horizontal, 20).padding(.vertical, 16)
            .background(AppTheme.primary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: AppTheme.primaryGlow, radius: 18, x: 0, y: 8)
        }
    }

    private var backButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "chevron.left").font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}

struct InfoPill: View {
    let icon: String; let text: String; let color: Color
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: icon).font(.system(size: 11)).foregroundColor(color)
            Text(text).font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.85))
        }
    }
}
