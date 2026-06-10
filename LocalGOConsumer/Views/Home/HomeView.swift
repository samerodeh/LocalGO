import SwiftUI

struct HomeView: View {
    @StateObject private var vm = HomeViewModel()
    @EnvironmentObject private var cartVM: CartViewModel

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
                    popularSection.padding(.top, 32)
                }
            }
            .background(AppTheme.background)
            .ignoresSafeArea(edges: .top)
            .navigationBarHidden(true)
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

    // MARK: - Popular items horizontal strip
    private var popularSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Popular Right Now")
                .font(.system(size: 20, weight: .bold)).foregroundColor(AppTheme.textPrimary)
                .padding(.horizontal, 20)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(
                        RestaurantData.altaib.categories
                            .flatMap(\.items)
                            .filter(\.isPopular)
                            .prefix(8)
                            .map { $0 }
                    ) { item in
                        PopularItemCard(item: item, restaurant: RestaurantData.altaib)
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

// MARK: - Popular item card
struct PopularItemCard: View {
    let item: MenuItem
    let restaurant: Restaurant
    @EnvironmentObject private var cartVM: CartViewModel

    var qty: Int { cartVM.quantityOf(item) }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .bottomTrailing) {
                FoodThumbnail(url: item.imageURL, width: 148, height: 108, corner: 14)
                Button {
                    cartVM.addItem(item, restaurant: restaurant)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28)).foregroundColor(AppTheme.primary)
                        .background(Color.white, in: Circle())
                }
                .padding(8)
            }
            Text(item.name)
                .font(.system(size: 13, weight: .semibold)).foregroundColor(AppTheme.textPrimary)
                .lineLimit(2).frame(width: 148, alignment: .leading)
            Text(String(format: "$%.2f", item.price))
                .font(.system(size: 14, weight: .bold)).foregroundColor(AppTheme.primary)
        }
        .frame(width: 148)
    }
}
