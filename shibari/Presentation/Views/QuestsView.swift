import SwiftUI

struct QuestsView: View {
    @Bindable var viewModel: QuestsViewModel
    var onNavigateToPost: (String) -> Void
    
    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()
            
            switch viewModel.uiState {
            case .loading:
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .tacticalRed))
            
            case .error(let message):
                VStack(spacing: 16) {
                    Text("エラー: \(message)")
                        .foregroundColor(.red)
                    Button("再読み込み") {
                        Task { await viewModel.loadMyQuests() }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.slateSurface)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            
            case .success(let groupedQuests):
                if groupedQuests.isEmpty {
                    VStack(spacing: 8) {
                        Text("現在参加している縛りはありません。")
                            .foregroundColor(.textPrimary)
                        Text("プロフィール画面から追加してください。")
                            .font(.footnote)
                            .foregroundColor(.textSecondary)
                    }
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 24) {
                            ForEach(groupedQuests) { group in
                                VStack(alignment: .leading, spacing: 12) {
                                
                                    // セクションヘッダー
                                    HStack {
                                        Text("\(group.frequency.displayName)クエスト") // ★ここを frequency に修正
                                            .font(.headline)
                                            .fontWeight(.bold)
                                            .foregroundColor(.achievementGold)
                                    
                                        Rectangle()
                                            .fill(Color.slateSurfaceVariant)
                                            .frame(height: 1)
                                    }
                                    .padding(.horizontal, 16)
                                
                                    // クエストカード一覧
                                    VStack(spacing: 16) {
                                        ForEach(group.quests) { quest in
                                            CardView(quest: quest) {
                                                onNavigateToPost(quest.id)
                                            }
                                            .padding(.horizontal, 16)
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .refreshable {
                        await viewModel.loadMyQuests(isRefresh: true)
                    }
                }
            }
        }
        .navigationTitle("今日のノルマ")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadMyQuests()
        }
    }
}

// Androidの Card + Column に相当する切り出しView
fileprivate struct CardView: View {
    let quest: Quest
    let onPostClick: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(quest.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.textPrimary)
                
                Text(quest.description)
                    .font(.body)
                    .foregroundColor(.textSecondary)
            }
            .padding(16)
            
            HStack {
                Spacer()
                Button(action: onPostClick) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("証拠を提出")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.tacticalRed)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.slateSurfaceVariant)
        .cornerRadius(12)
    }
}

#Preview {
    QuestsView(
        viewModel: QuestsViewModel(
            authRepository: AuthRepositoryMock(),
            userRepository: UserRepositoryMock(),
            questRepository: QuestRepositoryMock()
        ),
        onNavigateToPost: {_ in }
    )
}
