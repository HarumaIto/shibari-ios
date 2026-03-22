import SwiftUI

enum JudgmentResult: String, Codable {
    case approval = "APPROVE"
    case reject = "REJECT"
    case unknown = "UNKNOWN"
    
    var displayName: String {
        switch self {
        case .approval: return "承認"
        case .reject: return "否認"
        case .unknown: return "判定不能"
        }
    }
    
    var color: Color {
        switch self {
        case .approval: return .successNeonGreen
        case .reject: return .tacticalRed
        case .unknown: return .gray
        }
    }
}
