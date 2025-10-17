import NIOSSL
import Fluent
import FluentMySQLDriver
import Leaf
import Vapor
import JWT

// configures your application
public func configure(_ app: Application) async throws {
    // uncomment to serve files from /Public folder
    // app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

    // Configure JWT
    let jwtSigningKey = Environment.get("JWT_SECRET") ?? "your-secret-key-change-this-in-production"
    await app.jwt.signers.use(.hs256(key: jwtSigningKey))

    var tls: TLSConfiguration = .makeClientConfiguration()
    tls.certificateVerification = .none

    app.databases.use(DatabaseConfigurationFactory.mysql(
        hostname: Environment.get("DATABASE_HOST") ?? "localhost",
        port: Environment.get("DATABASE_PORT").flatMap(Int.init(_:)) ?? MySQLConfiguration.ianaPortNumber,
        username: Environment.get("DATABASE_USERNAME") ?? "vapor_username",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor_password",
        database: Environment.get("DATABASE_NAME") ?? "vapor_database",
        tlsConfiguration: tls
    ), as: .mysql)

    // Register migrations in order of dependencies
    // 1. Independent tables (no foreign keys)
    app.migrations.add(CreateUser())
    app.migrations.add(CreateTopic())
    app.migrations.add(CreateEntity())

    // 2. Tables with foreign keys to independent tables
    app.migrations.add(CreatePost())
    app.migrations.add(CreateTopicPost())
    app.migrations.add(CreateEvent())
    app.migrations.add(CreateListItem())

    // 3. Tables with foreign keys to posts/topic_posts
    app.migrations.add(CreateComment())

    // 4. Pivot tables (many-to-many relationships)
    app.migrations.add(CreatePostUserLike())
    app.migrations.add(CreateTopicPostUserLike())

    app.views.use(.leaf)

    // register routes
    try routes(app)
}
