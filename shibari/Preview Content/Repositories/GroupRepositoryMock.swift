class GroupRepositoryMock: GroupRepository {
    func createGroup(name: String, description: String, ownerId: String) async throws -> String {
        return "mock_group_id_123"
    }
    
    func joinGroup(groupId: String, userId: String) async throws { }
    
    func getGroup(groupId: String) async throws -> Group? {
        return Group(
            id: "mock_group_id_123",
            name: "Mock group",
            description: "Mock group description",
            ownerId: "mock_user_id_123",
            memberIds: [
                "mock_user_id_123",
                "mock_user_id_456"
            ],
            invitationCode: "MOCK_INVITATION_CODE"
        )
    }
    
    func getGroupByInvitationCode(invitationCode: String) async throws -> Group? {
        return nil
    }
}
