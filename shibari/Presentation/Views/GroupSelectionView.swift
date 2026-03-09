import SwiftUI

struct GroupSelectionView: View {
    @Bindable var viewModel: GroupSelectionViewModel
    var onNavigateToNext: () -> Void // 成功時のコールバック
    
    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 32) {
                    Text("グループの選択")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 40)
                    
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.white)
                            .font(.caption)
                            .padding()
                            .background(Color.red.opacity(0.8))
                            .cornerRadius(8)
                    }
                    
                    // --- 1. 新規作成 ---
                    VStack(alignment: .leading, spacing: 16) {
                        TextField("新しいグループ名", text: $viewModel.newGroupName)
                            .padding()
                            .background(Color.slateSurface)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        TextField("説明", text: $viewModel.newGroupDescription)
                            .padding()
                            .background(Color.slateSurface)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            Task { await viewModel.createGroup() }
                        }) {
                            if viewModel.isLoading {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("グループを作成")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.tacticalRed)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(viewModel.isLoading || viewModel.newGroupName.isEmpty)
                    }
                    .padding()
                    .background(Color.slateSurfaceVariant.opacity(0.3))
                    .cornerRadius(12)
                    
                    Text("または")
                        .foregroundColor(.textSecondary)
                        .fontWeight(.bold)
                    
                    // --- 2. 参加 ---
                    VStack(alignment: .leading, spacing: 16) {
                        TextField("招待コード", text: $viewModel.invitationCode)
                            .padding()
                            .background(Color.slateSurface)
                            .cornerRadius(8)
                            .foregroundColor(.white)
                        
                        Button(action: {
                            Task { await viewModel.joinGroup() }
                        }) {
                            if viewModel.isLoading {
                                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Text("グループに参加")
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.slateSurfaceVariant)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(viewModel.isLoading || viewModel.invitationCode.isEmpty)
                    }
                    .padding()
                    .background(Color.slateSurfaceVariant.opacity(0.3))
                    .cornerRadius(12)
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
            }
            .onChange(of: viewModel.isCompleted) { _, newValue in
                if newValue { onNavigateToNext() }
            }
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    GroupSelectionView(
        viewModel: GroupSelectionViewModel(
            groupRepository: GroupRepositoryMock(),
            userRepository: UserRepositoryMock(),
            currentUserId: "mock_user_1"
        ),
        onNavigateToNext: {}
    )
    .environmentObject(AppDIContainer.mock)
}
