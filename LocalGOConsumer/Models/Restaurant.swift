import Foundation

struct Restaurant: Identifiable {
    let id: UUID
    let name: String
    let cuisine: String
    let description: String
    let address: String
    let rating: Double
    let ratingCount: Int
    let deliveryTime: String
    let deliveryFee: Double
    let minimumOrder: Double
    let isOpen: Bool
    let tags: [String]
    let categories: [MenuCategory]
}
