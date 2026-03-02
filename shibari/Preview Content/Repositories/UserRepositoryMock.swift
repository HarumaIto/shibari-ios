import Foundation

class UserRepositoryMock: UserRepository {
    func getUser(userId: String) async throws -> User? {
        return User(
            id: "mock_user_id_123",
            displayName: "Mock user",
            participatingQuestIds: [
                "mock_quest_id_123",
                "mock_quest_id_456"
            ],
            groupId: "mock_group_id_123",
            blockedUserIds: []
        )
    }
    func getUsers(userIds: [String]) async throws -> [User] {
        return [
            User(
                id: "mock_user_id_123",
                displayName: "Mock user1",
                participatingQuestIds: [
                    "mock_quest_id_123",
                    "mock_quest_id_456"
                ],
                groupId: "mock_group_id_123",
                blockedUserIds: []
            ),
            User(
                id: "mock_user_id_456",
                displayName: "Mock user2",
                participatingQuestIds: [
                    "mock_quest_id_123",
                    "mock_quest_id_456"
                ],
                groupId: "mock_group_id_123",
                blockedUserIds: []
            ),
        ]
    }
    func createUser(user: User) async throws { }
    func updateGroupId(userId: String, groupId: String) async throws { }
    func updateQuestIds(userId: String, ids: [String]) async throws { }
    func updateProfile(userId: String, displayName: String, photoData: Data?) async throws { }
    func blockUser(currentUserId: String, targetUserId: String) async throws { }
    func anonymizeUser(userId: String) async throws { }
}
