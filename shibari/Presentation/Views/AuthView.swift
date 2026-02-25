import SwiftUI

struct AuthView: View {
    // ViewModelをバインディング
    @Bindable var viewModel: AuthViewModel
    
    var onNavigateToNext: () -> Void
    
    var body: some View {
        ZStack {
            // 背景色を画面全体に敷く
            Color.slateBackground.ignoresSafeArea()
            
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
                            .padding()
                            .background(Color.slateSurface)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never) // 自動大文字化を防ぐ
                            .autocorrectionDisabled(true)
                        
                        SecureField("パスワード (6文字以上)", text: $viewModel.password)
                            .padding()
                            .background(Color.slateSurface)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 32)
                    
                    // --- ボタンエリア ---
                    VStack(spacing: 16) {
                        // ログインボタン
                        Button(action: {
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
                        .disabled(viewModel.isLoading || viewModel.email.isEmpty || viewModel.password.count < 6)
                        
                        Divider()
                            .background(Color.slateSurfaceVariant)
                            .padding(.vertical, 8)
                        
                        // Googleログインボタン（UIのみのモック）
                        Button(action: {
                            // TODO: Google Sign-Inの実装
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
                        .disabled(viewModel.isLoading)
                    }
                    .padding(.horizontal, 32)
                    
                    Spacer()
                }
            }
        }
        // キーボード外をタップしたらキーボードを閉じる
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .onChange(of: viewModel.currentUserId) { _, newValue in
            if newValue != nil {
                onNavigateToNext()
            }
        }
    }
}
