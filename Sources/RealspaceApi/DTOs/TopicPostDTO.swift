import Vapor

// MARK: - Request DTOs

struct CreateTopicPostDTO: Content {
    var content: String
}

struct UpdateTopicPostDTO: Content {
    var content: String
}

// MARK: - Response DTOs

struct TopicPostResponseDTO: Content {
    var id: UUID
    var content: String
    var likesCount: Int
    var createdAt: Date?
    var author: UserSummaryDTO
    var topic: TopicSummaryDTO
    var isLikedByCurrentUser: Bool?
    var commentsCount: Int?

    init(from topicPost: TopicPost, author: User, topic: Topic, isLikedByCurrentUser: Bool? = nil, commentsCount: Int? = nil) {
        self.id = topicPost.id!
        self.content = topicPost.content
        self.likesCount = topicPost.likesCount
        self.createdAt = topicPost.createdAt
        self.author = UserSummaryDTO(from: author)
        self.topic = TopicSummaryDTO(from: topic)
        self.isLikedByCurrentUser = isLikedByCurrentUser
        self.commentsCount = commentsCount
    }
}

// Simplified version for lists
struct TopicPostSummaryDTO: Content {
    var id: UUID
    var content: String
    var likesCount: Int
    var createdAt: Date?
    var author: UserSummaryDTO

    init(from topicPost: TopicPost, author: User) {
        self.id = topicPost.id!
        self.content = topicPost.content
        self.likesCount = topicPost.likesCount
        self.createdAt = topicPost.createdAt
        self.author = UserSummaryDTO(from: author)
    }
}
