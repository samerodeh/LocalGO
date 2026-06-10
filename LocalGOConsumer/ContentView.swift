import SwiftUI

struct ContentView: View {
    @EnvironmentObject var cartVM: CartViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: selectedTab == 0 ? "house.fill" : "house")
                }
                .tag(0)

            CartView(isModal: false)
                .tabItem {
                    Label("Cart", systemImage: selectedTab == 1 ? "cart.fill" : "cart")
                }
                .badge(cartVM.totalItems > 0 ? "\(cartVM.totalItems)" : nil)
                .tag(1)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == 2 ? "person.fill" : "person")
                }
                .tag(2)
        }
        .tint(AppTheme.primary)
    }
}
