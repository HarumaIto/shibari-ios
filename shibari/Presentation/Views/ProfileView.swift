import SwiftUI

struct ProfileView: View {
    @Bindable var viewModel: ProfileViewModel
    var onLogout: () -> Void // ルート画面へ戻るためのコールバック
    
    @State private var showingLogoutAlert = false
    @State private var showingDeleteAlert = false
    @State private var showingEditProfile = false
    
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
                                            .font(.system(.body, design: .monospaced))
                                            .fontWeight(.bold)
                                            .foregroundColor(.achievementGold)
                                    }
                                }
                                .padding(16)
                                .background(Color.slateSurface)
                                .cornerRadius(12)
                                .padding(.horizontal, 16)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("参加中の縛り")
                                .font(.headline)
                                .foregroundColor(.textSecondary)
                                .padding(.horizontal, 16)
                            
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
        // ★ ヘッダー右上の「︙（ケバブメニュー）」
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
