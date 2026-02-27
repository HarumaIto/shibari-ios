import Foundation

class UserRepositoryMock: UserRepository {
    func getUser(userId: String) async throws -> User? {
        // プレビューでユーザー情報を表示したい場合は、ここにダミーのUserインスタンスを返します
        // 例: return User(id: userId, name: "テストユーザー", ...)
        return nil
    }
    
    func createUser(user: User) async throws { }
    func updateGroupId(userId: String, groupId: String) async throws { }
    func updateQuestIds(userId: String, ids: [String]) async throws { }
    func updateProfile(userId: String, displayName: String, photoData: Data?) async throws { }
    func blockUser(currentUserId: String, targetUserId: String) async throws { }
    func anonymizeUser(userId: String) async throws { }
}
