import Vapor

// MARK: - Request DTOs

struct CreateListItemDTO: Content {
    var action: String
    var subject: String
}

// MARK: - Response DTOs

struct ListItemResponseDTO: Content {
    var id: UUID
    var action: String
    var subject: String
    var createdAt: Date?

    init(from listItem: ListItem) {
        self.id = listItem.id!
        self.action = listItem.action
        self.subject = listItem.subject
        self.createdAt = listItem.createdAt
    }
}
