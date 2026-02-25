import Foundation
import Observation

@MainActor
@Observable
class GroupSelectionViewModel {
    private let groupRepository: GroupRepository
    private let userRepository: UserRepository
    private let currentUserId: String
    
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isCompleted: Bool = false // 成功時に画面遷移させるためのフラグ
    
    // --- 新規作成用 State ---
    var newGroupName: String = ""
    var newGroupDescription: String = ""
    
    // --- 参加用 State ---
    var invitationCode: String = ""
    
    init(groupRepository: GroupRepository, userRepository: UserRepository, currentUserId: String) {
        self.groupRepository = groupRepository
        self.userRepository = userRepository
        self.currentUserId = currentUserId
    }
    
    func createGroup() async {
        guard !newGroupName.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let groupId = try await groupRepository.createGroup(
                name: newGroupName,
                description: newGroupDescription,
                ownerId: currentUserId
            )
            // 自分のユーザー情報に groupId をセット
            try await userRepository.updateGroupId(userId: currentUserId, groupId: groupId)
            isCompleted = true
        } catch {
            errorMessage = "グループの作成に失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // 部隊への合流（既存グループ参加）
    func joinGroup() async {
        guard !invitationCode.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let group = try await groupRepository.getGroupByInvitationCode(invitationCode: invitationCode)
            guard let group = group else {
                errorMessage = "グループが見つかりませんでした。"
                isLoading = false
                return
            }
            let groupId = group.id
            try await groupRepository.joinGroup(groupId: groupId, userId: currentUserId)
            // 自分のユーザー情報に groupId をセット
            try await userRepository.updateGroupId(userId: currentUserId, groupId: groupId)
            isCompleted = true
        } catch {
            errorMessage = "招待コードが無効か、通信エラーが発生しました。"
        }
        
        isLoading = false
    }
}
