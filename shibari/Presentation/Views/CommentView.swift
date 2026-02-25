import SwiftUI
import FirebaseCore

struct CommentView: View {
    @Bindable var viewModel: CommentViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            Text("通信記録（コメント）")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.slateSurface)
            
            // コメント一覧
            if viewModel.isLoading {
                Spacer()
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .tacticalRed))
                Spacer()
            } else if viewModel.comments.isEmpty {
                Spacer()
                Text("まだ通信記録はありません")
                    .foregroundColor(.textSecondary)
                Spacer()
            } else {
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 16) {
                            ForEach(viewModel.comments) { comment in
                                HStack(alignment: .top, spacing: 12) {
                                    // アイコン
                                    Circle()
                                        .fill(Color.slateSurfaceVariant)
                                        .frame(width: 36, height: 36)
                                        .overlay(Text(String(comment.author.displayName.prefix(1))).foregroundColor(.white).font(.caption))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(comment.author.displayName)
                                                .font(.caption)
                                                .fontWeight(.bold)
                                                .foregroundColor(.textSecondary)
                                            Spacer()
                                            Text(comment.createdAt, style: .time)
                                                .font(.caption2)
                                                .foregroundColor(.gray)
                                        }
                                        
                                        Text(comment.text)
                                            .font(.body)
                                            .foregroundColor(.white)
                                            .padding(10)
                                            .background(Color.slateSurfaceVariant)
                                            .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .id(comment.id) // スクロール位置の目印
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    // 新しいコメントが追加されたら一番下まで自動スクロール
                    .onChange(of: viewModel.comments.count) { _, _ in
                        if let lastId = viewModel.comments.last?.id {
                            withAnimation { proxy.scrollTo(lastId, anchor: .bottom) }
                        }
                    }
                }
            }
            
            // 入力エリア
            HStack(spacing: 12) {
                TextField("メッセージを入力...", text: $viewModel.newCommentText)
                    .padding(12)
                    .background(Color.slateBackground)
                    .cornerRadius(20)
                    .foregroundColor(.white)
                
                Button(action: {
                    Task { await viewModel.postComment() }
                }) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(viewModel.newCommentText.isEmpty ? .gray : .tacticalRed)
                        .font(.system(size: 20))
                        .padding(8)
                }
                .disabled(viewModel.newCommentText.isEmpty || viewModel.isPosting)
            }
            .padding()
            .background(Color.slateSurface)
        }
        .background(Color.slateBackground.ignoresSafeArea())
        .onDisappear {
            viewModel.stopObserving()
        }
    }
}
