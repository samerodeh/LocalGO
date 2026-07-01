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

            ChatbotView()
                .tabItem {
                    Label("Assistant", systemImage: selectedTab == 1 ? "sparkles" : "sparkles")
                }
                .tag(1)

            CartView(isModal: false)
                .tabItem {
                    Label("Cart", systemImage: selectedTab == 2 ? "cart.fill" : "cart")
                }
                .badge(cartVM.totalItems > 0 ? "\(cartVM.totalItems)" : nil)
                .tag(2)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: selectedTab == 3 ? "person.fill" : "person")
                }
                .tag(3)
        }
        .tint(AppTheme.primary)
    }
}
