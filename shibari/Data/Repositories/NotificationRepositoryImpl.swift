import FirebaseFirestore

class NotificationRepositoryImpl: NotificationRepository {
    private let db = Firestore.firestore()
    
    func getNotifications(userId: String) async throws -> [AppNotification] {
        let snapshot = try await db.collection("users")
            .document(userId)
            .collection("notifications")
            .order(by: "createdAt", descending: true)
            .limit(to: 50)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            let dto = try? doc.data(as: AppNotificationDto.self)
            return dto?.toDomain()
        }
    }
    
}
