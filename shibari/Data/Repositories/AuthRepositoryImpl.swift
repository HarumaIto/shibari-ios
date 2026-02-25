import Foundation
import FirebaseAuth
import FirebaseMessaging

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
    
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> String {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let result = try await auth.signIn(with: credential)
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
}
