import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Bindable var viewModel: AuthViewModel
    var onNavigateToNext: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()
            
            VStack(spacing: 16) {
                Text("ログイン")
                    .font(.system(size: 40, weight: .black, design:.default))
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                // --- エラーメッセージ ---
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                        .padding(.horizontal, 32)
                }
                
                VStack(spacing: 16) {
                    TextField("メールアドレス", text: $viewModel.email)
                        .focused($isFocused)
                        .padding()
                        .background(Color.slateSurface)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never) // 自動大文字化を防ぐ
                        .autocorrectionDisabled(true)
                    
                    SecureField("パスワード", text: $viewModel.password)
                        .focused($isFocused)
                        .padding()
                        .background(Color.slateSurface)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 32)
                
                VStack(spacing: 16) {
                    Button(action: {
                        isFocused = false
                        Task { await viewModel.signInWithEmail() }
                    }) {
                        if viewModel.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("ログイン")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.tacticalRed)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.count < 6)
                    
                    Divider()
                        .background(Color.slateSurfaceVariant)
                        .padding(.vertical, 8)

                    // Googleログインボタン
                    Button(action: {
                        isFocused = false
                        Task { await viewModel.signInWithGoogle() }
                    }) {
                        HStack {
                            Image(systemName: "g.circle.fill")
                            Text("Googleアカウントでログイン")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.slateSurface)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    
                    SignInWithAppleButton(.signIn) {request in
                        isFocused = false
                        viewModel.handleSignInWithAppleRequest(request)
                    } onCompletion: { result in
                        Task {
                            await viewModel.handleSignInWithAppleCompletion(result)
                        }
                    }
                    .signInWithAppleButtonStyle(.whiteOutline)
                    .frame(height: 54)
                }
                .padding(.horizontal, 32)
            }
        }
        .onChange(of: viewModel.currentUserId) { _, newValue in
            if newValue != nil {
                onNavigateToNext()
            }
        }
    }
}

#Preview {
    LoginView(
        viewModel: AuthViewModel(
            authRepository: AuthRepositoryMock(),
            userRepository: UserRepositoryMock()
        ),
        onNavigateToNext: {}
    )
}
