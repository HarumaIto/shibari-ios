import SwiftUI

// Androidの Color.kt に相当する定義
extension Color {
    
    // --- メインカラー ---
    static let tacticalRed = Color(hex: "EF5350")
    static let achievementGold = Color(hex: "FFB300")
    static let successNeonGreen = Color(hex: "00E676")
    
    // --- 背景・サーフェス（ダークモード専用の世界観） ---
    static let slateBackground = Color(hex: "0F172A")
    static let slateSurface = Color(hex: "1E293B")
    static let slateSurfaceVariant = Color(hex: "334155")
    
    // --- テキストカラー ---
    static let textPrimary = Color(hex: "F1F5F9")
    static let textSecondary = Color(hex: "94A3B8")
    
    // （おまけ）16進数(HEX)コードで色を指定しやすくするための便利関数
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
