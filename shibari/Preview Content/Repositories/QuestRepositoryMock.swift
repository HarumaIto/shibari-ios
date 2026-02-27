class QuestRepositoryMock: QuestRepository {
    func getQuests(groupId: String) async throws -> [Quest] {
        return [] // ダミーの縛り（Quest）配列を返すとリストUIのテストができます
    }
    
    func createQuest(quest: Quest) async throws { }
}
