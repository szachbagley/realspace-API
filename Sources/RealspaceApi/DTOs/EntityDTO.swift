import Vapor

// MARK: - Request DTOs

struct CreateEntityDTO: Content {
    var name: String
    var address: String
    var imageURL: String?
}

struct UpdateEntityDTO: Content {
    var name: String?
    var address: String?
    var imageURL: String?
}

// MARK: - Response DTOs

struct EntityResponseDTO: Content {
    var id: UUID
    var name: String
    var address: String
    var imageURL: String?
    var createdAt: Date?
    var eventsCount: Int?

    init(from entity: Entity, eventsCount: Int? = nil) {
        self.id = entity.id!
        self.name = entity.name
        self.address = entity.address
        self.imageURL = entity.imageURL
        self.createdAt = entity.createdAt
        self.eventsCount = eventsCount
    }
}

// Simplified version for nested responses
struct EntitySummaryDTO: Content {
    var id: UUID
    var name: String
    var address: String
    var imageURL: String?

    init(from entity: Entity) {
        self.id = entity.id!
        self.name = entity.name
        self.address = entity.address
        self.imageURL = entity.imageURL
    }
}
