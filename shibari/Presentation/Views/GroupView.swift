import SwiftUI

struct GroupView: View {
    @Bindable var viewModel: GroupViewModel
    @EnvironmentObject var diContainer: AppDIContainer

    @State private var showCopyToast = false
    
    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .tacticalRed))
            } else if viewModel.errorMessage != nil  || viewModel.group == nil {
                VStack(spacing: 16) {
                    Text("エラー: \(viewModel.errorMessage!)")
                        .foregroundColor(.red)
                    Button("再読み込み") {
                        Task { await viewModel.loadGroup() }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.slateSurface)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        headerSection
                        questsNavigationSection
                        invitationCardSection
                        membersSection
                    }
                    .padding(.vertical, 24)
                }
            }
        }
        .task {
            await viewModel.loadGroup()
        }
        .navigationTitle("グループ詳細")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(
            // コピー完了のトースト通知
            Text("招待コードをコピーしました！")
                .font(.footnote)
                .padding()
                .background(Color.black.opacity(0.8))
                .foregroundColor(.white)
                .cornerRadius(8)
                .offset(y: showCopyToast ? 0 : -20)
                .opacity(showCopyToast ? 1 : 0)
                .animation(.easeInOut, value: showCopyToast)
            , alignment: .bottom
        )
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text(viewModel.group!.name)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            Text(viewModel.group!.description)
                .font(.body)
                .foregroundColor(.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
        }
    }
    
    private var questsNavigationSection: some View {
        NavigationLink(destination: diContainer.makeGroupQuestListView(groupId: viewModel.group!.id)) {
            HStack(spacing: 16) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.tacticalRed.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "list.bullet.clipboard")
                        .foregroundColor(.tacticalRed)
                        .font(.system(size: 18, weight: .semibold))
                }
                
                // テキスト情報
                VStack(alignment: .leading, spacing: 4) {
                    Text("グループの縛り一覧")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("現在設定されているルールを確認")
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                // 遷移できることを示す矢印
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.textSecondary)
            }
            .padding(16)
            .background(Color.slateSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.slateSurfaceVariant, lineWidth: 1)
            )
        }
        .padding(.horizontal, 16)
    }
    
    private var invitationCardSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("友達を招待する")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                Text(viewModel.group!.invitationCode)
                    .font(.title3)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .tracking(2) // 文字間隔を広げてコードっぽく
                
                Spacer()
                
                Button(action: {
                    UIPasteboard.general.string = viewModel.group!.invitationCode
                    withAnimation { showCopyToast = true }
                    // 2秒後にトーストを消す
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { showCopyToast = false }
                    }
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.achievementGold)
                        .padding(8)
                        .background(Color.achievementGold.opacity(0.2))
                        .cornerRadius(8)
                }
            }
            .padding(16)
            .background(Color.slateSurface)
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
    }
    
    private var membersSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("メンバー")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("\(viewModel.group!.memberIds.count)人")
                    .font(.subheadline)
                    .foregroundColor(.textSecondary)
            }
            .padding(.horizontal, 16)
            
            LazyVStack(spacing: 0) {
                ForEach(viewModel.members) { member in
                    HStack(spacing: 16) {
                        // アイコン（モック）
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 40, height: 40)
                            .overlay(Text(String(member.displayName.prefix(1))).foregroundColor(.white))
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(member.displayName)
                                .font(.body)
                                .foregroundColor(.white)
                            
                            
                            if member.participatingQuestIds.isEmpty {
                                Text("挑戦中の縛りなし")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            } else {
                                HStack(spacing: 4) {
                                    Image(systemName: "flag.fill")
                                        .font(.caption2)
                                        .foregroundColor(.tacticalRed)
                                    
                                    Text(viewModel.getQuestTitles(member: member))
                                        .font(.caption)
                                        .foregroundColor(.textSecondary)
                                        .lineLimit(1)
                                }
                                
                            }
                        }
                        
                        Spacer()
                        
                        // オーナーバッジ
                        if member.id == viewModel.group!.ownerId {
                            Text("オーナー")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.tacticalRed.opacity(0.2))
                                .foregroundColor(.tacticalRed)
                                .cornerRadius(4)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    
                    Divider().background(Color.slateSurface)
                }
            }
            .background(Color.slateSurfaceVariant)
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
    }
}

#Preview {
    GroupView(
        viewModel: GroupViewModel(
            groupRepository: GroupRepositoryMock(),
            authRepository: AuthRepositoryMock(),
            userRepository: UserRepositoryMock(),
            questRepository: QuestRepositoryMock()
        )
    )
    .environmentObject(AppDIContainer.mock)
}
