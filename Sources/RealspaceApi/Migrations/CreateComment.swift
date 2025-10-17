import Fluent

struct CreateComment: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("comments")
            .id()
            .field("content", .string, .required)
            .field("author_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("post_id", .uuid, .references("posts", "id", onDelete: .cascade))
            .field("topic_post_id", .uuid, .references("topic_posts", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("comments").delete()
    }
}
