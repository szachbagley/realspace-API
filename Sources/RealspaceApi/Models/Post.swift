import Fluent
import Vapor

final class Post: Model, Content {
    static let schema = "posts"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "action")
    var action: String

    @Field(key: "subject")
    var subject: String

    @OptionalField(key: "content")
    var content: String?

    @OptionalField(key: "image_url")
    var imageURL: String?

    @Field(key: "likes_count")
    var likesCount: Int

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    // Relationships
    @Parent(key: "author_id")
    var author: User

    @Children(for: \.$post)
    var comments: [Comment]

    @Siblings(through: PostUserLike.self, from: \.$post, to: \.$user)
    var likedBy: [User]

    init() { }

    init(id: UUID? = nil, action: String, subject: String, content: String? = nil, imageURL: String? = nil, authorID: UUID) {
        self.id = id
        self.action = action
        self.subject = subject
        self.content = content
        self.imageURL = imageURL
        self.likesCount = 0
        self.$author.id = authorID
    }
}
