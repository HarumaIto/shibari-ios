struct QuestSnapshotDto: Codable {
    var title: String
    var type: String
    
    func toDomain() -> QuestSnapshot {
        QuestSnapshot(title: title, type: QuestType(rawValue: type) ?? .PROHIBITION)
    }
    
    static func fromDomain(_ domain: QuestSnapshot) -> QuestSnapshotDto {
        QuestSnapshotDto(
            title: domain.title,
            type: domain.type.rawValue
        )
    }
}
