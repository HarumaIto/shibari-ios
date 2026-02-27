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
        
        var quests: [Quest] = []
        
        let ids = user.participatingQuestIds
        for i in stride(from: 0, to: ids.count, by: 10) {
            let chunk = Array(ids[i..<min(i + 10, ids.count)])
            
            let snapshot = try await db.collection("quests")
                .whereField("groupId", isEqualTo: groupId)
                .whereField(FieldPath.documentID(), in: chunk)
                .getDocuments()
            
            let dtos = snapshot.documents.compactMap{ try? $0.data(as: QuestDto.self) }
            quests.append(contentsOf: dtos.map { $0.toDomain() })
        }
        
        let calendar = Calendar.current
        let now = Date()
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: .now)) else { return [] }
        
        
        // Determine the minimal required start date based on quest frequencies
        let frequencies = Set(quests.map { $0.frequency })
        var candidateStartDates: [Date] = []
                
        // Daily quests only need posts from the start of today
        let startOfDay = calendar.startOfDay(for: now)
        if frequencies.contains(.DAILY) {
            candidateStartDates.append(startOfDay)
        }
                
        // Weekly quests need posts from the start of the current week (may cross month boundary)
        if frequencies.contains(.WEEKLY),
            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: now) {
            candidateStartDates.append(weekInterval.start)
        }
                
        // Monthly quests need posts from the start of the current month
        if frequencies.contains(.MONTHLY),
            let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: now)) {
            candidateStartDates.append(startOfMonth)
        }
                
        // Use the earliest required start date; fall back to start of today if none found
        let queryStartDate = candidateStartDates.min() ?? startOfDay
        
        let postsSnapshot = try await db.collection("timelines")
            .whereField("userId", isEqualTo: user.id)
            .whereField("createdAt", isGreaterThanOrEqualTo:  queryStartDate)
            .getDocuments()
        
        let recentPosts = postsSnapshot.documents.compactMap { try? $0.data(as: TimelinePostDto.self) }
        let postsByQuestId = Dictionary(grouping: recentPosts, by: { $0.questId })
        
        return quests.map { quest in
            var updatedQuest = quest
            let postsForThisQuest = postsByQuestId[quest.id] ?? []
            
            if postsForThisQuest.isEmpty {
                updatedQuest.isCompleted = false
                return quest
            }
            
            updatedQuest.isCompleted = postsForThisQuest.contains { post in
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
            return updatedQuest
        }
    }
    
    func createQuest(quest: Quest) async throws {
        let docRef = db.collection("quests").document()
        var newQuest = QuestDto.fromDomain(quest)
        newQuest.id = docRef.documentID
        try docRef.setData(from: newQuest)
    }
}
