import Vapor

// MARK: - Request DTOs

struct CreatePostDTO: Content {
    var action: String
    var subject: String
    var content: String?
    var imageURL: String?
}

struct UpdatePostDTO: Content {
    var content: String?
    var imageURL: String?
}

// MARK: - Response DTOs

struct PostResponseDTO: Content {
    var id: UUID
    var action: String
    var subject: String
    var content: String?
    var imageURL: String?
    var likesCount: Int
    var createdAt: Date?
    var author: UserSummaryDTO
    var isLikedByCurrentUser: Bool?
    var commentsCount: Int?

    init(from post: Post, author: User, isLikedByCurrentUser: Bool? = nil, commentsCount: Int? = nil) {
        self.id = post.id!
        self.action = post.action
        self.subject = post.subject
        self.content = post.content
        self.imageURL = post.imageURL
        self.likesCount = post.likesCount
        self.createdAt = post.createdAt
        self.author = UserSummaryDTO(from: author)
        self.isLikedByCurrentUser = isLikedByCurrentUser
        self.commentsCount = commentsCount
    }
}

// Simplified version for lists
struct PostSummaryDTO: Content {
    var id: UUID
    var action: String
    var subject: String
    var likesCount: Int
    var createdAt: Date?
    var author: UserSummaryDTO

    init(from post: Post, author: User) {
        self.id = post.id!
        self.action = post.action
        self.subject = post.subject
        self.likesCount = post.likesCount
        self.createdAt = post.createdAt
        self.author = UserSummaryDTO(from: author)
    }
}
