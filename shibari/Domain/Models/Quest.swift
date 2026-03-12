import Foundation

struct Quest: Identifiable, Equatable {
    var id: String = ""
    let groupId: String
    let title: String
    let type: QuestType
    let frequency: QuestFrequency
    let description: String
    let threshold: Int?
    var isCompleted: Bool = false
}
