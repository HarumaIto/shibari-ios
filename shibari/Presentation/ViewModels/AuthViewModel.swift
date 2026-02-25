import Foundation
import Observation
import GoogleSignIn

@MainActor
@Observable
class AuthViewModel {
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    
    // UI側の状態（State）
    var email = ""
    var password = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var currentUserId: String? = nil
    var isAgreedToTerms: Bool = false

    
    init(authRepository: AuthRepository, userRepository: UserRepository) {
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.currentUserId = authRepository.getCurrentUserId()
    }
    
    // メールアドレスでログイン
    func signInWithEmail() async {
        guard !email.isEmpty, password.count >= 6 else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let userId = try await authRepository.signIn(email: email, password: password)
            self.currentUserId = userId
        } catch {
            self.errorMessage = "ログインに失敗しました。メールアドレスとパスワードを確認してください。"
        }
        isLoading = false
    }
    
    // メールアドレスで新規登録
    func signUpWithEmail() async {
        guard !email.isEmpty, password.count >= 6 else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            let userId = try await authRepository.signUp(email: email, password: password)
            self.currentUserId = userId
        } catch {
            self.errorMessage = "登録に失敗しました: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            guard let clientID = authRepository.getClientId() else {
                throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "FirebaseのクライアントIDが見つかりません。GoogleService-Info.plistを確認してください。"])
            }
                    
            let config = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = config
                    
            guard let rootVC = WindowHelper.getRootViewController() else {
                throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "画面の取得に失敗しました。"])
            }
                    
            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
                    
            guard let idToken = signInResult.user.idToken?.tokenString else {
                throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "IDトークンの取得に失敗しました。"])
            }
            let accessToken = signInResult.user.accessToken.tokenString
            
            let userId = try await authRepository.signInWithGoogle(idToken: idToken, accessToken: accessToken)
            self.currentUserId = userId
        } catch {
            self.errorMessage = "Googleログインに失敗しました: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
}
