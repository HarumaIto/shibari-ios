import Foundation

struct Report: Identifiable, Equatable {
    let id: String
    let reporterId: String
    let reportedUserId: String
    let postId: String
    let reason: String
    let createdAt: Date
}
