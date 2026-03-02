import SwiftUI

struct TimelineView: View {
    @Bindable var viewModel: TimelineViewModel
    
    var body: some View {
        ZStack {
            Color.slateBackground.ignoresSafeArea()
            
            if viewModel.isLoading {
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .tacticalRed))
            } else if viewModel.posts.isEmpty {
                VStack {
                    Image(systemName: "eyes")
                        .font(.system(size: 64))
                        .foregroundColor(.textSecondary)
                    Text("クエストの投稿はまだありません")
                        .foregroundColor(.textSecondary)
                        .padding(.top, 8)
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 24) {
                        ForEach(viewModel.posts) { post in
                            TimelinePostCard(
                                post: post,
                                currentUserId: viewModel.currentUserId,
                                onVote: { type in
                                    Task { await viewModel.vote(postId: post.id, voteType: type) }
                                },
                                onReport: { reason in
                                    Task { await viewModel.reportPost(targetUserId: post.userId, postId: post.id, reason: reason) }
                                },
                                onBlock: {
                                    Task { await viewModel.blockUser(targetUserId: post.userId) }
                                }
                            )
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
                // iOS15以降の引っ張って更新
                .refreshable {
                    viewModel.startObserving()
                }
            }
        }
        .navigationTitle("タイムライン")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink(
                    destination: GroupView(
                        viewModel: GroupViewModel(
                            groupRepository: GroupRepositoryImpl(),
                            authRepository: AuthRepositoryImpl(),
                            userRepository: UserRepositoryImpl()
                        ),
                    )) {
                        Image(systemName: "person.2.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
            }
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink(
                    destination: NotificationsView()) {
                        Image(systemName: "bell.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                    }
            }
        }
        .onDisappear {
            viewModel.stopObserving()
        }
        .task {
            viewModel.startObserving()
        }
    }
}


#Preview {
    TimelineView(
        viewModel: TimelineViewModel(
            timelineRepository: TimelineRepositoryMock(),
            userRepository: UserRepositoryMock(),
            reportRepository: ReportRepositoryMock(),
            currentUserId: "mock_user_id_123",
            groupId: "mock_group_id_123"
        )
    )
}
