import SwiftUI

struct RootView: View {
    @State var viewModel: RootViewModel
    @EnvironmentObject var diContainer: AppDIContainer
    
    var body: some View {
        ZStack {
            if viewModel.isChecking {
                // 0. スプラッシュ
                ZStack {
                    Color.slateBackground.ignoresSafeArea()
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .tacticalRed))
                }
            } else if viewModel.currentUserId == nil {
                // 1. 未ログイン ➔ 認証画面
                diContainer.makeAuthSelectionView(onNavigateToNext: { viewModel.checkAuthStatus() })
                .onChange(of: viewModel.authRepository.getCurrentUserId()) { _, _ in viewModel.checkAuthStatus() }
                
            } else if viewModel.currentUser == nil {
                // 2. ログイン済みだがDBにプロフィールがない ➔ プロフィール登録画面
                diContainer.makeProfileSetupView(
                    currentUserId: viewModel.currentUserId!,
                    onNavigateToNext: { viewModel.checkAuthStatus() }
                )
                
            } else if viewModel.currentUser?.groupId == nil {
                // 3. プロフィールはあるがグループ未所属 ➔ グループ選択画面
                diContainer.makeGroupSelectionView(
                    currentUserId: viewModel.currentUserId!,
                    onNavigateToNext: { viewModel.checkAuthStatus() }
                )
                
            } else if viewModel.currentUser?.participatingQuestIds.isEmpty ?? true {
                // 4. グループ所属済みだが、縛りが未選択 ➔ 縛り選択画面
                diContainer.makeQuestSelectionView(
                    groupId: viewModel.currentUser!.groupId!,
                    currentUserId: viewModel.currentUserId!,
                    onNavigateToMain: { viewModel.checkAuthStatus() }
                )
                
            } else {
                // 5. すべて完了 ➔ メインのタブバー画面
                diContainer.makeMainTabView(
                    currentUserId: viewModel.currentUserId!,
                    groupId: viewModel.currentUser!.groupId!,
                    onLogoutRequest: {
                        viewModel.checkAuthStatus()
                    }
                )
            }
        }
    }
}
