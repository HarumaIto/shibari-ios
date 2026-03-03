class QuestRepositoryMock: QuestRepository {
    func getGroupQuests(groupId: String) async throws -> [Quest] {
        return [
            Quest(
                id: "mock_quest_id_123",
                groupId: "mock_group_id_123",
                title: "Mock quest",
                type: QuestType.ROUTINE,
                frequency: QuestFrequency.DAILY,
                description: "Mock description",
                threshold: 1
            )
        ]
    }
    
    func getMyQuests(groupId: String, user: User) async throws -> [Quest] {
        return [
            Quest(
                id: "mock_quest_id_123",
                groupId: "mock_group_id_123",
                title: "Mock quest",
                type: QuestType.ROUTINE,
                frequency: QuestFrequency.DAILY,
                description: "Mock description",
                threshold: 1,
                isCompleted: true
            ),
            Quest(
                id: "mock_quest_id_456",
                groupId: "mock_group_id_123",
                title: "Mock quest2",
                type: QuestType.ROUTINE,
                frequency: QuestFrequency.DAILY,
                description: "Mock description2",
                threshold: 1,
                isCompleted: false
            )
        ]
    }
    
    func createQuest(quest: Quest) async throws { }

    func updateQuest(quest: Quest) async throws { }
}
