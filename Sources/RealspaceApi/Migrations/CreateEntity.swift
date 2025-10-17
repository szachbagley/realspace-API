import Fluent

struct CreateEntity: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("entities")
            .id()
            .field("name", .string, .required)
            .field("address", .string, .required)
            .field("image_url", .string)
            .field("created_at", .datetime)
            .create()
    }

    func revert(on database: Database) async throws {
        try await database.schema("entities").delete()
    }
}
