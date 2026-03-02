import Foundation
import Observation

@MainActor
@Observable
class GroupQuestListViewModel {
    let questRepository: QuestRepository
    let groupId: String

    var quests: [Quest] = []
    var isLoading: Bool = false
    var errorMessage: String? = nil

    init(questRepository: QuestRepository, groupId: String) {
        self.questRepository = questRepository
        self.groupId = groupId
    }

    func loadQuests() async {
        isLoading = true
        do {
            quests = try await questRepository.getGroupQuests(groupId: groupId)
        } catch {
            errorMessage = "クエスト一覧の取得に失敗しました"
        }
        isLoading = false
    }
}
