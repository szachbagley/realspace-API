import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req async throws in
        try await req.view.render("index", ["title": "Hello Vapor!"])
    }

    app.get("hello") { req async -> String in
        "Hello, world!"
    }

    // Register API controllers
    let api = app.grouped("api")

    // Authentication routes
    try api.register(collection: AuthController())

    // User routes
    try api.register(collection: UserController())

    // Post routes
    try api.register(collection: PostController())

    // Topic routes
    try api.register(collection: TopicController())
    try api.register(collection: TopicPostController())

    // Comment routes
    try api.register(collection: CommentController())

    // Entity & Event routes
    try api.register(collection: EntityController())
    try api.register(collection: EventController())

    // List item routes
    try api.register(collection: ListItemController())
}
