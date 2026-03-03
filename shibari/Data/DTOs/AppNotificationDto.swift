import Foundation
import FirebaseFirestore

struct AppNotificationDto: Codable, Identifiable {
    @DocumentID var id: String?
    let type: String
    let title: String
    let body: String
    let senderId: String?
    let targetId: String?
    var isRead: Bool
    @ServerTimestamp var createdAt: Timestamp?
    
    func toDomain() -> AppNotification {
        return AppNotification(
            id: id ?? "",
            type: NotificationType(rawValue: type) ?? .unknown,
            title: title,
            body: body,
            senderId: senderId,
            targetId: targetId,
            isRead: isRead,
            createdAt: createdAt?.dateValue() ?? Date()
        )
    }
        
    static func fromDomain(_ domain: AppNotification) -> AppNotificationDto {
        return AppNotificationDto(
            id: domain.id.isEmpty ? nil : domain.id,
            type: domain.type.rawValue,
            title: domain.title,
            body: domain.body,
            senderId: domain.senderId,
            targetId: domain.targetId,
            isRead: domain.isRead,
            createdAt: Timestamp(date: domain.createdAt)
        )
    }
}
