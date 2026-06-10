import Foundation

struct MenuCategory: Identifiable {
    let id: UUID
    let name: String
    var items: [MenuItem]
}

struct MenuItem: Identifiable, Hashable {
    let id: UUID
    let name: String
    let description: String
    let price: Double
    let isPopular: Bool
    let isVegetarian: Bool
    let calories: Int?

    static func == (lhs: MenuItem, rhs: MenuItem) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}
