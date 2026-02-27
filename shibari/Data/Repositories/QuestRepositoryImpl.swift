import Foundation
import FirebaseFirestore

class QuestRepositoryImpl: QuestRepository {
    private let db = Firestore.firestore()
    
    func getGroupQuests(groupId: String) async throws -> [Quest] {
        let snapshot = try await db.collection("quests")
            .whereField("groupId", isEqualTo: groupId)
            .getDocuments()
        
        let dtos = snapshot.documents.compactMap { try? $0.data(as: QuestDto.self) }
        return dtos.map { $0.toDomain() }
    }
    
    func getMyQuests(groupId: String, user: User) async throws -> [Quest] {
        guard !user.participatingQuestIds.isEmpty else { return [] }
        
        var questDtos: [QuestDto] = []
        
        let ids = user.participatingQuestIds
        for i in stride(from: 0, to: ids.count, by: 10) {
            let chunk = Array(ids[i..<min(i + 10, ids.count)])
            
            let snapshot = try await db.collection("quests")
                .whereField("groupId", isEqualTo: groupId)
                .whereField("id", in: chunk)
                .getDocuments()
            
            let dtos = snapshot.documents.compactMap{ try? $0.data(as: QuestDto.self) }
            questDtos.append(contentsOf: dtos)
        }
        
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: .now)) else { return [] }
        
        let postsSnapshot = try await db.collection("timelines")
            .whereField("userId", isEqualTo: user.id)
            .whereField("createdAt", isGreaterThanOrEqualTo:  startOfMonth)
            .getDocuments()
        
        let recentPosts = postsSnapshot.documents.compactMap { try? $0.data(as: TimelinePostDto.self) }
        
        let quests: [Quest] = questDtos.map { dto in
            var quest = dto.toDomain()
            
            let postsForThisQuest = recentPosts.filter { $0.questId == quest.id }
            
            if postsForThisQuest.isEmpty {
                quest.isCompleted = false
                return quest
            }
            
            quest.isCompleted = postsForThisQuest.contains { post in
                guard let postDate = post.createdAt?.dateValue() else { return false }
                
                switch quest.frequency {
                case .DAILY:
                    return calendar.isDate(postDate, inSameDayAs: now)
                case .WEEKLY:
                    return calendar.isDate(postDate, equalTo: now, toGranularity: .weekOfYear)
                case .MONTHLY:
                    return calendar.isDate(postDate, equalTo: now, toGranularity: .month)
                default:
                    return false
                }
            }
            return quest
        }
        return quests
    }
    
    func createQuest(quest: Quest) async throws {
        let docRef = db.collection("quests").document()
        var newQuest = QuestDto.fromDomain(quest)
        newQuest.id = docRef.documentID
        try docRef.setData(from: newQuest)
    }
}
