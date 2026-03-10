import Foundation

// MARK: - Auth Repository Protocol
protocol AuthRepository {
    func getClientId() -> String?
    func getCurrentUserId() -> String?
    func signIn(email: String, password: String) async throws -> String
    func signUp(email: String, password: String) async throws -> String
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> String
    func signInWithApple(idToken: String, nonce: String, fullName: PersonNameComponents?) async throws -> String
    func signOut() throws
    func getFCMToken() async throws -> String?
}

// MARK: - User Repository Protocol
protocol UserRepository {
    func getUser(userId: String) async throws -> User?
    func getUsers(userIds: [String]) async throws -> [User]
    func createUser(user: User) async throws
    func updateGroupId(userId: String, groupId: String) async throws
    func updateQuestIds(userId: String, ids: [String]) async throws
    func updateProfile(userId: String, displayName: String, photoData: Data?) async throws
    func updateFcmToken(userId: String, fcmToken: String) async throws
    func blockUser(currentUserId: String, targetUserId: String) async throws
    func anonymizeUser(userId: String) async throws
}

// MARK: - Group Repository Protocol
protocol GroupRepository {
    func createGroup(name: String, description: String, ownerId: String) async throws -> String
    func joinGroup(groupId: String, userId: String) async throws
    func getGroup(groupId: String) async throws -> Group?
    func getGroupByInvitationCode(invitationCode: String) async throws -> Group?
}

// MARK: - Quest Repository Protocol
protocol QuestRepository {
    func getGroupQuests(groupId: String) async throws -> [Quest]
    func getMyQuests(groupId: String, user: User) async throws -> [Quest]
    func createQuest(quest: Quest) async throws -> String
    func updateQuest(quest: Quest) async throws
}

// MARK: - Report Repository Protocol
protocol ReportRepository {
    func reportContent(reporterId: String, reportedUserId: String, postId: String, reason: String) async throws
}

// MARK: - Timeline Repository Protocol
protocol TimelineRepository {
    // Kotlinの Flow<List<TimelinePost>> に相当するSwiftの型
    func getTimelineStream(groupId: String) -> AsyncThrowingStream<[TimelinePost], Error>
    func createPost(post: TimelinePost, mediaData: Data) async throws
    func votePost(postId: String, userId: String, voteType: VoteType) async throws
    func getCommentsStream(postId: String) -> AsyncThrowingStream<[Comment], Error>
    func addComment(postId: String, author: AuthorSnapshot, userId: String, text: String) async throws
}

// MARK: - Notification Repository Protocol
protocol NotificationRepository {
    func getNotifications(userId: String) async throws -> [AppNotification]
    func markAllAsRead(userId: String, ids: [String]) async throws
}
