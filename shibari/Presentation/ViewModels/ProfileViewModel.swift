import Foundation
import Observation

@MainActor
@Observable
class ProfileViewModel {
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    private let groupRepository: GroupRepository
    private let questRepository: QuestRepository
    
    var currentUser: User? = nil
    var currentGroup: Group? = nil
    var participatingQuests: [Quest] = []
    
    var isLoading: Bool = true
    var errorMessage: String? = nil
    var isLoggedOut: Bool = false // 画面遷移（ログアウト）のトリガー
    
    init(authRepository: AuthRepository, userRepository: UserRepository, groupRepository: GroupRepository, questRepository: QuestRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.groupRepository = groupRepository
        self.questRepository = questRepository
    }
    
    func loadData() async {
        if currentUser != nil && currentGroup != nil {
            return
        }
        
        if currentUser == nil {
            isLoading = true
        }
        do {
            guard let uid = authRepository.getCurrentUserId() else {
                errorMessage = "ユーザー情報が取得できません"
                isLoading = false
                return
            }
            
            // 1. ユーザー情報の取得
            if let user = try await userRepository.getUser(userId: uid) {
                self.currentUser = user
                
                // 2. グループ情報の取得
                if let groupId = user.groupId {
                    self.currentGroup = try await groupRepository.getGroup(groupId: groupId)
                    
                    // 3. 参加中のクエストを取得
                    let allQuests = try await questRepository.getQuests(groupId: groupId)
                    self.participatingQuests = allQuests.filter { user.participatingQuestIds.contains($0.id) }
                }
            }
        } catch {
            errorMessage = "データの読み込みに失敗しました"
        }
        isLoading = false
    }
    
    // ログアウト処理
    func signOut() {
        do {
            try authRepository.signOut()
            isLoggedOut = true
        } catch {
            errorMessage = "ログアウトに失敗しました"
        }
    }
    
    // 退会処理（データ匿名化 ＋ アカウント削除）
    func deleteAccount() async {
        isLoading = true
        do {
            guard let uid = authRepository.getCurrentUserId() else { return }
            
            // 過去の投稿がエラーにならないよう、名前等を「退会済みユーザー」に書き換える（匿名化）
            try await userRepository.anonymizeUser(userId: uid)
            
            // Firebase Authからユーザーを完全に削除
            try await authRepository.deleteAccount()
            
            isLoggedOut = true
        } catch {
            errorMessage = "退会処理に失敗しました。再度ログインし直してからお試しください。"
            isLoading = false
        }
    }
}
