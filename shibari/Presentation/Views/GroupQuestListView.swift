import SwiftUI

struct GroupQuestListView: View {
    @Bindable var viewModel: GroupQuestListViewModel
    @State private var selectedQuest: Quest? = nil
    @State private var showingForm = false
    @EnvironmentObject var diContainer: AppDIContainer

    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()

            if viewModel.isLoading && viewModel.quests.isEmpty {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .tacticalRed))
            } else if viewModel.quests.isEmpty {
                Text("縛りがまだありません。\n「＋」ボタンから追加してください。")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.textSecondary)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.quests) { quest in
                            Button(action: {
                                selectedQuest = quest
                                showingForm = true
                            }) {
                                QuestListCardView(quest: quest)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(16)
                }
                .refreshable {
                    await viewModel.loadQuests()
                }
            }
        }
        .navigationTitle("グループの縛り一覧")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    selectedQuest = nil
                    showingForm = true
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.white)
                }
            }
        }
        .task {
            await viewModel.loadQuests()
        }
        .navigationDestination(isPresented: $showingForm) {
            diContainer.makeQuestFormView(
                groupId: viewModel.groupId,
                initialQuest: selectedQuest,
                onSaved: {
                    showingForm = false
                }
            )
        }
        .onChange(of: showingForm) { _, newValue in
            if !newValue {
                Task { await viewModel.loadQuests() }
                selectedQuest = nil
            }
        }
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
    }
}

fileprivate struct QuestListCardView: View {
    let quest: Quest

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text(quest.title)
                    .font(.headline)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.leading)

                if !quest.description.isEmpty {
                    Text(quest.description)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .multilineTextAlignment(.leading)
                }

                Text(quest.frequency.displayName)
                    .font(.caption2)
                    .foregroundColor(.achievementGold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.achievementGold.opacity(0.15))
                    .cornerRadius(4)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(.textSecondary)
        }
        .padding(16)
        .background(Color.slateSurfaceVariant)
        .cornerRadius(8)
    }
}

#Preview {
    NavigationStack {
        GroupQuestListView(
            viewModel: GroupQuestListViewModel(
                questRepository: QuestRepositoryMock(),
                groupId: "mock_group_id_456"
            )
        )
    }
    .environmentObject(AppDIContainer.mock)
}
