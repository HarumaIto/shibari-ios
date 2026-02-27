import Foundation
import Observation

@MainActor
@Observable
class QuestSelectionViewModel {
    private let questRepository: QuestRepository
    private let userRepository: UserRepository
    private let groupId: String
    private let currentUserId: String
    
    var quests: [Quest] = []
    var selectedQuestIds: Set<String> = [] // 高速に検索・追加・削除するためSetを使用
    var isLoading: Bool = true
    var errorMessage: String? = nil
    var isCompleted: Bool = false
    
    init(questRepository: QuestRepository, userRepository: UserRepository, groupId: String, currentUserId: String) {
        self.questRepository = questRepository
        self.userRepository = userRepository
        self.groupId = groupId
        self.currentUserId = currentUserId
        
        if (currentUserId.isEmpty) {
            return
        }
        
        Task { await loadQuests() }
    }
    
    private func loadQuests() async {
        isLoading = true
        do {
            self.quests = try await questRepository.getQuests(groupId: groupId)
            if let user = try await userRepository.getUser(userId: currentUserId) {
                self.selectedQuestIds = Set(user.participatingQuestIds)
            }
        } catch {
            self.errorMessage = "データの読み込みに失敗しました"
        }
        isLoading = false
    }
    
    func toggleQuest(questId: String) {
        if selectedQuestIds.contains(questId) {
            selectedQuestIds.remove(questId)
        } else {
            selectedQuestIds.insert(questId)
        }
    }
    
    func saveSelection() async {
        isLoading = true
        do {
            try await userRepository.updateQuestIds(userId: currentUserId, ids: Array(selectedQuestIds))
            isCompleted = true
        } catch {
            self.errorMessage = "保存に失敗しました"
        }
        isLoading = false
    }
}
