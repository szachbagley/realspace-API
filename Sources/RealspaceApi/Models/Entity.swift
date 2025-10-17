import Fluent
import Vapor

final class Entity: Model, Content {
    static let schema = "entities"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "address")
    var address: String

    @OptionalField(key: "image_url")
    var imageURL: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    // Relationships
    @Children(for: \.$entity)
    var events: [Event]

    init() { }

    init(id: UUID? = nil, name: String, address: String, imageURL: String? = nil) {
        self.id = id
        self.name = name
        self.address = address
        self.imageURL = imageURL
    }
}
