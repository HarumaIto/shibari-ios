import SwiftUI

struct MainTabView: View {
    let currentUserId: String
    let groupId: String
    @State private var postQuestId: String? = nil
    let timelineRepository: TimelineRepository
    let userRepository: UserRepository
    let reportRepository: ReportRepository
    let authRepository: AuthRepository
    let questRepository: QuestRepository
    let groupRepository: GroupRepository
    
    var onLogoutRequest: () -> Void
        
    var body: some View {
        TabView {
            NavigationStack {
                TimelineView(
                    viewModel: TimelineViewModel(
                        timelineRepository: timelineRepository,
                        userRepository: userRepository,
                        reportRepository: reportRepository,
                        currentUserId: currentUserId,
                        groupId: groupId
                    ),
                    groupRepository: groupRepository,
                    authRepository: authRepository
                )
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("タイムライン")
            }
            
            NavigationStack {
                QuestsView(
                    viewModel: QuestsViewModel(
                        authRepository: authRepository,
                        userRepository: userRepository,
                        questRepository: questRepository
                    ),
                    onNavigateToPost: { questId in
                        self.postQuestId = questId
                    }
                )
                .navigationDestination(item: $postQuestId) { questId in
                    PostView(
                        viewModel: PostViewModel(
                            questId: questId,
                            timelineRepository: timelineRepository,
                            authRepository: authRepository,
                            userRepository: userRepository,
                            questRepository: questRepository
                        )
                    )
                }
            }
            .tabItem {
                Image(systemName: "checkmark.circle.fill")
                Text("クエスト")
            }
            
            NavigationStack {
                ProfileView(
                    viewModel: ProfileViewModel(
                        authRepository: authRepository,
                        userRepository: userRepository,
                        groupRepository: groupRepository,
                        questRepository: questRepository
                    ),
                    onLogout: {
                        onLogoutRequest()
                    }
                )
            }
            .tabItem {
                Image(systemName: "person.crop.circle")
                Text("プロフィール")
            }
        }
        // タブが選択された時の色（タクティカルレッド）
        .tint(.tacticalRed)
        // タブバー全体の背景色設定（iOS 16+）
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.slateSurface)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}
