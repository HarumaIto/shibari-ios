import SwiftUI

struct RootView: View {
    @State private var viewModel = RootViewModel()
    
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
                AuthSelectionView(
                    onNavigateToNext: { viewModel.checkAuthStatus() }
                )
                .onChange(of: viewModel.authRepository.getCurrentUserId()) { _, _ in viewModel.checkAuthStatus() }
                
            } else if viewModel.currentUser == nil {
                // 2. ログイン済みだがDBにプロフィールがない ➔ プロフィール登録画面
                ProfileSetupView(
                    viewModel: ProfileSetupViewModel(
                        userRepository: viewModel.userRepository,
                        authRepository: viewModel.authRepository,
                        currentUserId: viewModel.currentUserId!
                    ),
                    onNavigateToNext: { viewModel.checkAuthStatus() }
                )
                
            } else if viewModel.currentUser?.groupId == nil {
                // 3. プロフィールはあるがグループ未所属 ➔ グループ選択画面
                GroupSelectionView(
                    viewModel: GroupSelectionViewModel(
                        groupRepository: viewModel.groupRepository,
                        userRepository: viewModel.userRepository,
                        currentUserId: viewModel.currentUserId!
                    ),
                    onNavigateToNext: { viewModel.checkAuthStatus() }
                )
                
            } else if viewModel.currentUser?.participatingQuestIds.isEmpty ?? true {
                // 4. グループ所属済みだが、縛りが未選択 ➔ 縛り選択画面
                QuestSelectionView(
                    viewModel: QuestSelectionViewModel(
                        questRepository: viewModel.questRepository,
                        userRepository: viewModel.userRepository,
                        groupId: viewModel.currentUser!.groupId!,
                        currentUserId: viewModel.currentUserId!
                    ),
                    onNavigateToMain: { viewModel.checkAuthStatus() }
                )
                
            } else {
                // 5. すべて完了 ➔ メインのタブバー画面
                MainTabView(
                    currentUserId: viewModel.currentUserId!,
                    groupId: viewModel.currentUser!.groupId!,
                    timelineRepository: viewModel.timelineRepository,
                    userRepository: viewModel.userRepository,
                    reportRepository: viewModel.reportRepository,
                    authRepository: viewModel.authRepository,
                    questRepository: viewModel.questRepository,
                    groupRepository: viewModel.groupRepository,
                    onLogoutRequest: {
                        viewModel.checkAuthStatus()
                    }
                )
            }
        }
    }
}
