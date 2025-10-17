import Fluent

struct CreateTopic: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("topics")
            .id()
            .field("name", .string, .required)
            .field("topic_description", .string, .required)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("topics").delete()
    }
}
