import Foundation
import FirebaseFirestore

class GroupRepositoryImpl: GroupRepository {
    private let db = Firestore.firestore()
    
    func createGroup(name: String, description: String, ownerId: String) async throws -> String {
        let groupId = UUID().uuidString.prefix(6).uppercased() // 例: 6桁の招待コード兼用
        let dto = GroupDto(
            id: groupId,
            name: name,
            description: description,
            ownerId: ownerId,
            memberIds: [ownerId],
            invitationCode: groupId
        )
        try db.collection("groups").document(groupId).setData(from: dto)
        return groupId
    }
    
    func joinGroup(groupId: String, userId: String) async throws {
        // グループが存在するか確認
        let doc = try await db.collection("groups").document(groupId).getDocument()
        guard doc.exists else { throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "Group not found"]) }
        
        // メンバーに追加
        try await db.collection("groups").document(groupId).updateData([
            "memberIds": FieldValue.arrayUnion([userId])
        ])
    }
    
    func getGroup(groupId: String) async throws -> Group? {
        let doc = try await db.collection("groups").document(groupId).getDocument()
        let dto = try? doc.data(as: GroupDto.self)
        return dto?.toDomain()
    }
    
    func getGroupByInvitationCode(invitationCode: String) async throws -> Group? {
        let docs = try await db.collection("groups")
            .whereField("invitationCode", isEqualTo: invitationCode)
            .getDocuments()
        let doc = docs.documents.first
        let dto = try? doc?.data(as: GroupDto.self)
        return dto?.toDomain()
    }
}
