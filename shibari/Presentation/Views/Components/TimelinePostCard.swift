import SwiftUI
import AVKit

// MARK: - 投稿カード UI
struct TimelinePostCard: View {
    let post: TimelinePost
    let currentUserId: String
    let onVote: (VoteType) -> Void
    let onReport: (String) -> Void
    let onBlock: () -> Void
    
    @State private var showingReportAlert = false
    @State private var reportReason = ""
    @State private var showingComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // --- 1. ヘッダー部（投稿者情報とメニュー） ---
            HStack {
                if let photoUrl = post.author.photoUrl, let url = URL(string: photoUrl) {
                    FeedImageView(url: url)
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                } else {
                    FallbackIcon(
                        name: post.author.displayName,
                        size: 40
                    )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(post.author.displayName)
                        .font(.headline)
                        .foregroundColor(.textPrimary)
                    Text("クエスト: \(post.quest.title)")
                        .font(.caption)
                        .foregroundColor(.achievementGold)
                }
                
                Spacer()
                
                Text(statusDisplayName(for: post.status))
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.3)) // Androidの LightGray.copy(alpha = 0.3f) に相当
                    .cornerRadius(4)
                
                // 自分以外の投稿ならケバブメニュー(︙)を表示
                if post.userId != currentUserId {
                    Menu {
                        Button("不適切なコンテンツを通報") {
                            showingReportAlert = true
                        }
                        Button(role: .destructive, action: onBlock) {
                            Text("このユーザーをブロック")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.textSecondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 16)
                    }
                }
            }
            .padding(16)
            
            // --- 2. 証拠画像 ---
            if let mediaUrl = URL(string: post.mediaUrl) {
                Rectangle()
                    .fill(Color.black)
                    .aspectRatio(1.0, contentMode: .fit) // 幅に合わせて完璧な正方形にする
                    .overlay(
                        SwiftUI.Group {
                            if post.mediaType == .video {
                                FeedVideoPlayer(url: mediaUrl)
                            } else {
                                FeedImageView(url: mediaUrl)
                            }
                        }
                    )
                    .clipped()
            }
            
            // --- 3. コメントと投票エリア ---
            VStack(alignment: .leading, spacing: 16) {
                if !post.comment.isEmpty {
                    Text(post.comment)
                        .foregroundColor(.textPrimary)
                        .font(.body)
                }
                
                // 投票ボタン（承認 / 否認）
                HStack(spacing: 12) {
                    Button(action: {
                        showingComments = true
                    }) {
                        Image(systemName: "message")
                            .font(.system(size: 20))
                            .foregroundColor(.textSecondary)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 16)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.slateSurfaceVariant, lineWidth: 1)
                            )
                    }
                    // 否認ボタン（タクティカルレッド）
                    Button(action: { onVote(.REJECT) }) {
                        HStack {
                            Image(systemName: "xmark.shield.fill")
                            Text("否認")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(post.votes[currentUserId] == VoteType.REJECT ? Color.tacticalRed.opacity(0.2) : Color.clear)
                        .foregroundColor(.tacticalRed)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.tacticalRed, lineWidth: 1)
                        )
                    }
                    // 承認ボタン（ネオングリーン）
                    Button(action: { onVote(.APPROVE) }) {
                        HStack {
                            Image(systemName: "checkmark.seal.fill")
                            Text("承認 (\(post.approvalCount))")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(post.votes[currentUserId] == VoteType.APPROVE ? Color.successNeonGreen.opacity(0.2) : Color.clear)
                        .foregroundColor(.successNeonGreen)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.successNeonGreen, lineWidth: 1)
                        )
                    }
                }
            }
            .padding(16)
        }
        .background(Color.slateSurface)
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
        // 通報時の理由入力ダイアログ
        .alert("通報の理由", isPresented: $showingReportAlert) {
            TextField("例: 暴言が含まれている", text: $reportReason)
            Button("キャンセル", role: .cancel) { reportReason = "" }
            Button("通報する", role: .destructive) {
                if !reportReason.isEmpty {
                    onReport(reportReason)
                    reportReason = ""
                }
            }
        }
        .sheet(isPresented: $showingComments) {
            CommentView(
                viewModel: CommentViewModel(
                    postId: post.id,
                    timelineRepository: TimelineRepositoryImpl(), // 簡易生成
                    userRepository: UserRepositoryImpl(),       // 簡易生成
                    currentUserId: currentUserId
                )
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
    
    private func statusDisplayName(for status: PostStatus) -> String {
        switch status {
        case .pending:
            return "審査中"
        case .approved:
            return "承認済"
        case .rejected:
            return "否認"
        }
    }
}

// MARK: - タイムライン専用 画像プレイヤー (スクロールキャンセル対策版)
struct FeedImageView: View {
    let url: URL
    
    @State private var uiImage: UIImage? = nil
    @State private var hasError: Bool = false
    
    var body: some View {
        ZStack {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else if hasError {
                Color.slateSurfaceVariant
                    .overlay(
                        VStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle").foregroundColor(.red)
                            Text("読込失敗").font(.caption2).foregroundColor(.textSecondary)
                        }
                    )
            } else {
                Color.slateSurfaceVariant
                    .overlay(ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .tacticalRed)))
            }
        }
        .onAppear {
            loadImage()
        }
    }
    
    private func loadImage() {
        // すでに読み込み済み、またはエラー確定済みの場合は何もしない
        guard uiImage == nil && !hasError else { return }
        
        Task {
            do {
                // AsyncImageを使わず、URLSessionで直接データを引っこ抜く
                let (data, _) = try await URLSession.shared.data(from: url)
                if let image = UIImage(data: data) {
                    // アニメーション付きでフワッと表示
                    withAnimation(.easeIn(duration: 0.2)) {
                        self.uiImage = image
                    }
                } else {
                    self.hasError = true
                }
            } catch {
                // スクロール等による勝手なキャンセルを無視する
                if !Task.isCancelled {
                    self.hasError = true
                }
            }
        }
    }
}

// MARK: - タイムライン専用 動画プレイヤー
struct FeedVideoPlayer: View {
    let url: URL
    // プレイヤーを状態として保持し、再描画時のチラつきを防ぐ
    @State private var player: AVPlayer?
    
    var body: some View {
        ZStack {
            // 動画の黒帯部分の背景
            Color.black
            
            if let player = player {
                // iOS標準の動画プレイヤー（再生/一時停止などのコントロール付き）
                VideoPlayer(player: player)
            } else {
                // プレイヤーの準備ができるまでのローディング
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .tacticalRed))
            }
        }
        .onAppear {
            // 画面に表示されたらプレイヤーを生成して自動再生
            if player == nil {
                let newPlayer = AVPlayer(url: url)
                self.player = newPlayer
                newPlayer.play()
            } else {
                // すでにプレイヤーがある場合は再生を再開
                player?.play()
            }
        }
        .onDisappear {
            // スクロールして画面外に出たら、通信量とバッテリー節約のために自動停止
            player?.pause()
        }
    }
}
