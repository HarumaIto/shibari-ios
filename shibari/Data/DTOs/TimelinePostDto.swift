import Foundation
import FirebaseFirestore

struct TimelinePostDto: Codable {
    @DocumentID var id: String?
    var userId: String
    var questId: String
    var groupId: String
    
    var author: AuthorSnapshotDto
    var quest: QuestSnapshotDto
    var aiJudgment: AiJudgmentDto?
    
    var mediaUrl: String
    var mediaType: String
    var comment: String
    
    var approvalCount: Int
    var rejectCount: Int?
    var votes: [String: String]
    var status: String
    
    var commentCount: Int?
    var latestComments: [String]?
    
    @ServerTimestamp var createdAt: Timestamp?
    
    func toDomain() -> TimelinePost {
        return TimelinePost(
            id: id ?? "",
            userId: userId,
            questId: questId,
            groupId: groupId,
            author: author.toDomain(),
            quest: quest.toDomain(),
            aiJudgment: aiJudgment?.toDomain(),
            mediaUrl: mediaUrl,
            // Enumの変換。失敗時は安全なデフォルト値を設定
            mediaType: MediaType(rawValue: mediaType) ?? .image,
            comment: comment,
            approvalCount: approvalCount,
            rejectCount: rejectCount ?? 0,
            votes: votes.compactMapValues { VoteType(rawValue: $0) },
            status: PostStatus(rawValue: status) ?? .pending,
            commentCount: commentCount ?? 0,
            latestComments: latestComments ?? [],
            // TimestampをDateに変換。nilの場合は現在時刻をフォールバック
            createdAt: createdAt?.dateValue() ?? Date(),
        )
    }
    
    static func fromDomain(_ domain: TimelinePost) -> TimelinePostDto {
        return TimelinePostDto(
            // Firestore側でIDを自動生成させる場合はnilを渡せるようにする
            id: domain.id.isEmpty ? nil : domain.id,
            userId: domain.userId,
            questId: domain.questId,
            groupId: domain.groupId,
            author: AuthorSnapshotDto.fromDomain(domain.author),
            quest: QuestSnapshotDto.fromDomain(domain.quest),
            aiJudgment: nil,
            mediaUrl: domain.mediaUrl,
            // EnumからString(rawValue)への変換
            mediaType: domain.mediaType.rawValue,
            comment: domain.comment,
            approvalCount: domain.approvalCount,
            rejectCount: domain.rejectCount,
            // Dictionaryの中のEnumも一括で変換
            votes: domain.votes.mapValues { $0.rawValue },
            status: domain.status.rawValue,
            commentCount: domain.commentCount,
            latestComments: domain.latestComments,
            // Date型をFirestore用のTimestamp型に変換
            createdAt: Timestamp(date: domain.createdAt),
        )
    }
}
