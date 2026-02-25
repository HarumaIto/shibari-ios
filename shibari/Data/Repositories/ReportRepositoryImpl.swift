import Foundation
import FirebaseFirestore

class ReportRepositoryImpl: ReportRepository {
    private let db = Firestore.firestore()
    
    func reportContent(reporterId: String, reportedUserId: String, postId: String, reason: String) async throws {
        let report = ReportDto(
            reporterId: reporterId,
            reportedUserId: reportedUserId,
            postId: postId,
            reason: reason
        )
        try db.collection("reports").document().setData(from: report)
    }
}
