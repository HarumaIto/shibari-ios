import Foundation
import FirebaseFirestore

struct QuestDto: Codable, Identifiable {
    @DocumentID var id: String?
    var groupId: String
    var title: String
    var type: String
    var frequency: String
    var description: String
    var threshold: Int?
    
    func toDomain() -> Quest {
        return Quest(
            id: id ?? "",
            groupId: groupId,
            title: title,
            // Enumのパース失敗時は安全にデフォルト値を設定
            type: QuestType(rawValue: type) ?? .PROHIBITION,
            frequency: QuestFrequency(rawValue: frequency) ?? .ALWAYS,
            description: description,
            threshold: threshold
        )
    }
        
    static func fromDomain(_ domain: Quest) -> QuestDto {
        return QuestDto(
            id: domain.id.isEmpty ? nil : domain.id,
            groupId: domain.groupId,
            title: domain.title,
            type: domain.type.rawValue,
            frequency: domain.frequency.rawValue,
            description: domain.description,
            threshold: domain.threshold
        )
    }
}
