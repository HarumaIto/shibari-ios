import Foundation

struct TimelinePost: Identifiable, Equatable {
    var id: String = ""
    let userId: String
    let questId: String
    let groupId: String
    let author: AuthorSnapshot
    let quest: QuestSnapshot
    var mediaUrl: String  = ""
    let mediaType: MediaType
    let comment: String
    var approvalCount: Int = 0
    var votes: [String: VoteType] = [:]
    let status: PostStatus
    var commentCount: Int = 0
    var latestComments: [String] = []
    
    var createdAt: Date = Date()
}
