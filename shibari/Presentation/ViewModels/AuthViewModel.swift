import Foundation
import Observation
import GoogleSignIn
import AuthenticationServices
import CryptoKit
import Security

@MainActor
@Observable
class AuthViewModel {
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    
    // UI側の状態（State）
    var email = ""
    var password = ""
    var checkPassword = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var currentUserId: String? = nil
    var isAgreedToTerms: Bool = false
    var currentNonce: String? = nil
    
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
        guard !email.isEmpty, password.count >= 8, checkPassword.count >= 8 else { return }
        
        if password == checkPassword {
            self.errorMessage = "入力されたパスワードが一致しません。"
            return
        }
        
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
    
    func handleSignInWithAppleRequest(_ request: ASAuthorizationAppleIDRequest) {
        let nonce = randomNonceString()
        currentNonce = nonce
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
    }
        
    func handleSignInWithAppleCompletion(_ result: Result<ASAuthorization, Error>) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                guard let nonce = currentNonce else {
                    errorMessage = "Nonceが見つかりません。"
                    return
                }
                guard let appleIDToken = appleIDCredential.identityToken,
                      let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    errorMessage = "Apple ID トークンの取得に失敗しました。"
                    return
                }
                do {
                    let userId = try await authRepository.signInWithApple(
                        idToken: idTokenString,
                        nonce: nonce,
                        fullName: appleIDCredential.fullName
                    )
                    currentUserId = userId
                } catch {
                    errorMessage = error.localizedDescription
                }
            } else {
                errorMessage = "予期せぬ認証情報が返されました。"
            }
            
        case .failure(let error):
            // ユーザーが意図的にキャンセルした場合はエラーを表示しない（UX向上）
            if let asError = error as? ASAuthorizationError, asError.code == .canceled {
                return
            }
            errorMessage = error.localizedDescription
        }
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        var randomBytes = [UInt8](repeating: 0, count: length)
        let errorCode = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)
        if errorCode != errSecSuccess {
            errorMessage = "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
            return ""
        }
        
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        
        let nonce = randomBytes.map { byte in
            // Pick a random character from the set, wrapping around if needed.
            charset[Int(byte) % charset.count]
        }
        
        return String(nonce)
    }
    
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
