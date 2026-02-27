import SwiftUI
import AuthenticationServices

struct AuthView: View {
    // ViewModelをバインディング
    @Bindable var viewModel: AuthViewModel
    
    var onNavigateToNext: () -> Void
    
    @FocusState private var isFocused: Bool
        
    var body: some View {
        ZStack {
            // 背景色を画面全体に敷く
            Color.slateBackground.ignoresSafeArea()
                .onTapGesture {
                    isFocused = false
                }
            
            ScrollView {
                VStack(spacing: 32) {
                    // --- ロゴ・タイトルエリア ---
                    VStack(spacing: 16) {
                        Image(systemName: "shield.checkerboard")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(Color.tacticalRed)
                        
                        Text("別働隊")
                            .font(.system(size: 40, weight: .black, design: .default))
                            .foregroundColor(.white)
                        
                        Text("- Shibari -")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
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
                    
                    // --- 入力エリア ---
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
                        
                        SecureField("パスワード (6文字以上)", text: $viewModel.password)
                            .focused($isFocused)
                            .padding()
                            .background(Color.slateSurface)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 32)
                    
                    // --- ボタンエリア ---
                    VStack(spacing: 16) {
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
                        
                        // ログインボタン
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
                        
                        // 新規登録ボタン
                        Button(action: {
                            isFocused = false
                            Task { await viewModel.signUpWithEmail() }
                        }) {
                            Text("新規登録")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.slateSurfaceVariant)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.count < 6 || !viewModel.isAgreedToTerms)
                        
                        Divider()
                            .background(Color.slateSurfaceVariant)
                            .padding(.vertical, 8)
                        
                        let isButtonDisabled = viewModel.isLoading || !viewModel.isAgreedToTerms
                        // Googleログインボタン
                        Button(action: {
                            isFocused = false
                            Task { await viewModel.signInWithGoogle() }
                        }) {
                            HStack {
                                Image(systemName: "g.circle.fill")
                                Text("Googleアカウントで連携")
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
                        
                        SignInWithAppleButton(.continue) {request in
                            isFocused = false
                            viewModel.handleSignInWithAppleRequest(request)
                        } onCompletion: { result in
                            Task {
                                await viewModel.handleSignInWithAppleCompletion(result)
                            }
                        }
                        .signInWithAppleButtonStyle(.whiteOutline)
                        .frame(height: 54)
                        .disabled(isButtonDisabled)
                        .opacity(isButtonDisabled ? 0.5 : 1.0)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
            .scrollDismissesKeyboard(.interactively)
        }
        .onChange(of: viewModel.currentUserId) { _, newValue in
            if newValue != nil {
                onNavigateToNext()
            }
        }
    }
}
