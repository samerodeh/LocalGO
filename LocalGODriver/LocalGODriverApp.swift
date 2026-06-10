import SwiftUI

@main
struct LocalGODriverApp: App {
    @StateObject private var driverVM = DriverViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(driverVM)
        }
    }
}
