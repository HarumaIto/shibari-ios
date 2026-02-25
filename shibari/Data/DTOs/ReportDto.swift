import Foundation
import FirebaseFirestore

struct ReportDto: Codable, Identifiable {
    @DocumentID var id: String?
    var reporterId: String
    var reportedUserId: String
    var postId: String
    var reason: String
    @ServerTimestamp var createdAt: Timestamp?
    
    func toDomain() -> Report {
        return Report(
            id: id ?? "",
            reporterId: reporterId,
            reportedUserId: reportedUserId,
            postId: postId,
            reason: reason,
            createdAt: createdAt?.dateValue() ?? Date()
        )
    }
    
    static func fromDomain(_ domain: Report) -> ReportDto {
        return ReportDto(
            id: domain.id.isEmpty ? nil : domain.id,
            reporterId: domain.reporterId,
            reportedUserId: domain.reportedUserId,
            postId: domain.postId,
            reason: domain.reason,
            createdAt: Timestamp(date: domain.createdAt)
        )
    }
}
