import Foundation

class TimelineRepositoryMock: TimelineRepository {
    // タイムラインのストリーム（監視）は、空の配列を1回だけ流して完了させます
    func getTimelineStream(groupId: String) -> AsyncThrowingStream<[TimelinePost], Error> {
        return AsyncThrowingStream { continuation in
            continuation.yield([]) // ダミーの投稿を入れるとタイムラインのUIテストができます
            // continuation.finish() // 必要であればストリームを終了させる
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
