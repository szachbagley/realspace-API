import Fluent

struct CreatePost: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("posts")
            .id()
            .field("action", .string, .required)
            .field("subject", .string, .required)
            .field("content", .string)
            .field("image_url", .string)
            .field("likes_count", .int, .required)
            .field("author_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("posts").delete()
    }
}
