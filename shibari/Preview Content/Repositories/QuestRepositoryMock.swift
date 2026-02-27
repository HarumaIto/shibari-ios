class QuestRepositoryMock: QuestRepository {
    func getQuests(groupId: String) async throws -> [Quest] {
        return [
            Quest(
                id: "mock_quest_id_123",
                groupId: "mock_group_id_456",
                title: "Mock quest",
                type: QuestType.ROUTINE,
                frequency: QuestFrequency.DAILY,
                description: "Mock description",
                threshold: 1
            )
        ]
    }
    
    func createQuest(quest: Quest) async throws { }
}
