import Fluent

struct CreatePostUserLike: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("post_user_likes")
            .id()
            .field("post_id", .uuid, .required, .references("posts", "id", onDelete: .cascade))
            .field("user_id", .uuid, .required, .references("users", "id", onDelete: .cascade))
            .field("created_at", .datetime)
            .unique(on: "post_id", "user_id")
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("post_user_likes").delete()
    }
}
