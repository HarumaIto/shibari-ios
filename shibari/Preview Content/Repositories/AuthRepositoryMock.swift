import Foundation

class AuthRepositoryMock: AuthRepository {
    func getClientId() -> String? {
        return "mock_client_id_123"
    }
    
    func getCurrentUserId() -> String? {
        // 未ログイン状態のUIを見たい時はここを nil に変更する
        return "mock_user_id_123"
    }
    
    func signIn(email: String, password: String) async throws -> String {
        return "mock_user_id_123"
    }
    
    func signUp(email: String, password: String) async throws -> String {
        return "mock_user_id_123"
    }
    
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> String {
        return "mock_user_id_123"
    }
    
    func signInWithApple(idToken: String, nonce: String, fullName: PersonNameComponents?) async throws -> String {
        return "mock_user_id_123"
    }
    
    func signOut() throws {
        // 何もせず成功
    }
    
    func getFCMToken() async throws -> String? {
        return "mock_fcm_token_abc"
    }
}
