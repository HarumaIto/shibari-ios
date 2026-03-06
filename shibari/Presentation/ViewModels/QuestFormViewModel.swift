import Foundation
import Observation

@MainActor
@Observable
class QuestFormViewModel {
    private let questRepository: QuestRepository
    private let groupId: String
    private let initialQuest: Quest?

    var title: String = ""
    var description: String = ""
    var type: QuestType = .PROHIBITION
    var frequency: QuestFrequency = .DAILY
    var thresholdText: String = ""

    var isLoading: Bool = false
    var errorMessage: String? = nil
    var isSaved: Bool = false

    var isNewQuest: Bool { initialQuest == nil }

    var hasChanges: Bool {
        guard let initial = initialQuest else {
            return !title.isEmpty || !description.isEmpty
        }
        return title != initial.title
            || description != initial.description
            || type != initial.type
            || frequency != initial.frequency
            || thresholdText != (initial.threshold.map { String($0) } ?? "")
    }

    var canSave: Bool {
        !title.isEmpty && !description.isEmpty && hasChanges && !isLoading
    }

    init(questRepository: QuestRepository, groupId: String, initialQuest: Quest?) {
        self.questRepository = questRepository
        self.groupId = groupId
        self.initialQuest = initialQuest

        if let quest = initialQuest {
            self.title = quest.title
            self.description = quest.description
            self.type = quest.type
            self.frequency = quest.frequency
            self.thresholdText = quest.threshold.map { String($0) } ?? ""
        }
    }

    func save() async {
        isLoading = true
        defer { isLoading = false }

        let threshold = Int(thresholdText)

        do {
            if let existing = initialQuest {
                let updated = Quest(
                    id: existing.id,
                    groupId: groupId,
                    title: title,
                    type: type,
                    frequency: frequency,
                    description: description,
                    threshold: threshold
                )
                try await questRepository.updateQuest(quest: updated)
            } else {
                let newQuest = Quest(
                    id: "",
                    groupId: groupId,
                    title: title,
                    type: type,
                    frequency: frequency,
                    description: description,
                    threshold: threshold
                )
                try await questRepository.createQuest(quest: newQuest)
            }
            isSaved = true
        } catch {
            errorMessage = "保存に失敗しました"
        }
    }
}
