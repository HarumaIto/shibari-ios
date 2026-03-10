import SwiftUI

struct MainTabView: View {
    let currentUserId: String
    let groupId: String
    @State private var postQuestId: String? = nil
    
    var onLogoutRequest: () -> Void
    @EnvironmentObject var diContainer: AppDIContainer
        
    var body: some View {
        TabView {
            NavigationStack {
                diContainer.makeTimelineView(currentUserId: currentUserId, groupId: groupId)
            }
            .tabItem {
                Image(systemName: "list.bullet")
                Text("タイムライン")
            }
            
            NavigationStack {
                diContainer.makeQuestsView(onNavigateToPost: { questId in
                    self.postQuestId = questId
                })
                .navigationDestination(item: $postQuestId) { questId in
                    diContainer.makePostView(questId: questId)
                }
            }
            .tabItem {
                Image(systemName: "checkmark.circle.fill")
                Text("クエスト")
            }
            
            NavigationStack {
                diContainer.makeProfileView(onLogout: onLogoutRequest)
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
