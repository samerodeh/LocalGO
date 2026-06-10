import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var selectedCategory: String? = nil

    let restaurants: [Restaurant] = RestaurantData.all

    var filteredRestaurants: [Restaurant] {
        guard !searchText.isEmpty else { return restaurants }
        return restaurants.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.cuisine.localizedCaseInsensitiveContains(searchText)
        }
    }
}
