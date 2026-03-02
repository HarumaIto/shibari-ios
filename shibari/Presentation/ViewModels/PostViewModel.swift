import Foundation
import Observation
import PhotosUI
import SwiftUI

@MainActor
@Observable
class PostViewModel {
    private let timelineRepository: TimelineRepository
    private let authRepository: AuthRepository
    private let userRepository: UserRepository
    private let questRepository: QuestRepository
    
    let questId: String
    
    var comment: String = ""
    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isCompleted: Bool = false // 成功時の画面遷移トリガー
    
    // PhotosPickerで選ばれたアイテム
    var selectedItem: PhotosPickerItem? = nil {
        didSet {
            // アイテムが選ばれたら、非同期で画像データを読み込む
            Task { await loadMedia() }
        }
    }
    // 実際にプレビュー・送信するためのデータ
    var selectedMediaData: Data? = nil
    var isSelectedMediaVideo: Bool = false
    
    init(questId: String, timelineRepository: TimelineRepository, authRepository: AuthRepository, userRepository: UserRepository, questRepository: QuestRepository) {
        self.questId = questId
        self.timelineRepository = timelineRepository
        self.authRepository = authRepository
        self.userRepository = userRepository
        self.questRepository = questRepository
    }
    
    private func loadMedia() async {
        guard let item = selectedItem else { return }
        isLoading = true
        do {
            let isVideo = item.supportedContentTypes.contains { type in
                type.conforms(to: .movie) || type.conforms(to: .video)
            }
            
            if isVideo {
                if let data = try await item.loadTransferable(type: Data.self) {
                    let maxVideoSize = 50 * 1024 * 1024 // 50MB
                    if data.count > maxVideoSize {
                        errorMessage = "動画が大きすぎます。50MB以下のものを選んでください。"
                        selectedItem = nil
                        selectedMediaData = nil
                    } else {
                        isSelectedMediaVideo = true
                        selectedMediaData = data
                    }
                }
            } else {
                if let data = try await item.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    // 先ほど作成したヘルパー関数を使用
                    if let compressedData = ImageHelper.compressImage(image: image, maxSize: 1080, quality: 0.8) {
                        isSelectedMediaVideo = false
                        selectedMediaData = compressedData
                    } else {
                        errorMessage = "画像の処理に失敗しました。"
                        selectedItem = nil
                        selectedMediaData = nil
                    }
                } else {
                    errorMessage = "対応していない画像フォーマットです。"
                    selectedItem = nil
                    selectedMediaData = nil
                }
            }
        } catch {
            errorMessage = "メディアの読み込みに失敗しました"
        }
        isLoading = false
    }
    
    func submitPost() async {
        guard let mediaData = selectedMediaData else {
            errorMessage = "証拠メディアを選択してください"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. 必要な情報を取得
            guard let userId = authRepository.getCurrentUserId() else {
                throw NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "認証エラーです。再ログインしてください"])
            }
            guard let user = try await userRepository.getUser(userId: userId),
                  let groupId = user.groupId else {
                throw NSError(domain: "", code: 403, userInfo: [NSLocalizedDescriptionKey: "グループに所属していません。"])
            }
            
            let allQuests = try await questRepository.getGroupQuests(groupId: groupId)
            guard let quest = allQuests.first(where: { $0.id == questId }) else {
                throw NSError(domain: "", code: 404, userInfo: [NSLocalizedDescriptionKey: "クエスト情報が見つかりません。"])
            }
            
            // 2. TimelinePost（非正規化データを含む）の組み立て
            let authorSnapshot = AuthorSnapshot(displayName: user.displayName, photoUrl: user.photoUrl)
            let questSnapshot = QuestSnapshot(title: quest.title, type: quest.type)
            
            let post = TimelinePost(
                userId: userId,
                questId: questId,
                groupId: groupId,
                author: authorSnapshot,
                quest: questSnapshot,
                mediaType: isSelectedMediaVideo ? .video : .image,
                comment: comment,
                status: .pending
            )
            
            // 3. アップロード実行
            try await timelineRepository.createPost(post: post, mediaData: mediaData)
            isCompleted = true // 成功したらフラグを立てて画面を戻る
            
        } catch {
            let nsError = error as NSError
            // Android版にあったエラーハンドリングの再現
            if nsError.domain == NSURLErrorDomain {
                errorMessage = "通信環境の良いところで再度お試しください"
            } else {
                errorMessage = "投稿に失敗しました: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
}
