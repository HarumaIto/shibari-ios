import Foundation
import Observation

@Observable
class NotificationsViewModel {
    private let notificationRepository: NotificationRepository
    private let authRepository: AuthRepository
    
    var currentUid: String = ""
    var notifications: [AppNotification] = []
    var isLoading: Bool = true
    var errorMessage: String? = nil
    
    init(notificationRepository: NotificationRepository, authRepository: AuthRepository) {
        self.notificationRepository = notificationRepository
        self.authRepository = authRepository
    }
    
    func loadNotifications() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            guard let uid = authRepository.getCurrentUserId() else {
                errorMessage = "ログインしていません"
                return
            }
            currentUid = uid
            
            self.notifications = try await notificationRepository.getNotifications(userId: uid)
        } catch {
            errorMessage = "データの読み込みに失敗しました"
        }
    }
    
    // 一覧画面を開いたときの処理（一括既読）
    func markAllAsRead() async {
        let unreadIds = notifications.filter { !$0.isRead }.map { $0.id }
        if unreadIds.isEmpty || currentUid.isEmpty { return }
        
        // UIをすべて既読に更新
        for i in 0..<notifications.count {
            notifications[i].isRead = true
        }
        
        do {
            try await notificationRepository.markAllAsRead(
                userId: currentUid,
                ids: unreadIds
            )
        } catch {
            errorMessage = "通知の既読更新に失敗しました"
        }
    }
}
