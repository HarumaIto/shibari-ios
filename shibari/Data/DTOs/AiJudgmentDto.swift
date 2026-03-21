import Foundation
import FirebaseFirestore

struct AiJudgmentDto: Codable {
    var result: String
    var reason: String
    
    @ServerTimestamp var judgedAt: Timestamp?
    
    func toDomain() -> AiJudgment {
        AiJudgment(
            result: JudgmentResult(rawValue: result) ?? .unknown,
            reason: reason,
            judgedAt: judgedAt?.dateValue() ?? Date()
        )
    }
}
