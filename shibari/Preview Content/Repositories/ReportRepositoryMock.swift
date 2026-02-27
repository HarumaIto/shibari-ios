class ReportRepositoryMock: ReportRepository {
    func reportContent(reporterId: String, reportedUserId: String, postId: String, reason: String) async throws { }
}
