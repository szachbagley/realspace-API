import Vapor

// MARK: - Request DTOs

struct CreateCommentDTO: Content {
    var content: String
    var postID: UUID?
    var topicPostID: UUID?
}

// MARK: - Response DTOs

struct CommentResponseDTO: Content {
    var id: UUID
    var content: String
    var createdAt: Date?
    var author: UserSummaryDTO

    init(from comment: Comment, author: User) {
        self.id = comment.id!
        self.content = comment.content
        self.createdAt = comment.createdAt
        self.author = UserSummaryDTO(from: author)
    }
}
