import Fluent
import Vapor

final class Topic: Model, Content {
    static let schema = "topics"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "topic_description")
    var topicDescription: String

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    // Relationships
    @Children(for: \.$topic)
    var posts: [TopicPost]

    init() { }

    init(id: UUID? = nil, name: String, topicDescription: String) {
        self.id = id
        self.name = name
        self.topicDescription = topicDescription
    }
}
