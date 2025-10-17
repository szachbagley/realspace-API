import Fluent
import Vapor

final class TopicPost: Model, Content {
    static let schema = "topic_posts"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "content")
    var content: String

    @Field(key: "likes_count")
    var likesCount: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    // Relationships
    @Parent(key: "author_id")
    var author: User

    @Parent(key: "topic_id")
    var topic: Topic

    @Children(for: \.$topicPost)
    var comments: [Comment]

    @Siblings(through: TopicPostUserLike.self, from: \.$topicPost, to: \.$user)
    var likedBy: [User]

    init() { }

    init(id: UUID? = nil, content: String, authorID: UUID, topicID: UUID) {
        self.id = id
        self.content = content
        self.likesCount = 0
        self.$author.id = authorID
        self.$topic.id = topicID
    }
}
