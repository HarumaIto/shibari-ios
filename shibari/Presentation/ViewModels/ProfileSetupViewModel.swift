import Foundation
import Observation
import FirebaseMessaging

@MainActor
@Observable
class ProfileSetupViewModel {
    private let userRepository: UserRepository
    private let authRepository: AuthRepository
    private let currentUserId: String
    
    var displayName: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isCompleted: Bool = false
    
    init(userRepository: UserRepository, authRepository: AuthRepository, currentUserId: String) {
        self.userRepository = userRepository
        self.authRepository = authRepository
        self.currentUserId = currentUserId
    }
    
    func saveProfile() async {
        guard !displayName.isEmpty else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let fcmToken = try? await authRepository.getFCMToken()
            let newUser = User(
                id: currentUserId,
                displayName: displayName,
                photoUrl: nil,
                fcmToken: fcmToken,
                participatingQuestIds: [],
                groupId: nil,
                blockedUserIds: []
            )
            try await userRepository.createUser(user: newUser)
            isCompleted = true
        } catch {
            errorMessage = "プロフィールの登録に失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
