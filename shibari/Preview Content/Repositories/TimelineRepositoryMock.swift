import Foundation

class TimelineRepositoryMock: TimelineRepository {
    // タイムラインのストリーム（監視）は、空の配列を1回だけ流して完了させます
    func getTimelineStream(groupId: String) -> AsyncThrowingStream<[TimelinePost], Error> {
        return AsyncThrowingStream { continuation in
            continuation.yield([
                TimelinePost(
                    userId: "mock_user_id_123",
                    questId: "mock_quest_id_123",
                    groupId: "mock_group_id_123",
                    author: AuthorSnapshot(
                        displayName: "Mock user",
                        photoUrl: nil
                    ),
                    quest: QuestSnapshot(
                        title: "Mock quest",
                        type: QuestType.ROUTINE
                    ),
                    mediaType: MediaType.image,
                    comment: "Mock comment",
                    status: PostStatus.pending
                )
            ])
        }
    }
    
    func createPost(post: TimelinePost, mediaData: Data) async throws { }
    func votePost(postId: String, userId: String, voteType: VoteType) async throws { }
    
    // コメントのストリームも同様に空配列を流します
    func getCommentsStream(postId: String) -> AsyncThrowingStream<[Comment], Error> {
        return AsyncThrowingStream { continuation in
            continuation.yield([])
        }
    }
    
    func addComment(postId: String, author: AuthorSnapshot, userId: String, text: String) async throws { }
}
