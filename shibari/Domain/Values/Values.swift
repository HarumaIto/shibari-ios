enum MediaType: String, Codable {
    case image
    case video
}

enum PostStatus: String, Codable {
    case pending
    case approved
    case rejected
}

enum VoteType: String, Codable {
    case APPROVE
    case REJECT
}

enum QuestType: String, Codable {
    case PROHIBITION
    case ROUTINE
    case ACHIEVEMENT
    case CHALLENGE
}
