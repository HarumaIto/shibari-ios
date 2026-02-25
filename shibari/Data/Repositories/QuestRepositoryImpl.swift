import Foundation
import FirebaseFirestore

class QuestRepositoryImpl: QuestRepository {
    private let db = Firestore.firestore()
    
    func getQuests(groupId: String) async throws -> [Quest] {
        let snapshot = try await db.collection("quests")
            .whereField("groupId", isEqualTo: groupId)
            .getDocuments()
        
        let dtos = snapshot.documents.compactMap { try? $0.data(as: QuestDto.self) }
        return dtos.map { $0.toDomain() }
    }
    
    func createQuest(quest: Quest) async throws {
        let docRef = db.collection("quests").document()
        var newQuest = QuestDto.fromDomain(quest)
        newQuest.id = docRef.documentID
        try docRef.setData(from: newQuest)
    }
}
