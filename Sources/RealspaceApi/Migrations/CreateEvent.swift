import Fluent

struct CreateEvent: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("events")
            .id()
            .field("name", .string, .required)
            .field("date", .datetime, .required)
            .field("event_description", .string)
            .field("link", .string)
            .field("image_url", .string)
            .field("entity_id", .uuid, .required, .references("entities", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("events").delete()
    }
}
