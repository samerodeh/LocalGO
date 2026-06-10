import SwiftUI

enum AppTheme {
    // MARK: - Brand Colors (matching LocalGO landing page)
    static let primary       = Color(red: 249/255, green: 115/255, blue: 22/255)   // #f97316
    static let primaryDark   = Color(red: 234/255, green: 88/255,  blue: 12/255)   // #ea580c
    static let primaryGlow   = Color(red: 249/255, green: 115/255, blue: 22/255).opacity(0.35)
    static let navy          = Color(red: 15/255,  green: 23/255,  blue: 42/255)   // #0f172a
    static let navyMid       = Color(red: 30/255,  green: 41/255,  blue: 59/255)   // #1e293b
    static let navyLight     = Color(red: 51/255,  green: 65/255,  blue: 85/255)   // #334155

    // MARK: - Semantic Colors
    static let background    = Color(red: 248/255, green: 250/255, blue: 252/255)  // #f8fafc
    static let surface       = Color.white
    static let textPrimary   = Color(red: 15/255,  green: 23/255,  blue: 42/255)
    static let textSecondary = Color(red: 100/255, green: 116/255, blue: 139/255)  // #64748b
    static let divider       = Color(red: 226/255, green: 232/255, blue: 240/255)  // #e2e8f0

    // MARK: - Shape
    static let cardRadius: CGFloat    = 18
    static let buttonRadius: CGFloat  = 14
    static let chipRadius: CGFloat    = 100
}

// MARK: - View helpers
extension View {
    func cardStyle() -> some View {
        self
            .background(AppTheme.surface)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.cardRadius, style: .continuous))
            .shadow(color: .black.opacity(0.07), radius: 12, x: 0, y: 4)
    }

    func primaryButtonStyle(disabled: Bool = false) -> some View {
        self
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(disabled ? Color.gray.opacity(0.35) : AppTheme.primary)
            .clipShape(RoundedRectangle(cornerRadius: AppTheme.buttonRadius, style: .continuous))
            .shadow(color: disabled ? .clear : AppTheme.primaryGlow, radius: 14, x: 0, y: 6)
    }
}
