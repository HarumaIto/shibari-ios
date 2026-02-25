import Foundation

struct Group: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let ownerId: String
    let memberIds: [String]
    let invitationCode: String
}
