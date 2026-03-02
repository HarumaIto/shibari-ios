import SwiftUI

struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel
    var onLogout: () -> Void // ルート画面へ戻るためのコールバック
    
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false
    @State private var showingEditProfile = false
    @State private var showingQuestsProfile = false
    @State private var showingGroupView = false
    @State private var isCopied = false

    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()
            
            if viewModel.isLoading && viewModel.currentUser == nil {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .tacticalRed))
            } else {
                ScrollView {
                    VStack(spacing: 24) {
                        
                        VStack(spacing: 16) {
                            if let photoUrl = viewModel.currentUser?.photoUrl, let url = URL(string: photoUrl) {
                                AsyncImage(url: url) { phase in
                                    if let image = phase.image {
                                        image.resizable().scaledToFill()
                                    } else {
                                        // 読み込み中 or エラー時はイニシャルを表示
                                        FallbackIcon(
                                            name: viewModel.currentUser?.displayName ?? "",
                                            size: 80
                                        )
                                    }
                                }
                                .frame(width: 80, height: 80)
                                .clipShape(Circle())
                            } else {
                                FallbackIcon(
                                    name: viewModel.currentUser?.displayName ?? "",
                                    size: 80
                                )
                            }
                            
                            VStack(spacing: 4) {
                                Text(viewModel.currentUser?.displayName ?? "名称未設定")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("ID: \(viewModel.currentUser?.id.prefix(8) ?? "---")")
                                    .font(.caption)
                                    .foregroundColor(.textSecondary)
                            }
                        }
                        .padding(.top, 24)
                        
                        if let group = viewModel.currentGroup {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("グループ情報")
                                    .font(.headline)
                                    .foregroundColor(.textSecondary)
                                    .padding(.horizontal, 16)
                                
                                VStack(alignment: .leading, spacing: 16) {
                                    HStack {
                                        Text("グループ名")
                                            .foregroundColor(.textSecondary)
                                        Spacer()
                                        Text(group.name)
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                    }
                                    
                                    Divider().background(Color.slateSurfaceVariant)
                                    
                                    HStack {
                                        Text("招待コード")
                                            .foregroundColor(.textSecondary)
                                        Spacer()
                                        Text(group.invitationCode)
                                        .textSelection(.enabled)
                                            .font(.system(.body, design: .monospaced))
                                            .fontWeight(.bold)
                                            .foregroundColor(.achievementGold)
                                        Button(action: {
                                            UIPasteboard.general.string = group.invitationCode
                                            withAnimation {
                                                isCopied = true
                                            }
                                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                                withAnimation {
                                                    isCopied = false
                                                }
                                            }
                                        }) {
                                            Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                                                .foregroundColor(.textSecondary)
                                        }
                                    }
                                    Divider().background(Color.slateSurfaceVariant)
                                    
                                    Button(action: {
                                        showingGroupView = true
                                    }) {
                                        HStack {
                                            Text("グループ詳細")
                                                .foregroundColor(.textSecondary)
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                                .foregroundColor(.textSecondary)
                                        }
                                    }
                                }
                                .padding(16)
                                .background(Color.slateSurface)
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("参加中の縛り")
                                    .font(.headline)
                                    .foregroundColor(.textSecondary)
                                    .padding(.horizontal, 16)
                                Spacer()
                                Button {
                                    showingQuestsProfile = true
                                } label: {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.textSecondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 16)
                                }
                            }
                            
                            
                            if viewModel.participatingQuests.isEmpty {
                                Text("現在参加している縛りはありません。")
                                    .foregroundColor(.textSecondary)
                                    .padding(.horizontal, 16)
                            } else {
                                VStack(spacing: 8) {
                                    ForEach(viewModel.participatingQuests) { quest in
                                        HStack {
                                            Image(systemName: "checkmark.seal.fill")
                                                .foregroundColor(.successNeonGreen)
                                            Text(quest.title)
                                                .foregroundColor(.white)
                                            Spacer()
                                        }
                                        .padding()
                                        .background(Color.slateSurface)
                                        .cornerRadius(8)
                                    }
                                }
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        Spacer(minLength: 40)
                        
                        HStack(spacing: 16) {
                            Link("利用規約", destination: URL(string: termsUrl)!)
                            
                            Text("|").foregroundColor(.slateSurfaceVariant)
                            
                            Link("プライバシーポリシー", destination:  URL(string: privacyUrl)!)
                        }
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                        .padding(.bottom, 32)
                    }
                }
                .refreshable {
                    await viewModel.loadData()
                }
            }
        }
        .task {
            await viewModel.loadData()
        }
        .navigationTitle("プロフィール")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: {
                        showingEditProfile = true
                    }) {
                        Label("プロフィールを編集", systemImage: "pencil")
                    }
                    
                    Button(role: .destructive, action: {
                        showingLogoutAlert = true
                    }) {
                        Label("ログアウト", systemImage: "rectangle.portrait.and.arrow.right")
                    }
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        Label("退会する", systemImage: "person.crop.circle.badge.xmark")
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.white)
                        .padding()
                }
            }
        }
        // ログアウト確認アラート
        .alert("ログアウト", isPresented: $showingLogoutAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("ログアウト", role: .destructive) {
                viewModel.signOut()
            }
        } message: {
            Text("現在のアカウントからログアウトしますか？")
        }
        // 退会確認アラート
        .alert("本当に退会しますか？", isPresented: $showingDeleteAlert) {
            Button("キャンセル", role: .cancel) { }
            Button("退会する", role: .destructive) {
                Task { await viewModel.deleteAccount() }
            }
        } message: {
            Text("この操作は取り消せません。あなたの投稿は「退会済みユーザー」として残ります。")
        }
        // ViewModelでログアウト処理が完了したことを検知して親（MainTabView）に伝える
        .onChange(of: viewModel.isLoggedOut) { _, isOut in
            if isOut {
                onLogout()
            }
        }
        .navigationDestination(isPresented: $showingEditProfile) {
            ProfileEditView(
                viewModel: ProfileEditViewModel(
                    userRepository: UserRepositoryImpl(),
                    currentUserId: viewModel.currentUser?.id ?? ""
                )
            )
        }
        .onChange(of: showingEditProfile) { _, newValue in
            if newValue == false { reloadProfileIfNeeded() }
        }
        .navigationDestination(isPresented: $showingQuestsProfile) {
            QuestSelectionView(
                viewModel: QuestSelectionViewModel(
                    questRepository: QuestRepositoryImpl(),
                    userRepository: UserRepositoryImpl(),
                    groupId: viewModel.currentGroup?.id ?? "",
                    currentUserId: viewModel.currentUser?.id ?? ""
                ),
                onNavigateToMain: {
                    showingQuestsProfile = false
                }
            )
        }
        .onChange(of: showingQuestsProfile) { _, newValue in
            if newValue == false { reloadProfileIfNeeded() }
        }
        .navigationDestination(isPresented: $showingGroupView) {
            if let group = viewModel.currentGroup {
                GroupView(
                    group: group,
                    questRepository: QuestRepositoryImpl()
                )
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

    private func reloadProfileIfNeeded() {
        Task {
            await viewModel.loadData(forceReload: true)
        }
    }
}

#Preview {
    ProfileView(
        viewModel: ProfileViewModel(
            authRepository: AuthRepositoryMock(),
            userRepository: UserRepositoryMock(),
            groupRepository: GroupRepositoryMock(),
            questRepository: QuestRepositoryMock()
        ),
        onLogout: {}
    )
}
