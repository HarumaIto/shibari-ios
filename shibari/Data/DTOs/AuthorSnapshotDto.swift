struct AuthorSnapshotDto: Codable {
    var displayName: String
    var photoUrl: String?
    
    func toDomain() -> AuthorSnapshot {
        AuthorSnapshot(displayName: displayName, photoUrl: photoUrl)
    }
        
    static func fromDomain(_ domain: AuthorSnapshot) -> AuthorSnapshotDto {
        AuthorSnapshotDto(
            displayName: domain.displayName,
            photoUrl: domain.photoUrl
        )
    }
}
