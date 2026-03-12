import SwiftUI

struct QuestSelectionView: View {
    @Bindable var viewModel: QuestSelectionViewModel
    var onNavigateToMain: () -> Void
    
    @State private var showingQuestForm = false
    @EnvironmentObject var diContainer: AppDIContainer

    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()
            
            VStack(alignment: .leading, spacing: 0) {
                // ヘッダーテキスト
                VStack(alignment: .leading, spacing: 8) {
                    Text("縛りの選択")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.textPrimary)
                    
                    Text("参加する（監視される）縛りを選んでください。\n後からプロフィール画面でも変更できます。")
                        .font(.subheadline)
                        .foregroundColor(.textSecondary)
                }
                .padding(16)
                
                if viewModel.isLoading && viewModel.quests.isEmpty {
                    Spacer()
                    ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .tacticalRed))
                        .frame(maxWidth: .infinity)
                    Spacer()
                } else {
                    // クエスト一覧リスト
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(viewModel.quests) { quest in
                                let questId = quest.id
                                let isSelected = viewModel.selectedQuestIds.contains(questId)
                                
                                Button(action: {
                                    viewModel.toggleQuest(questId: questId)
                                }) {
                                    HStack(spacing: 16) {
                                        // iOS標準のチェックマークアイコンでCheckboxを代用
                                        Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                            .foregroundColor(isSelected ? .tacticalRed : .textSecondary)
                                            .font(.system(size: 24))
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(quest.title)
                                                .font(.headline)
                                                .foregroundColor(.textPrimary)
                                            
                                            if !quest.description.isEmpty {
                                                Text(quest.description)
                                                    .font(.caption)
                                                    .foregroundColor(.textSecondary)
                                                    .multilineTextAlignment(.leading)
                                            }
                                        }
                                        Spacer()
                                    }
                                    .padding(16)
                                    // 選択されている場合は背景色を少し変える
                                    .background(isSelected ? Color.tacticalRed.opacity(0.15) : Color.slateSurfaceVariant)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(isSelected ? Color.tacticalRed : Color.clear, lineWidth: 1)
                                    )
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            
                            Button(action: {
                                showingQuestForm = true
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "plus.circle.fill")
                                        .foregroundColor(.tacticalRed)
                                        .font(.system(size: 24))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("オリジナルの縛りを作る")
                                            .font(.headline)
                                            .foregroundColor(.tacticalRed)
                                        Text("自分たちだけのルールを追加できます")
                                            .font(.caption)
                                            .foregroundColor(.textSecondary)
                                    }
                                    Spacer()
                                }
                                .padding(16)
                                .background(Color.tacticalRed.opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    // 破線（ダッシュ線）にして「追加枠」っぽさを出す
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.tacticalRed.opacity(0.5), style: StrokeStyle(lineWidth: 1, dash: [5]))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(.top, 8)
                        }
                        .padding(.horizontal, 16)
                    }
                }
                
                // 下部固定の決定ボタン
                VStack {
                    Button(action: {
                        Task { await viewModel.saveSelection() }
                    }) {
                        if viewModel.isLoading {
                            ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))
                        } else {
                            Text("決定して始める")
                                .fontWeight(.bold)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.tacticalRed)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .disabled(viewModel.isLoading)
                }
                .padding(16)
            }
        }
        // 保存成功時の画面遷移
        .onChange(of: viewModel.isCompleted) { _, newValue in
            if newValue {
                viewModel.isCompleted = false
                onNavigateToMain()
            }
        }
        // エラー時のスナックバー（アラートで代用）
        .alert("エラー", isPresented: Binding<Bool>(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
        .sheet(isPresented: $showingQuestForm, onDismiss: {
            Task { await viewModel.refreshQuests() }
        }) {
            diContainer.makeQuestFormView(
                groupId: viewModel.groupId,
                initialQuest: nil,
                onSaved: {
                    showingQuestForm = false
                }
            )
        }
    }
}

#Preview {
    NavigationStack {
        QuestSelectionView(
            viewModel: QuestSelectionViewModel(
                questRepository: QuestRepositoryMock(),
                userRepository: UserRepositoryMock(),
                groupId: "mock_group_id",
                currentUserId: "mock_user_1"
            ),
            onNavigateToMain: {}
        )
    }
    .environmentObject(AppDIContainer.mock)
}
