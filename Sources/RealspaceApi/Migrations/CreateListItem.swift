import Fluent

struct CreateListItem: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("list_items")
            .id()
            .field("action", .string, .required)
            .field("subject", .string, .required)
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("list_items").delete()
    }
}
