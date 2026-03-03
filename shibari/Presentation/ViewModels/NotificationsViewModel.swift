import Foundation
import Observation

@Observable
class NotificationsViewModel {
    private let notificationRepository: NotificationRepository
    private let authRepository: AuthRepository
    
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
            
            self.notifications = try await notificationRepository.getNotifications(userId: uid)
        } catch {
            errorMessage = "データの読み込みに失敗しました"
        }
    }
}
