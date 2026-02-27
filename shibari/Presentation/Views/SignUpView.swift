import SwiftUI
import AuthenticationServices

struct SignUpView: View {
    @Bindable var viewModel: AuthViewModel
    var onNavigateToNext: () -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()
                .onTapGesture {
                    isFocused = false
                }
            
            VStack(spacing: 16) {
                Text("新規登録")
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
                    
                    SecureField("パスワード (確認)", text: $viewModel.checkPassword)
                        .focused($isFocused)
                        .padding()
                        .background(Color.slateSurface)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 32)
                
                HStack(alignment: .center, spacing: 8) {
                    Button(action: {
                        // タップでチェック状態を切り替え
                        viewModel.isAgreedToTerms.toggle()
                    }) {
                        Image(systemName: viewModel.isAgreedToTerms ? "checkmark.square.fill" : "square")
                            .foregroundColor(viewModel.isAgreedToTerms ? .tacticalRed : .gray)
                            .font(.system(size: 20))
                    }
                    
                    // Markdown形式でリンクを設定
                    Text("[利用規約](\(termsUrl)) と [プライバシーポリシー](\(privacyUrl)) に同意する")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .tint(.tacticalRed)
                }
                .padding(.bottom, 8)
                
                VStack(spacing: 16) {
                    let isButtonDisabled = viewModel.isLoading || !viewModel.isAgreedToTerms
                    
                    Button(action: {
                        isFocused = false
                        Task { await viewModel.signUpWithEmail() }
                    }) {
                        if viewModel.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("新規登録")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.tacticalRed)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .opacity(isButtonDisabled || viewModel.email.isEmpty || viewModel.password.count < 8 || viewModel.checkPassword.count < 8 ? 0.5 : 1.0)
                    .disabled(isButtonDisabled || viewModel.email.isEmpty || viewModel.password.count < 8 || viewModel.checkPassword.count < 8)
                    
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
                            Text("Googleアカウントで登録")
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
                    .opacity(isButtonDisabled ? 0.5 : 1.0)
                    .disabled(isButtonDisabled)
                    
                    SignInWithAppleButton(.signUp) {request in
                        isFocused = false
                        viewModel.handleSignInWithAppleRequest(request)
                    } onCompletion: { result in
                        Task {
                            await viewModel.handleSignInWithAppleCompletion(result)
                        }
                    }
                    .signInWithAppleButtonStyle(.whiteOutline)
                    .frame(height: 54)
                    .opacity(isButtonDisabled ? 0.5 : 1.0)
                    .disabled(isButtonDisabled)
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
    SignUpView(
        viewModel: AuthViewModel(
            authRepository: AuthRepositoryImpl(),
            userRepository: UserRepositoryImpl()
        ),
        onNavigateToNext: {}
    )
}
