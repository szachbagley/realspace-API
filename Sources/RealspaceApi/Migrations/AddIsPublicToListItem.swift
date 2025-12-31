import Fluent

struct AddIsPublicToListItem: AsyncMigration {
    func prepare(on database: Database) async throws {
        try await database.schema("list_items")
            .field("is_public", .bool, .required, .sql(.default(false)))
            .update()
    }

    func revert(on database: Database) async throws {
        try await database.schema("list_items")
            .deleteField("is_public")
            .update()
    }
}
