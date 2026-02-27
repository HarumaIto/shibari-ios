import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseMessaging

class AuthRepositoryImpl: AuthRepository {
    private let core = FirebaseApp.app()
    private let auth = Auth.auth()
    private let messaging = Messaging.messaging()
    
    func getClientId() -> String? {
        return core?.options.clientID
    }
    
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
    
    func getFCMToken() async throws -> String? {
        try? await messaging.token()
    }
    
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> String {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let authResult = try await auth.signIn(with: credential)
        
        return authResult.user.uid
    }
    
    func signInWithApple(idToken: String, nonce: String, fullName: PersonNameComponents?) async throws -> String {
        let credential = OAuthProvider.appleCredential(
            withIDToken: idToken,
            rawNonce: nonce,
            fullName: fullName
        )
        let authResult = try await auth.signIn(with: credential)
        
        return authResult.user.uid
    }
}
