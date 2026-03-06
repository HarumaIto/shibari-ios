import SwiftUI

struct ProfileSetupView: View {
    @Bindable var viewModel: ProfileSetupViewModel
    var onNavigateToNext: () -> Void
    
    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Spacer().frame(height: 40)
                
                VStack(spacing: 8) {
                    Text("プロフィール設定")
                        .font(.title)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    
                    Text("アプリ内で表示される名前を入力してください")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.white)
                        .font(.caption)
                        .padding()
                        .background(Color.red.opacity(0.8))
                        .cornerRadius(8)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    TextField("表示名 (ニックネーム)", text: $viewModel.displayName)
                        .padding()
                        .background(Color.slateSurface)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                    
                    Button(action: {
                        Task { await viewModel.saveProfile() }
                    }) {
                        if viewModel.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("登録して次へ")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.tacticalRed)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(viewModel.isLoading || viewModel.displayName.isEmpty)
                }
                .padding(.horizontal, 24)
                
                Spacer()
            }
        }
        .onChange(of: viewModel.isCompleted) { _, newValue in
            if newValue { onNavigateToNext() }
        }
    }
}

#Preview {
    ProfileSetupView(
        viewModel: ProfileSetupViewModel(
            userRepository: UserRepositoryMock(),
            authRepository: AuthRepositoryMock(),
            currentUserId: "mock_user_1"
        ),
        onNavigateToNext: {}
    )
    .environmentObject(AppDIContainer.mock)
}
