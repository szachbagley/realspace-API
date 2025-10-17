import Fluent
import Vapor

final class TopicPostUserLike: Model {
    static let schema = "topic_post_user_likes"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "topic_post_id")
    var topicPost: TopicPost

    @Parent(key: "user_id")
    var user: User

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(id: UUID? = nil, topicPostID: UUID, userID: UUID) {
        self.id = id
        self.$topicPost.id = topicPostID
        self.$user.id = userID
    }
}
