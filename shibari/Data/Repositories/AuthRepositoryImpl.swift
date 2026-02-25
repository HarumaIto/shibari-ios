import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging
import GoogleSignIn

class AuthRepositoryImpl: AuthRepository {
    private let auth = Auth.auth()
    private let messaging = Messaging.messaging()
    
    func getCurrentUserId() -> String? {
        return auth.currentUser?.uid
    }
    
    func signIn(email: String, password: String) async throws -> String {
        let result = try await auth.signIn(withEmail: email, password: password)
        return result.user.uid
    }
    
    func signUp(email: String, password: String) async throws -> String {
        let result = try await auth.createUser(withEmail: email, password: password)
        return result.user.uid
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func deleteAccount() async throws {
        guard let user = auth.currentUser else {
            throw NSError(domain: "AuthError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not logged in"])
        }
        try await user.delete()
    }
    
    func getFCMToken() async throws -> String? {
        try? await messaging.token()
    }
    
    @MainActor
    func signInWithGoogle() async throws -> String {
        // 1. FirebaseAppからクライアントIDを取得
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "FirebaseのクライアントIDが見つかりません。GoogleService-Info.plistを確認してください。"])
        }
            
        // 2. GoogleSignInの設定
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
            
        // 3. UIViewControllerを取得してGoogleのログインポップアップを表示
        guard let rootVC = WindowHelper.getRootViewController() else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "画面の取得に失敗しました。"])
        }
            
        // 4. Googleログインを実行し、結果を待つ
        let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
            
        // 5. Firebase用の認証トークンを取り出す
        guard let idToken = signInResult.user.idToken?.tokenString else {
            throw NSError(domain: "AuthError", code: -1, userInfo: [NSLocalizedDescriptionKey: "IDトークンの取得に失敗しました。"])
        }
        let accessToken = signInResult.user.accessToken.tokenString
        
        // 6. Firebase AuthにGoogleのトークンを渡してログイン！
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let authResult = try await Auth.auth().signIn(with: credential)
        
        return authResult.user.uid
    }
}
