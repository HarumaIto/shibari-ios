import Foundation
import FirebaseFirestore

struct GroupDto: Codable, Identifiable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var ownerId: String
    var memberIds: [String] = []
    var invitationCode: String
    
    func toDomain() -> Group {
        return Group(
            id: id ?? "",
            name: name,
            description: description,
            ownerId: ownerId,
            memberIds: memberIds,
            invitationCode: invitationCode
        )
    }

    static func fromDomain(_ domain: Group) -> GroupDto {
        return GroupDto(
            id: domain.id.isEmpty ? nil : domain.id,
            name: domain.name,
            description: domain.description,
            ownerId: domain.ownerId,
            memberIds: domain.memberIds,
            invitationCode: domain.invitationCode
        )
    }
}
