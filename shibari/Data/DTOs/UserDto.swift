import Foundation
import FirebaseFirestore

struct UserDto: Codable {
    @DocumentID var id: String?
    var displayName: String
    var photoUrl: String?
    var fcmToken: String?
    var participatingQuestIds: [String]
    var groupId: String?
    var blockedUserIds: [String]
    
    // DTO -> Domain
    func toDomain() -> User {
        return User(
            id: id ?? "",
            displayName: displayName,
            photoUrl: photoUrl,
            fcmToken: fcmToken,
            participatingQuestIds: participatingQuestIds,
            groupId: groupId,
            blockedUserIds: blockedUserIds
        )
    }
    
    // Domain -> DTO
    static func fromDomain(_ user: User) -> UserDto {
        return UserDto(
            id: user.id,
            displayName: user.displayName,
            photoUrl: user.photoUrl,
            fcmToken: user.fcmToken,
            participatingQuestIds: user.participatingQuestIds,
            groupId: user.groupId,
            blockedUserIds: user.blockedUserIds
        )
    }
}
