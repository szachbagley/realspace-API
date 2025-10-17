import Fluent
import Vapor

final class Event: Model, Content {
    static let schema = "events"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "date")
    var date: Date

    @OptionalField(key: "event_description")
    var eventDescription: String?

    @OptionalField(key: "link")
    var link: String?

    @OptionalField(key: "image_url")
    var imageURL: String?

    @Timestamp(key: "created_at", on: .create)
    var createdAt: Date?

    // Relationships
    @Parent(key: "entity_id")
    var entity: Entity

    init() { }

    init(id: UUID? = nil, name: String, date: Date, entityID: UUID, eventDescription: String? = nil, link: String? = nil, imageURL: String? = nil) {
        self.id = id
        self.name = name
        self.date = date
        self.eventDescription = eventDescription
        self.link = link
        self.imageURL = imageURL
        self.$entity.id = entityID
    }
}
