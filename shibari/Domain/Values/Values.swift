enum MediaType: String, Codable {
    case image
    case video
}

enum PostStatus: String, Codable {
    case pending
    case approved
    case rejected
}

enum VoteType: String, Codable {
    case APPROVE
    case REJECT
}

enum QuestType: String, Codable, CaseIterable {
    case PROHIBITION
    case ROUTINE
    case ACHIEVEMENT
    case CHALLENGE

    var displayName: String {
        switch self {
        case .PROHIBITION: return "禁止"
        case .ROUTINE: return "ルーティン"
        case .ACHIEVEMENT: return "達成"
        case .CHALLENGE: return "チャレンジ"
        }
    }
}
