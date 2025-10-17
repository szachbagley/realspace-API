import Fluent
import Vapor

final class Comment: Model, Content {
    static let schema = "comments"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "content")
    var content: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    // Relationships
    @Parent(key: "author_id")
    var author: User

    @OptionalParent(key: "post_id")
    var post: Post?

    @OptionalParent(key: "topic_post_id")
    var topicPost: TopicPost?

    init() { }

    init(id: UUID? = nil, content: String, authorID: UUID, postID: UUID? = nil, topicPostID: UUID? = nil) {
        self.id = id
        self.content = content
        self.$author.id = authorID
        if let postID = postID {
            self.$post.id = postID
        }
        if let topicPostID = topicPostID {
            self.$topicPost.id = topicPostID
        }
    }
}
