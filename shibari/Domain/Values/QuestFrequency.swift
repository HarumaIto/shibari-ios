import Foundation

enum QuestFrequency: String, Codable, CaseIterable {
    case ALWAYS
    case DAILY
    case WEEKLY
    case MONTHLY
    case YEARLY
    
    // 画面表示用のテキスト
    var displayName: String {
        switch self {
        case .ALWAYS: return "常時"
        case .DAILY: return "日次"
        case .WEEKLY: return "週次"
        case .MONTHLY: return "月次"
        case .YEARLY: return "年次"
        }
    }
    
    // セクションを並べる順番
    var sortOrder: Int {
        switch self {
        case .ALWAYS: return 0
        case .DAILY: return 1
        case .WEEKLY: return 2
        case .MONTHLY: return 3
        case .YEARLY: return 4
        }
    }
}
