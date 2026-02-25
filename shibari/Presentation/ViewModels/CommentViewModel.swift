import Foundation
import Observation

@MainActor
@Observable
class CommentViewModel {
    private let postId: String
    private let timelineRepository: TimelineRepository
    private let userRepository: UserRepository
    private let currentUserId: String
    
    var comments: [Comment] = []
    var newCommentText: String = ""
    
    var isLoading: Bool = true
    var isPosting: Bool = false
    var errorMessage: String? = nil
    
    private var commentTask: Task<Void, Never>? = nil
    
    init(postId: String, timelineRepository: TimelineRepository, userRepository: UserRepository, currentUserId: String) {
        self.postId = postId
        self.timelineRepository = timelineRepository
        self.userRepository = userRepository
        self.currentUserId = currentUserId
        
        startObserving()
    }
    
    func startObserving() {
        commentTask?.cancel()
        commentTask = Task { [weak self] in
            guard let self = self else { return }
            self.isLoading = true
            
            do {
                let stream = self.timelineRepository.getCommentsStream(postId: self.postId)
                for try await newComments in stream {
                    if Task.isCancelled { break }
                    self.comments = newComments
                    self.isLoading = false
                }
            } catch {
                self.errorMessage = "コメントの読み込みに失敗しました"
                self.isLoading = false
            }
        }
    }
    
    func postComment() async {
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        isPosting = true
        
        do {
            // 自分のユーザー情報を取得して、AuthorSnapshotを作る
            guard let user = try await userRepository.getUser(userId: currentUserId) else { return }
            let author = AuthorSnapshot(displayName: user.displayName, photoUrl: user.photoUrl)
            
            try await timelineRepository.addComment(postId: postId, author: author, userId: user.id, text: newCommentText)
            
            // 投稿成功したら入力欄を空にする
            self.newCommentText = ""
        } catch {
            self.errorMessage = "コメントの送信に失敗しました"
        }
        
        isPosting = false
    }
    
    func stopObserving() {
        commentTask?.cancel()
        commentTask = nil
    }
}
