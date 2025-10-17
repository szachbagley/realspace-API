import Vapor

// MARK: - Request DTOs

struct CreateEventDTO: Content {
    var name: String
    var date: Date
    var entityID: UUID
    var eventDescription: String?
    var link: String?
    var imageURL: String?
}

struct UpdateEventDTO: Content {
    var name: String?
    var date: Date?
    var eventDescription: String?
    var link: String?
    var imageURL: String?
}

// MARK: - Response DTOs

struct EventResponseDTO: Content {
    var id: UUID
    var name: String
    var date: Date
    var eventDescription: String?
    var link: String?
    var imageURL: String?
    var createdAt: Date?
    var entity: EntitySummaryDTO

    init(from event: Event, entity: Entity) {
        self.id = event.id!
        self.name = event.name
        self.date = event.date
        self.eventDescription = event.eventDescription
        self.link = event.link
        self.imageURL = event.imageURL
        self.createdAt = event.createdAt
        self.entity = EntitySummaryDTO(from: entity)
    }
}

// Simplified version for lists
struct EventSummaryDTO: Content {
    var id: UUID
    var name: String
    var date: Date
    var entity: EntitySummaryDTO

    init(from event: Event, entity: Entity) {
        self.id = event.id!
        self.name = event.name
        self.date = event.date
        self.entity = EntitySummaryDTO(from: entity)
    }
}
