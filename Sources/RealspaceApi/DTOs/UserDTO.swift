import Vapor

// MARK: - Request DTOs

struct CreateUserDTO: Content {
    var username: String
    var displayName: String
    var email: String
    var password: String
    var bio: String?
}

struct LoginDTO: Content {
    var email: String
    var password: String
}

struct UpdateUserDTO: Content {
    var displayName: String?
    var bio: String?
    var profileImageURL: String?
}

// MARK: - Response DTOs

struct UserResponseDTO: Content {
    var id: UUID
    var username: String
    var displayName: String
    var bio: String
    var profileImageURL: String?
    var createdAt: Date?

    init(from user: User) {
        self.id = user.id!
        self.username = user.username
        self.displayName = user.displayName
        self.bio = user.bio
        self.profileImageURL = user.profileImageURL
        self.createdAt = user.createdAt
    }
}

struct AuthResponseDTO: Content {
    var token: String
    var user: UserResponseDTO
}

// Simplified version for nested responses
struct UserSummaryDTO: Content {
    var id: UUID
    var username: String
    var displayName: String
    var profileImageURL: String?

    init(from user: User) {
        self.id = user.id!
        self.username = user.username
        self.displayName = user.displayName
        self.profileImageURL = user.profileImageURL
    }
}
