import Fluent

struct CreateTopicPost: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("topic_posts")
            .id()
            .field("content", .string, .required)
            .field("likes_count", .int, .required)
            .field("author_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("topic_id", .uuid, .required, .references("topics", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("topic_posts").delete()
    }
}
