import Foundation

struct Comment: Identifiable, Equatable {
    let id: String
    let userId: String
    let author: AuthorSnapshot
    let text: String
    let createdAt: Date
}
