import Foundation

struct User: Identifiable, Equatable {
    let id: String
    var displayName: String
    var photoUrl: String?
    var fcmToken: String?
    var participatingQuestIds: [String]
    var groupId: String?
    var blockedUserIds: [String]
}
