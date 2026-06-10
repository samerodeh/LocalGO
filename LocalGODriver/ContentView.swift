import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var vm: DriverViewModel
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem { Label("Deliveries", systemImage: "shippingbox.fill") }
                .tag(0)

            EarningsView()
                .tabItem { Label("Earnings", systemImage: "dollarsign.circle.fill") }
                .tag(1)

            DriverProfileView()
                .tabItem { Label("Profile", systemImage: "person.fill") }
                .tag(2)
        }
        .tint(AppTheme.primary)
    }
}
