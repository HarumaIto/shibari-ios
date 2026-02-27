import Foundation
import Observation

@MainActor
@Observable
class QuestsViewModel {
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    private let questRepository: QuestRepository
    
    var uiState: QuestsUiState = .loading
    
    struct QuestGroup: Identifiable {
        let frequency: QuestFrequency
        let quests: [Quest]
        var id: String { frequency.rawValue }
    }
    
    // Kotlinのsealed interfaceと同等の列挙型
    enum QuestsUiState {
        case loading
        case success(groupedQuests: [QuestGroup])
        case error(message: String)
    }
    
    init(authRepository: AuthRepository, userRepository: UserRepository, questRepository: QuestRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.questRepository = questRepository
    }
    
    func loadMyQuests(isRefresh: Bool = false) async {
        // すでに成功状態で、リフレッシュでない場合はスキップ
        if case .success = uiState, !isRefresh {
            return
        }
        
        uiState = .loading
        do {
            guard let uid = authRepository.getCurrentUserId() else {
                uiState = .error(message: "ログインしていません")
                return
            }
            
            guard let user = try await userRepository.getUser(userId: uid) else {
                uiState = .error(message: "ユーザー情報が見つかりません")
                return
            }
            
            guard let groupId = user.groupId else {
                uiState = .error(message: "グループに所属していません")
                return
            }
            
            let questIds = user.participatingQuestIds
            if questIds.isEmpty {
                uiState = .success(groupedQuests: [])
                return
            }
            
            // 全てのクエストを取得し、自分の参加中IDでフィルタリング
            let allQuests = try await questRepository.getMyQuests(groupId: groupId, user: user)
            let myQuests = allQuests.filter { questIds.contains($0.id) }
                        
            let groupedDict = Dictionary(grouping: myQuests, by: { $0.frequency })
            let groupedQuests = groupedDict.map { key, value in
                QuestGroup(frequency: key, quests: value)
            }
            .sorted { $0.frequency.sortOrder < $1.frequency.sortOrder }
            
            uiState = .success(groupedQuests: groupedQuests)
            
        } catch {
            uiState = .error(message: "データの読み込みに失敗しました")
        }
    }
}
