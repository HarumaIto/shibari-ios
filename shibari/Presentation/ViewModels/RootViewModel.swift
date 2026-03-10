import Foundation
import Observation

@MainActor
@Observable
class RootViewModel {
    let authRepository: AuthRepository
    let userRepository: UserRepository
    let groupRepository: GroupRepository
    let timelineRepository: TimelineRepository
    let reportRepository: ReportRepository
    let questRepository: QuestRepository
    
    var currentUserId: String? = nil
    var currentUser: User? = nil
    var isChecking: Bool = true // 初期ロード中フラグ
    
    init(
        authRepository: AuthRepository,
        userRepository: UserRepository,
        groupRepository: GroupRepository,
        timelineRepository: TimelineRepository,
        reportRepository: ReportRepository,
        questRepository: QuestRepository
    ) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.groupRepository = groupRepository
        self.timelineRepository = timelineRepository
        self.reportRepository = reportRepository
        self.questRepository = questRepository
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        isChecking = true
        currentUserId = authRepository.getCurrentUserId()
        
        if let uid = currentUserId {
            Task {
                self.currentUser = try? await userRepository.getUser(userId: uid)
                self.isChecking = false
                // 起動時に最新のFCMトークンをFirestoreに反映する
                if let token = try? await authRepository.getFCMToken() {
                    do {
                        try await userRepository.updateFcmToken(userId: uid, fcmToken: token)
                    } catch {
                        print("FCMトークンのFirestore更新に失敗しました: \(error)")
                    }
                } else {
                    print("FCMトークンの取得に失敗しました。")
                }
            }
        } else {
            self.currentUser = nil
            self.isChecking = false
        }
    }
}
