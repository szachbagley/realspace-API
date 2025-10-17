import Fluent
import Vapor

final class User: Model, Content, Authenticatable {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "username")
    var username: String

    @Field(key: "display_name")
    var displayName: String

    @Field(key: "bio")
    var bio: String

    @OptionalField(key: "profile_image_url")
    var profileImageURL: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    // Authentication fields
    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String

    // Relationships
    @Children(for: \.$author)
    var posts: [Post]

    @Children(for: \.$user)
    var listItems: [ListItem]

    @Siblings(through: PostUserLike.self, from: \.$user, to: \.$post)
    var likedPosts: [Post]

    @Siblings(through: TopicPostUserLike.self, from: \.$user, to: \.$topicPost)
    var likedTopicPosts: [TopicPost]

    init() { }

    init(id: UUID? = nil, username: String, displayName: String, email: String, passwordHash: String, bio: String = "", profileImageURL: String? = nil) {
        self.id = id
        self.username = username
        self.displayName = displayName
        self.email = email
        self.passwordHash = passwordHash
        self.bio = bio
        self.profileImageURL = profileImageURL
    }
}
