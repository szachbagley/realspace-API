import Fluent
import Vapor

final class ListItem: Model, Content {
    static let schema = "list_items"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "action")
    var action: String

    @Field(key: "subject")
    var subject: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    // Relationships
    @Parent(key: "user_id")
    var user: User

    init() { }

    init(id: UUID? = nil, action: String, subject: String, userID: UUID) {
        self.id = id
        self.action = action
        self.subject = subject
        self.$user.id = userID
    }
}
