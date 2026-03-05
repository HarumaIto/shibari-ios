import SwiftUI

enum NotificationType: String, Codable {
    case memberJoined = "MEMBER_JOINED"
    case questPosted = "QUEST_POSTED"
    case commentAdded = "COMMENT_ADDED"
    case questReminder = "QUEST_REMINDER"
    case questApproved = "QUEST_APPROVED" // 承認
    case questRejected = "QUEST_REJECTED" // 却下
    case unknown = "UNKNOWN" // 想定外のデータ用
    
    // UI表示用のアイコンを返すプロパティ
    var iconName: String {
        switch self {
        case .memberJoined: return "person.badge.plus"
        case .questPosted: return "photo.on.rectangle.angled"
        case .commentAdded: return "bubble.right.fill"
        case .questReminder: return "exclamationmark.circle.fill"
        case .questApproved: return "checkmark.seal.fill"
        case .questRejected: return "xmark.seal.fill"
        case .unknown: return "bell.fill"
        }
    }
    
    // UI表示用のテーマカラーを返すプロパティ
    var color: Color {
        switch self {
        case .memberJoined: return .blue
        case .questPosted: return .tacticalRed // アプリのメインカラー
        case .commentAdded: return .green
        case .questReminder: return .orange
        case .questApproved: return .achievementGold
        case .questRejected: return .gray
        case .unknown: return .white
        }
    }
}
