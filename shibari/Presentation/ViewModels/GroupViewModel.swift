import Foundation
import Observation

@Observable
class GroupViewModel {
    private let groupRepository: GroupRepository
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    private let questRepository: QuestRepository
        
    var group: Group? = nil
    var members: [User] = []
    var questDictionary: [String: Quest] = [:]
    var isLoading: Bool = true
    var errorMessage: String? = nil
    
    init(groupRepository: GroupRepository, authRepository: AuthRepository, userRepository: UserRepository, questRepository: QuestRepository) {
        self.groupRepository = groupRepository
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.questRepository = questRepository
    }
    
    func loadGroup() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            guard let uid = authRepository.getCurrentUserId() else {
                errorMessage = "ログインしていません"
                return
            }
            
            guard let user = try await userRepository.getUser(userId: uid) else {
                errorMessage = "ユーザー情報が見つかりません"
                return
            }
            
            guard let groupId = user.groupId else {
                errorMessage = "グループに所属していません"
                return
            }
            
            guard let group = try await groupRepository.getGroup(groupId: groupId) else {
                errorMessage = "グループ情報が見つかりません"
                return
            }
            self.group = group
            
            async let fetchMembers = userRepository.getUsers(userIds: group.memberIds)
            async let fetchQuests = questRepository.getGroupQuests(groupId: groupId)
            
            let (membersResult, questsResult) = try await (fetchMembers, fetchQuests)
            
            self.members = membersResult
            
            self.questDictionary = questsResult.reduce(into: [String: Quest]()) { dict, quest in
                dict[quest.id] = quest
            }
        } catch {
            errorMessage = "データの読み込みに失敗しました"
        }
    }
}
