import Foundation
import Observation
import FirebaseFirestore // エラー判定用

@MainActor
@Observable
class TimelineViewModel {
    private let timelineRepository: TimelineRepository
    let userRepository: UserRepository
    private let reportRepository: ReportRepository
    
    let currentUserId: String
    private let groupId: String
    
    var posts: [TimelinePost] = []
    var isLoading: Bool = true
    var errorMessage: String? = nil
    
    // 監視用のタスクを保持（画面から消えた時や再読み込み時にキャンセルするため）
    private var timelineTask: Task<Void, Never>? = nil
    private var currentUser: User? = nil
    
    init(timelineRepository: TimelineRepository, userRepository: UserRepository, reportRepository: ReportRepository, currentUserId: String, groupId: String) {
        self.timelineRepository = timelineRepository
        self.userRepository = userRepository
        self.reportRepository = reportRepository
        self.currentUserId = currentUserId
        self.groupId = groupId
    }
    
    func startObserving() {
        // すでに監視中ならキャンセル
        timelineTask?.cancel()
            
        // ★修正: [weak self] をつけて循環参照（メモリリーク）を防ぐ
        timelineTask = Task { [weak self] in
            // selfがまだ存在するかチェックし、存在すれば以降の処理を実行
            guard let self = self else { return }
                
            self.isLoading = true
            do {
                self.currentUser = try await self.userRepository.getUser(userId: self.currentUserId)
                let blockedIds = self.currentUser?.blockedUserIds ?? []
                
                let stream = self.timelineRepository.getTimelineStream(groupId: self.groupId)
                for try await newPosts in stream {
                    if Task.isCancelled { break }
                    self.posts = newPosts.filter { !blockedIds.contains($0.userId) }
                    self.isLoading = false
                }
            } catch {
                let nsError = error as NSError
                if nsError.domain == FirestoreErrorDomain && nsError.code == FirestoreErrorCode.permissionDenied.rawValue {
                    print("ログアウトによる権限エラーをキャッチ（安全に無視）")
                } else {
                    self.errorMessage = "タイムラインの読み込みに失敗しました"
                    self.isLoading = false
                }
            }
        }
    }
        
    func stopObserving() {
        timelineTask?.cancel()
        timelineTask = nil
    }
    
    func vote(postId: String, voteType: VoteType) async {
        do {
            try await timelineRepository.votePost(postId: postId, userId: currentUserId, voteType: voteType)
        } catch {
            print("投票エラー: \(error)")
        }
    }
    
    func blockUser(targetUserId: String) async {
        do {
            try await userRepository.blockUser(currentUserId: currentUserId, targetUserId: targetUserId)
            // ブロック後、タイムラインを再読み込みしてUIから消す
            startObserving()
        } catch {
            print("ブロックエラー: \(error)")
        }
    }
    
    func reportPost(targetUserId: String, postId: String, reason: String) async {
        do {
            try await reportRepository.reportContent(reporterId: currentUserId, reportedUserId: targetUserId, postId: postId, reason: reason)
        } catch {
            print("通報エラー: \(error)")
        }
    }
}
