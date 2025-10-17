import Vapor
import Fluent

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("users")

        users.get(":userID", use: getUser)

        // Protected routes
        let protected = users.grouped(UserAuthenticator(), User.guardMiddleware())
        protected.put(":userID", use: updateUser)
        protected.get(":userID", "posts", use: getUserPosts)
    }

    // GET /users/:userID
    func getUser(req: Request) async throws -> UserResponseDTO {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }

        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }

        return UserResponseDTO(from: user)
    }

    // PUT /users/:userID
    func updateUser(req: Request) async throws -> UserResponseDTO {
        let currentUser = try req.auth.require(User.self)

        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }

        // Users can only update their own profile
        guard currentUser.id == userID else {
            throw Abort(.forbidden, reason: "Cannot update another user's profile")
        }

        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }

        let updateDTO = try req.content.decode(UpdateUserDTO.self)

        if let displayName = updateDTO.displayName {
            user.displayName = displayName
        }
        if let bio = updateDTO.bio {
            user.bio = bio
        }
        if let profileImageURL = updateDTO.profileImageURL {
            user.profileImageURL = profileImageURL
        }

        try await user.save(on: req.db)

        return UserResponseDTO(from: user)
    }

    // GET /users/:userID/posts
    func getUserPosts(req: Request) async throws -> [PostResponseDTO] {
        guard let userID = req.parameters.get("userID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid user ID")
        }

        guard let user = try await User.find(userID, on: req.db) else {
            throw Abort(.notFound, reason: "User not found")
        }

        let posts = try await Post.query(on: req.db)
            .filter(\.$author.$id == userID)
            .sort(\.$createdAt, .descending)
            .all()

        let currentUser = try? req.auth.require(User.self)

        var responseDTOs: [PostResponseDTO] = []
        for post in posts {
            var isLiked: Bool? = nil
            if let currentUser = currentUser {
                let likeExists = try await PostUserLike.query(on: req.db)
                    .filter(\.$post.$id == post.id!)
                    .filter(\.$user.$id == currentUser.id!)
                    .first()
                isLiked = likeExists != nil
            }

            let commentsCount = try await Comment.query(on: req.db)
                .filter(\.$post.$id == post.id!)
                .count()

            responseDTOs.append(PostResponseDTO(
                from: post,
                author: user,
                isLikedByCurrentUser: isLiked,
                commentsCount: commentsCount
            ))
        }

        return responseDTOs
    }
}
