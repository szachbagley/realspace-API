import Fluent

struct CreateTopicPostUserLike: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("topic_post_user_likes")
            .id()
            .field("topic_post_id", .uuid, .required, .references("topic_posts", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .unique(on: "topic_post_id", "user_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("topic_post_user_likes").delete()
    }
}
