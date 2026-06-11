import Foundation
import SwiftUI

/// Why an item was recommended — drives the little explainer chip in the UI.
enum RecReason {
    case mostOrdered   // high all-time order volume
    case trending      // high recent velocity relative to its baseline
    case personal      // the user has ordered it before

    var label: String {
        switch self {
        case .mostOrdered: return "Most ordered"
        case .trending:    return "Trending"
        case .personal:    return "You order this"
        }
    }
    var icon: String {
        switch self {
        case .mostOrdered: return "flame.fill"
        case .trending:    return "chart.line.uptrend.xyaxis"
        case .personal:    return "heart.fill"
        }
    }
    var color: Color {
        switch self {
        case .mostOrdered: return AppTheme.primary
        case .trending:    return AppTheme.green
        case .personal:    return Color(red: 0.93, green: 0.28, blue: 0.45)
        }
    }
}

struct Recommendation: Identifiable {
    let item: MenuItem
    let score: Double
    let orderCount: Int
    let reason: RecReason
    var id: UUID { item.id }   // stable identity within a session
}

/// A working recommendation engine that ranks menu items primarily by how often
/// they're ordered, blended with recent-order velocity (trending) and the user's
/// own order history (personalization).
///
/// Scoring (per item, all signals min-max normalized to 0…1 across the menu):
///
///     score = wPop · popularity  +  wTrend · trending  +  wPersonal · affinity
///
/// • **popularity** — live all-time order count (seeded from SalesData, then
///   incremented as the user places orders). This is the dominant signal, so the
///   results are "the most-ordered items," lightly adapted to the diner.
/// • **trending** — trailing-7-day order count; surfaces items heating up now.
/// • **affinity** — how often *this* user has ordered the item.
///
/// Weights shift on a cold start (no personal history) so popularity/trending
/// carry the full weight until the engine learns the user's taste.
final class RecommendationEngine: ObservableObject {

    /// Live all-time order counts, keyed by item name. @Published so any view
    /// ranking against it re-renders the moment a new order updates the counts.
    @Published private(set) var liveOrderCounts: [String: Int]

    /// This device's own order counts — the personalization signal.
    @Published private(set) var personalCounts: [String: Int] = [:]

    init() {
        liveOrderCounts = SalesData.stats.mapValues { $0.allTime }
    }

    // MARK: - Learning

    /// Fold a completed order back into the model. Called when checkout succeeds,
    /// so rankings adapt in real time.
    func recordOrder(_ items: [CartItem]) {
        for line in items {
            liveOrderCounts[line.item.name, default: 0] += line.quantity
            personalCounts[line.item.name, default: 0] += line.quantity
        }
    }

    func orderCount(for item: MenuItem) -> Int { liveOrderCounts[item.name] ?? 0 }

    // MARK: - Ranking

    /// Top-ranked recommendations for a restaurant, most relevant first.
    func recommendations(for restaurant: Restaurant, limit: Int = 8) -> [Recommendation] {
        // Collect the unique menu items (the menu repeats some in "Featured").
        var seen = Set<String>()
        let items = restaurant.categories.flatMap(\.items).filter { seen.insert($0.name).inserted }
        guard !items.isEmpty else { return [] }

        let popularity = items.map { Double(liveOrderCounts[$0.name] ?? 0) }
        let trending   = items.map { Double(SalesData.stat(for: $0.name).recent) }
        let affinity   = items.map { Double(personalCounts[$0.name] ?? 0) }

        let popN   = normalize(popularity)
        let trendN = normalize(trending)
        let affN   = normalize(affinity)

        let hasHistory = affinity.contains { $0 > 0 }
        let wPop      = 0.60
        let wTrend    = hasHistory ? 0.20 : 0.40
        let wPersonal = hasHistory ? 0.20 : 0.00

        var ranked: [Recommendation] = []
        for (i, item) in items.enumerated() {
            let score = wPop * popN[i] + wTrend * trendN[i] + wPersonal * affN[i]
            ranked.append(
                Recommendation(
                    item: item,
                    score: score,
                    orderCount: Int(popularity[i]),
                    reason: reason(personal: affN[i], popularity: popN[i], trending: trendN[i])
                )
            )
        }

        return Array(
            ranked
                .sorted { $0.score > $1.score }
                .prefix(limit)
        )
    }

    /// "Order Again" — distinct items the user recently ordered, mapped back to
    /// live menu items so they can be re-added with one tap.
    func buyAgain(from lines: [OrderLine], in restaurant: Restaurant, limit: Int = 10) -> [MenuItem] {
        var menu: [String: MenuItem] = [:]
        for item in restaurant.categories.flatMap(\.items) { menu[item.name] = item }

        var seen = Set<String>()
        var result: [MenuItem] = []
        for line in lines where !seen.contains(line.itemName) {
            if let item = menu[line.itemName] {
                seen.insert(line.itemName)
                result.append(item)
                if result.count >= limit { break }
            }
        }
        return result
    }

    // MARK: - Helpers

    /// Pick the dominant signal so we can explain the recommendation to the user.
    private func reason(personal: Double, popularity: Double, trending: Double) -> RecReason {
        if personal > 0 { return .personal }
        if trending > popularity + 0.12 { return .trending }   // heating up faster than its baseline
        return .mostOrdered
    }

    /// Min-max normalize to 0…1. Returns all-zeros if every value is equal.
    private func normalize(_ values: [Double]) -> [Double] {
        guard let lo = values.min(), let hi = values.max(), hi > lo else {
            return values.map { _ in 0 }
        }
        return values.map { ($0 - lo) / (hi - lo) }
    }
}
