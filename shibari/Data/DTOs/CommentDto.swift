import Foundation
import FirebaseFirestore

struct CommentDto: Codable, Identifiable {
    @DocumentID var id: String?
    var userId: String
    var author: AuthorSnapshotDto
    var text: String
    @ServerTimestamp var createdAt: Timestamp?
    
    func toDomain() -> Comment {
        return Comment(
            id: id ?? "",
            userId: userId,
            author: author.toDomain(),
            text: text,
            createdAt: createdAt?.dateValue() ?? Date()
        )
    }
        
    static func fromDomain(_ domain: Comment) -> CommentDto {
        return CommentDto(
            id: domain.id.isEmpty ? nil : domain.id,
            userId: domain.userId,
            author: AuthorSnapshotDto.fromDomain(domain.author),
            text: domain.text,
            createdAt: Timestamp(date: domain.createdAt)
        )
    }
}
