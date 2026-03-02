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
    
    private var isCompletedRoutine: Bool {
        quest.type == .ROUTINE && quest.frequency != .ALWAYS && quest.isCompleted
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(quest.title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(isCompletedRoutine ? .textSecondary : .textPrimary)
                
                Text(quest.description)
                    .font(.body)
                    .foregroundColor(.textSecondary)
            }
            .padding(16)
            
            HStack {
                if isCompletedRoutine {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("期間内クリア")
                            .fontWeight(.bold)
                    }
                    .font(.caption)
                    .foregroundColor(.tacticalRed)
                }
                
                Spacer()
                Button(action: onPostClick) {
                    HStack {
                        Image(systemName: isCompletedRoutine ? "arrow.triangle.2.circlepath" : "plus.circle.fill")
                        Text(isCompletedRoutine ? "再提出" : "証拠を提出")
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(isCompletedRoutine ? Color.clear : Color.tacticalRed)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isCompletedRoutine ? Color.white : Color.clear, lineWidth: 0.5)
                    )
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 16)
        }
        .background(Color.slateSurfaceVariant.opacity(isCompletedRoutine ? 0.4 : 1.0))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCompletedRoutine ? Color.gray.opacity(0.2) : Color.clear, lineWidth: 1)
        )
    }
}

#Preview {
    QuestsView(
        viewModel: QuestsViewModel(
            authRepository: AuthRepositoryMock(),
            userRepository: UserRepositoryMock(),
            questRepository: QuestRepositoryMock(),
        ),
        onNavigateToPost: {_ in }
    )
}
