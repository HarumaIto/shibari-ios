import Foundation

struct AppNotification: Identifiable {
    let id: String
    let type: NotificationType
    let title: String
    let body: String
    let senderId: String?
    let targetId: String?
    var isRead: Bool
    let createdAt: Date
}
