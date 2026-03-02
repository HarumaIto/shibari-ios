import SwiftUI

struct GroupView: View {
    let group: Group
    let questRepository: QuestRepository

    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // グループ基本情報
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("グループ名")
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text(group.name)
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                        }

                        if !group.description.isEmpty {
                            Divider().background(Color.slateSurfaceVariant)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("説明")
                                    .foregroundColor(.textSecondary)
                                Text(group.description)
                                    .foregroundColor(.textPrimary)
                            }
                        }

                        Divider().background(Color.slateSurfaceVariant)

                        HStack {
                            Text("メンバー数")
                                .foregroundColor(.textSecondary)
                            Spacer()
                            Text("\(group.memberIds.count)人")
                                .fontWeight(.bold)
                                .foregroundColor(.textPrimary)
                        }
                    }
                    .padding(16)
                    .background(Color.slateSurface)
                    .cornerRadius(12)

                    // グループの縛り一覧バナー
                    NavigationLink(destination: GroupQuestListView(
                        viewModel: GroupQuestListViewModel(
                            questRepository: questRepository,
                            groupId: group.id
                        )
                    )) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("グループの縛り一覧")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.textPrimary)
                                Text("縛りの追加・編集ができます")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.textSecondary)
                        }
                        .padding(16)
                        .background(Color.slateSurface)
                        .cornerRadius(12)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(16)
            }
        }
        .navigationTitle("グループ詳細")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        GroupView(
            group: Group(
                id: "mock_group_id_456",
                name: "Mock group",
                description: "Mock group description",
                ownerId: "mock_user_id_123",
                memberIds: ["mock_user_id_123"],
                invitationCode: "MOCK_CODE"
            ),
            questRepository: QuestRepositoryMock()
        )
    }
}
