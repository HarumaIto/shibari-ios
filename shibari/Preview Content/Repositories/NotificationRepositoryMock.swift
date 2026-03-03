import Foundation

class NotificationRepositoryMock: NotificationRepository {
    func getNotifications(userId: String) async throws -> [AppNotification] {
        let date = Date()
        return [
            AppNotification(
                id: "mock_notification_id_1",
                type: NotificationType.commentAdded,
                title: "Mock Comment Added",
                body: "Added comment your post",
                senderId: "",
                targetId: "",
                isRead: false,
                createdAt: date
            ),
            AppNotification(
                id: "mock_notification_id_2",
                type: NotificationType.memberJoined,
                title: "Mock Member Joined",
                body: "Member joined this group",
                senderId: "",
                targetId: "",
                isRead: false,
                createdAt: date
            ),
            AppNotification(
                id: "mock_notification_id_3",
                type: NotificationType.questApproved,
                title: "Mock Quest Approved",
                body: "Your quest approved",
                senderId: "",
                targetId: "",
                isRead: false,
                createdAt: date
            ),
            AppNotification(
                id: "mock_notification_id_4",
                type: NotificationType.questPosted,
                title: "Mock Quest Posted",
                body: "Quset posted this group",
                senderId: "",
                targetId: "",
                isRead: true,
                createdAt: date
            ),
            AppNotification(
                id: "mock_notification_id_5",
                type: NotificationType.questRejected,
                title: "Mock Quest Rejected",
                body: "Your quest rejected",
                senderId: "",
                targetId: "",
                isRead: true,
                createdAt: date
            ),
            AppNotification(
                id: "mock_notification_id_6",
                type: NotificationType.questReminder,
                title: "Mock Quest Reminder",
                body: "Your quest reminder",
                senderId: "",
                targetId: "",
                isRead: true,
                createdAt: date
            ),
            AppNotification(
                id: "mock_notification_id_7",
                type: NotificationType.unknown,
                title: "Mock Unknown",
                body: "Unknown notification",
                senderId: "",
                targetId: "",
                isRead: false,
                createdAt: date
            ),
        ]
    }
}
