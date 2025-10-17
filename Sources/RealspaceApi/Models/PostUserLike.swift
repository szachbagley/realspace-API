import Fluent
import Vapor

final class PostUserLike: Model {
    static let schema = "post_user_likes"

    @ID(key: .id)
    var id: UUID?

    @Parent(key: "post_id")
    var post: Post

    @Parent(key: "user_id")
    var user: User

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    init() { }

    init(id: UUID? = nil, postID: UUID, userID: UUID) {
        self.id = id
        self.$post.id = postID
        self.$user.id = userID
    }
}
