import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @EnvironmentObject private var cartVM: CartViewModel
    @EnvironmentObject private var recEngine: RecommendationEngine
    @EnvironmentObject private var orderService: OrderService
    @EnvironmentObject private var auth: AuthService

    private let categories = ["All", "Pizza", "Manakish", "Grill", "Sides", "Drinks"]
    private let categoryIcons = ["square.grid.2x2.fill", "circle.fill", "flame.fill", "fork.knife", "leaf.fill", "cup.and.saucer.fill"]

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    headerBanner
                    searchBar.padding(.horizontal, 20).padding(.vertical, 16)
                    categoryRow.padding(.bottom, 24)
                    restaurantSection.padding(.horizontal, 20)
                    buyAgainSection.padding(.top, 32)
                    popularSection.padding(.top, 32)
                }
            }
            .background(AppTheme.background)
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
            .task {
                // Warm the image cache on launch so every menu photo is ready
                // (in memory/disk) before the user scrolls into it.
                ImageCache.shared.prefetch(FoodThumbnail.allMenuImageURLs)
            }
            .onAppear { orderService.load(for: auth.currentUser?.id) }
        }
    }

    // MARK: - Order Again (from order history)
    @ViewBuilder
    private var buyAgainSection: some View {
        let items = recEngine.buyAgain(from: orderService.orders.flatMap(\.lines),
                                       in: RestaurantData.altaib, limit: 10)
        if !items.isEmpty {
            VStack(alignment: .leading, spacing: 14) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.counterclockwise.circle.fill").font(.system(size: 16)).foregroundColor(AppTheme.primary)
                    VStack(alignment: .leading, spacing: 1) {
                        Text("Order Again").font(.system(size: 20, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                        Text("Your recent favorites, one tap away").font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
                    }
                }
                .padding(.horizontal, 20)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(items) { item in
                            PopularItemCard(item: item, restaurant: RestaurantData.altaib)
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
    }

    // MARK: - Header
    private var headerBanner: some View {
        ZStack(alignment: .bottom) {
            LinearGradient(colors: [AppTheme.navy, AppTheme.navyMid], startPoint: .top, endPoint: .bottom)
                .frame(height: 170)

            // Decorative orange blobs
            ZStack {
                Circle().fill(AppTheme.primary.opacity(0.12)).frame(width: 160).offset(x: 120, y: -20)
                Circle().fill(AppTheme.primary.opacity(0.08)).frame(width: 110).offset(x: -100, y: 10)
            }

            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 5) {
                        Image(systemName: "mappin.circle.fill").foregroundColor(AppTheme.primary).font(.system(size: 13))
                        Text("Delivering to").font(.system(size: 12, weight: .medium)).foregroundColor(.white.opacity(0.65))
                    }
                    Text("Montreal, QC")
                        .font(.system(size: 17, weight: .bold)).foregroundColor(.white)
                }
                Spacer()
                // LocalGO wordmark
                HStack(spacing: 5) {
                    ZStack {
                        Circle().fill(AppTheme.primary).frame(width: 28, height: 28)
                        Image(systemName: "location.fill").font(.system(size: 12)).foregroundColor(.white)
                    }
                    Text("LocalGO")
                        .font(.system(size: 22, weight: .black)).foregroundColor(.white).kerning(-0.5)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 22)
            .padding(.top, 60)
        }
    }

    // MARK: - Search
    private var searchBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass").foregroundColor(AppTheme.textSecondary)
            TextField("Search restaurants or dishes…", text: $vm.searchText)
                .font(.system(size: 15))
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 8, x: 0, y: 2)
    }

    // MARK: - Categories
    private var categoryRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(categories.enumerated()), id: \.offset) { i, cat in
                    let selected = (i == 0 && vm.selectedCategory == nil) ||
                                   vm.selectedCategory == cat
                    Button {
                        vm.selectedCategory = (cat == "All") ? nil : cat
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: categoryIcons[i]).font(.system(size: 12))
                            Text(cat).font(.system(size: 14, weight: .semibold))
                        }
                        .padding(.horizontal, 15).padding(.vertical, 10)
                        .background(selected ? AppTheme.primary : Color.white)
                        .foregroundColor(selected ? .white : AppTheme.textPrimary)
                        .clipShape(Capsule())
                        .shadow(
                            color: selected ? AppTheme.primaryGlow : .black.opacity(0.06),
                            radius: 6, x: 0, y: 2
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Restaurants
    private var restaurantSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Restaurants Near You")
                .font(.system(size: 20, weight: .bold)).foregroundColor(AppTheme.textPrimary)
            ForEach(vm.filteredRestaurants) { restaurant in
                NavigationLink {
                    RestaurantView(restaurant: restaurant)
                } label: {
                    RestaurantCardView(restaurant: restaurant)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Popular items horizontal strip (recommendation engine)
    private var popularSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "flame.fill").font(.system(size: 16)).foregroundColor(AppTheme.primary)
                VStack(alignment: .leading, spacing: 1) {
                    Text("Most Popular")
                        .font(.system(size: 20, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                    Text("Ranked by what people order most at Al Taib")
                        .font(.system(size: 12)).foregroundColor(AppTheme.textSecondary)
                }
            }
            .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    let recs = recEngine.recommendations(for: RestaurantData.altaib, limit: 8)
                    ForEach(Array(recs.enumerated()), id: \.element.id) { index, rec in
                        PopularItemCard(
                            item: rec.item,
                            restaurant: RestaurantData.altaib,
                            rank: index + 1,
                            orderCount: rec.orderCount,
                            reason: rec.reason
                        )
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 110)
    }
}

// MARK: - Category chip
struct CategoryChip: View {
    let title: String; let icon: String; let isSelected: Bool; let action: () -> Void
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon).font(.system(size: 12))
                Text(title).font(.system(size: 14, weight: .semibold))
            }
            .padding(.horizontal, 15).padding(.vertical, 10)
            .background(isSelected ? AppTheme.primary : Color.white)
            .foregroundColor(isSelected ? .white : AppTheme.textPrimary)
            .clipShape(Capsule())
            .shadow(color: isSelected ? AppTheme.primaryGlow : .black.opacity(0.06), radius: 6, x: 0, y: 2)
        }
    }
}

// MARK: - Popular item card (recommendation result)
struct PopularItemCard: View {
    let item: MenuItem
    let restaurant: Restaurant
    var rank: Int? = nil
    var orderCount: Int? = nil
    var reason: RecReason? = nil
    @EnvironmentObject private var cartVM: CartViewModel
    @State private var showFullImage = false

    var qty: Int { cartVM.quantityOf(item) }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .bottomTrailing) {
                FoodThumbnail(url: item.imageURL, width: 148, height: 108, corner: 14)
                    .overlay(alignment: .topLeading) { topBadges }
                    .contentShape(Rectangle())
                    .onTapGesture { showFullImage = true }
                Button {
                    cartVM.addItem(item, restaurant: restaurant)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28)).foregroundColor(AppTheme.primary)
                        .background(Color.white, in: Circle())
                }
                .padding(8)
            }

            // Reason chip
            if let reason {
                HStack(spacing: 4) {
                    Image(systemName: reason.icon).font(.system(size: 9, weight: .bold))
                    Text(reason.label).font(.system(size: 10, weight: .bold))
                }
                .foregroundColor(reason.color)
                .padding(.horizontal, 7).padding(.vertical, 3)
                .background(reason.color.opacity(0.12), in: Capsule())
            }

            Text(item.name)
                .font(.system(size: 13, weight: .semibold)).foregroundColor(AppTheme.textPrimary)
                .lineLimit(2).frame(width: 148, alignment: .leading)

            HStack(spacing: 6) {
                Text(String(format: "$%.2f", item.price))
                    .font(.system(size: 14, weight: .bold)).foregroundColor(AppTheme.primary)
                if let orderCount {
                    Text("· \(Self.short(orderCount)) orders")
                        .font(.system(size: 11)).foregroundColor(AppTheme.textSecondary)
                }
            }
        }
        .frame(width: 148)
        .fullScreenCover(isPresented: $showFullImage) {
            FullScreenImageView(item: item, restaurant: restaurant)
        }
    }

    // Rank pill (top-left) + expand hint (top-right)
    private var topBadges: some View {
        ZStack {
            if let rank {
                Text("#\(rank)")
                    .font(.system(size: 11, weight: .black)).foregroundColor(.white)
                    .padding(.horizontal, 7).padding(.vertical, 3)
                    .background(AppTheme.primary, in: Capsule())
                    .padding(6)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
            Image(systemName: "arrow.up.left.and.arrow.down.right")
                .font(.system(size: 10, weight: .bold)).foregroundColor(.white)
                .padding(6).background(.black.opacity(0.45), in: Circle()).padding(6)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
        }
    }

    /// 1840 → "1.8k"
    static func short(_ n: Int) -> String {
        n >= 1000 ? String(format: "%.1fk", Double(n) / 1000) : "\(n)"
    }
}
