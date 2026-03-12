import SwiftUI

struct MainTabView: View {
    let currentUserId: String
    let groupId: String
    @State private var postQuestId: String? = nil
    @State private var timelineViewModel: TimelineViewModel
    @State private var questsViewModel: QuestsViewModel
    @State private var profileViewModel: ProfileViewModel
    
    var onLogoutRequest: () -> Void
    @EnvironmentObject var diContainer: AppDIContainer

    init(currentUserId: String, groupId: String, timelineViewModel: TimelineViewModel, questsViewModel: QuestsViewModel, profileViewModel: ProfileViewModel, onLogoutRequest: @escaping () -> Void) {
        self.currentUserId = currentUserId
        self.groupId = groupId
        self.onLogoutRequest = onLogoutRequest
        self._timelineViewModel = State(initialValue: timelineViewModel)
        self._questsViewModel = State(initialValue: questsViewModel)
        self._profileViewModel = State(initialValue: profileViewModel)
    }
        
    var body: some View {
        TabView {
            NavigationStack {
                TimelineView(viewModel: timelineViewModel)
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("タイムライン")
            }
            
            NavigationStack {
                QuestsView(
                    viewModel: questsViewModel,
                    onNavigateToPost: { questId in
                        self.postQuestId = questId
                    }
                )
                .navigationDestination(item: $postQuestId) { questId in
                    diContainer.makePostView(questId: questId)
                }
            }
            .tabItem {
                Image(systemName: "checkmark.circle.fill")
                Text("クエスト")
            }
            
            NavigationStack {
                ProfileView(viewModel: profileViewModel, onLogout: onLogoutRequest)
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
