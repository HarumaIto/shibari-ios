import Foundation
import Observation

@MainActor
@Observable
class RootViewModel {
    let authRepository: AuthRepository = AuthRepositoryImpl()
    let userRepository: UserRepository = UserRepositoryImpl()
    let groupRepository: GroupRepository = GroupRepositoryImpl()
    let timelineRepository: TimelineRepository = TimelineRepositoryImpl()
    let reportRepository: ReportRepository = ReportRepositoryImpl()
    let questRepository: QuestRepository = QuestRepositoryImpl()
    
    var currentUserId: String? = nil
    var currentUser: User? = nil
    var isChecking: Bool = true // 初期ロード中フラグ
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        isChecking = true
        currentUserId = authRepository.getCurrentUserId()
        
        if let uid = currentUserId {
            Task {
                self.currentUser = try? await userRepository.getUser(userId: uid)
                self.isChecking = false
            }
        } else {
            self.currentUser = nil
            self.isChecking = false
        }
    }
}
