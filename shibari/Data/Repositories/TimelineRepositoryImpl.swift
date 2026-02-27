import Foundation
import FirebaseFirestore
import FirebaseStorage

class TimelineRepositoryImpl: TimelineRepository {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    // Kotlinの Flow に相当する処理
    func getTimelineStream(groupId: String) -> AsyncThrowingStream<[TimelinePost], Error> {
        AsyncThrowingStream { continuation in
            let listener = db.collection("timelines")
                .whereField("groupId", isEqualTo: groupId)
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    guard let documents = snapshot?.documents else {
                        continuation.yield([])
                        return
                    }
                    do {
                        // 取得したドキュメントをTimelinePostの配列に変換して流す
                        let dtos = try documents.compactMap { try $0.data(as: TimelinePostDto.self) }
                        let posts = dtos.map { $0.toDomain() }
                        continuation.yield(posts)
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            
            // 監視がキャンセルされたらListenerを解除する
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    func createPost(post: TimelinePost, mediaData: Data) async throws {
        let postId = UUID().uuidString
        
        let fileExtension: String
        let mimeType: String
        
        switch post.mediaType {
        case .video:
            fileExtension = "mp4"
            mimeType = "video/mp4"
        case .image:
            fileExtension = "jpg"
            mimeType = "image/jpeg"
        }
        
        let storageRef = storage.reference().child("posts/\(postId).\(fileExtension)")
        
        // 1. 画像をStorageにアップロード
        let metadata = StorageMetadata()
        metadata.contentType = mimeType
        let _ = try await storageRef.putDataAsync(mediaData, metadata: metadata)
        
        // 2. ダウンロードURLを取得
        let downloadUrl = try await storageRef.downloadURL()
        
        // 3. Firestoreに保存
        var newPost = TimelinePostDto.fromDomain(post)
        newPost.mediaUrl = downloadUrl.absoluteString
        
        try db.collection("timelines").document(postId).setData(from: newPost)
    }
    
    func votePost(postId: String, userId: String, voteType: VoteType) async throws {
        let postRef = db.collection("timelines").document(postId)
        
        // Firestoreのトランザクションを使って、カウントと投票履歴を安全に更新
        _ = try await db.runTransaction({ (transaction, errorPointer) -> Any? in
            do {
                let document = try transaction.getDocument(postRef)
                guard var dto = try? document.data(as: TimelinePostDto.self) else { return nil }
                
                // 投票を記録
                dto.votes[userId] = voteType.rawValue
                dto.approvalCount = dto.votes.values.filter { $0 == VoteType.APPROVE.rawValue } .count
                
                try transaction.setData(from: dto, forDocument: postRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
            }
            return nil
        })
    }
    
    // コメントをリアルタイム取得するストリーム（Flowの代わり）
    func getCommentsStream(postId: String) -> AsyncThrowingStream<[Comment], Error> {
        AsyncThrowingStream { continuation in
            // timelines/{postId}/comments コレクションを監視
            let listener = db.collection("timelines").document(postId).collection("comments")
                .order(by: "createdAt", descending: false) // 古い順（上から下へ）表示
                .addSnapshotListener { snapshot, error in
                    if let error = error {
                        continuation.finish(throwing: error)
                        return
                    }
                    guard let documents = snapshot?.documents else {
                        continuation.yield([])
                        return
                    }
                    let dtos = documents.compactMap { try? $0.data(as: CommentDto.self) }
                    let comments = dtos.map { $0.toDomain() }
                    continuation.yield(comments)
                }
            
            continuation.onTermination = { @Sendable _ in
                listener.remove()
            }
        }
    }
    
    // コメントを投稿する
    func addComment(postId: String, author: AuthorSnapshot, userId: String, text: String) async throws {
        let docRef = db.collection("timelines").document(postId).collection("comments").document()
        let comment = CommentDto(
            userId: userId,
            author: AuthorSnapshotDto.fromDomain(author),
            text: text,
        )
        try docRef.setData(from: comment)
    }
}
