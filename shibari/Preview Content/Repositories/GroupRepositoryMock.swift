class GroupRepositoryMock: GroupRepository {
    func createGroup(name: String, description: String, ownerId: String) async throws -> String {
        return "mock_group_id_456"
    }
    
    func joinGroup(groupId: String, userId: String) async throws { }
    
    func getGroup(groupId: String) async throws -> Group? {
        return nil // 必要に応じてダミーのGroupを返す
    }
    
    func getGroupByInvitationCode(invitationCode: String) async throws -> Group? {
        return nil
    }
}
