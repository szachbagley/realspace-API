import Vapor

// MARK: - Request DTOs

struct CreateTopicDTO: Content {
    var name: String
    var topicDescription: String
}

// MARK: - Response DTOs

struct TopicResponseDTO: Content {
    var id: UUID
    var name: String
    var topicDescription: String
    var createdAt: Date?
    var postsCount: Int?

    init(from topic: Topic, postsCount: Int? = nil) {
        self.id = topic.id!
        self.name = topic.name
        self.topicDescription = topic.topicDescription
        self.createdAt = topic.createdAt
        self.postsCount = postsCount
    }
}

// Simplified version for lists
struct TopicSummaryDTO: Content {
    var id: UUID
    var name: String
    var topicDescription: String

    init(from topic: Topic) {
        self.id = topic.id!
        self.name = topic.name
        self.topicDescription = topic.topicDescription
    }
}
