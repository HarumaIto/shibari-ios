import Foundation
import FirebaseFirestore
import FirebaseStorage

class UserRepositoryImpl: UserRepository {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private var usersCollection: CollectionReference {
        db.collection("users")
    }
    
    func getUser(userId: String) async throws -> User? {
        let document = try await usersCollection.document(userId).getDocument()
        guard document.exists else { return nil }
        let dto = try document.data(as: UserDto.self)
        return dto.toDomain()
    }
    
    func getUsers(userIds: [String]) async throws -> [User] {
        guard !userIds.isEmpty else { return [] }
        
        var allDtos: [UserDto] = []
        
        let chunkSize = 10
        var index = 0
        while index < userIds.count {
            let endIndex = min(index + chunkSize, userIds.count)
            let chunk = Array(userIds[index..<endIndex])
            
            let snapshot = try await usersCollection
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments()
            
            let dtos = snapshot.documents.compactMap { try? $0.data(as: UserDto.self) }
            allDtos.append(contentsOf: dtos)
            
            index = endIndex
        }
        
        return allDtos.map { $0.toDomain() }
    }
    
    func createUser(user: User) async throws {
        let dto = UserDto.fromDomain(user)
        guard let userId = dto.id else { return }
        try usersCollection.document(userId).setData(from: dto)
    }
    
    func updateGroupId(userId: String, groupId: String) async throws {
        try await usersCollection.document(userId).updateData([
            "groupId": groupId
        ])
    }
    
    func updateQuestIds(userId: String, ids: [String]) async throws {
        try await usersCollection.document(userId).updateData([
            "participatingQuestIds": ids
        ])
    }
    
    func updateProfile(userId: String, displayName: String, photoData: Data?) async throws {
        var data: [String: Any] = [
            "displayName": displayName,
        ]
        if (photoData != nil) {
            let imageId = UUID().uuidString
            let storageRef = storage.reference().child("profiles/\(userId)/\(imageId).jpg")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            let _ = try await storageRef.putDataAsync(photoData!, metadata: metadata)
            
            let downloadUrl = try await storageRef.downloadURL()
            
            data["photoUrl"] = downloadUrl.absoluteString
        }
        
        try await usersCollection.document(userId).updateData(data)
    }
    
    func blockUser(currentUserId: String, targetUserId: String) async throws {
        // Androidの FieldValue.arrayUnion に相当
        try await usersCollection.document(currentUserId).updateData([
            "blockedUserIds": FieldValue.arrayUnion([targetUserId])
        ])
    }
    
    func anonymizeUser(userId: String) async throws {
        let updates: [String: Any] = [
            "isDeleted": true,
            "displayName": "退会済みユーザー",
            "fcmToken": NSNull(),
            "photoUrl": NSNull()
        ]
        try await usersCollection.document(userId).updateData(updates)
    }
}
