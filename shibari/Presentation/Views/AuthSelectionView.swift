import SwiftUI

struct AuthSelectionView: View {
    var viewModel: AuthViewModel
    var onNavigateToNext: () -> Void
    @EnvironmentObject var diContainer: AppDIContainer
    
    @State private var showingLogin = false
    @State private var showingSignUp = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景色を画面全体に敷く
                Color.slateBackground.ignoresSafeArea()
                
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
                    
                    // --- ボタンエリア ---
                    VStack(spacing: 16) {
                        // 新規登録ボタン
                        Button(action: {
                            showingSignUp = true
                        }) {
                            Text("新規登録")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.tacticalRed)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        
                        // ログインボタン
                        Button(action: {
                            showingLogin = true
                        }) {
                            Text("ログイン")
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.slateSurfaceVariant)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                        
                    }
                    .padding(.horizontal, 32)
                }
            }
            .navigationDestination(isPresented: $showingLogin) {
                    diContainer.makeLoginView(onNavigateToNext: onNavigateToNext)
            }
            .navigationDestination(isPresented: $showingSignUp) {
                    diContainer.makeSignUpView(onNavigateToNext: onNavigateToNext)
            }
        }
    }
}

#Preview {
    AuthSelectionView(
        viewModel: AuthViewModel(
            authRepository: AuthRepositoryMock(),
            userRepository: UserRepositoryMock()
        ),
        onNavigateToNext: {}
    )
        .environmentObject(AppDIContainer.mock)
}

