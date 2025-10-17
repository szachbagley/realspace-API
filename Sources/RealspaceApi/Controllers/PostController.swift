import Vapor
import Fluent

struct PostController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let posts = routes.grouped("posts")

        posts.get(use: listPosts)
        posts.get(":postID", use: getPost)

        // Protected routes
        let protected = posts.grouped(UserAuthenticator(), User.guardMiddleware())
        protected.post(use: createPost)
        protected.put(":postID", use: updatePost)
        protected.delete(":postID", use: deletePost)
        protected.post(":postID", "like", use: likePost)
        protected.delete(":postID", "like", use: unlikePost)
    }

    // GET /posts
    func listPosts(req: Request) async throws -> [PostResponseDTO] {
        let posts = try await Post.query(on: req.db)
            .sort(\.$createdAt, .descending)
            .all()

        let currentUser = try? req.auth.require(User.self)

        var responseDTOs: [PostResponseDTO] = []
        for post in posts {
            let author = try await post.$author.get(on: req.db)

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
                author: author,
                isLikedByCurrentUser: isLiked,
                commentsCount: commentsCount
            ))
        }

        return responseDTOs
    }

    // GET /posts/:postID
    func getPost(req: Request) async throws -> PostResponseDTO {
        guard let postID = req.parameters.get("postID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid post ID")
        }

        guard let post = try await Post.find(postID, on: req.db) else {
            throw Abort(.notFound, reason: "Post not found")
        }

        let author = try await post.$author.get(on: req.db)

        let currentUser = try? req.auth.require(User.self)
        var isLiked: Bool? = nil
        if let currentUser = currentUser {
            let likeExists = try await PostUserLike.query(on: req.db)
                .filter(\.$post.$id == postID)
                .filter(\.$user.$id == currentUser.id!)
                .first()
            isLiked = likeExists != nil
        }

        let commentsCount = try await Comment.query(on: req.db)
            .filter(\.$post.$id == postID)
            .count()

        return PostResponseDTO(
            from: post,
            author: author,
            isLikedByCurrentUser: isLiked,
            commentsCount: commentsCount
        )
    }

    // POST /posts
    func createPost(req: Request) async throws -> PostResponseDTO {
        let user = try req.auth.require(User.self)
        let createDTO = try req.content.decode(CreatePostDTO.self)

        let post = Post(
            action: createDTO.action,
            subject: createDTO.subject,
            content: createDTO.content,
            imageURL: createDTO.imageURL,
            authorID: user.id!
        )

        try await post.save(on: req.db)

        return PostResponseDTO(
            from: post,
            author: user,
            isLikedByCurrentUser: false,
            commentsCount: 0
        )
    }

    // PUT /posts/:postID
    func updatePost(req: Request) async throws -> PostResponseDTO {
        let user = try req.auth.require(User.self)

        guard let postID = req.parameters.get("postID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid post ID")
        }

        guard let post = try await Post.find(postID, on: req.db) else {
            throw Abort(.notFound, reason: "Post not found")
        }

        // Only author can update
        guard post.$author.id == user.id! else {
            throw Abort(.forbidden, reason: "You can only update your own posts")
        }

        let updateDTO = try req.content.decode(UpdatePostDTO.self)

        if let content = updateDTO.content {
            post.content = content
        }
        if let imageURL = updateDTO.imageURL {
            post.imageURL = imageURL
        }

        try await post.save(on: req.db)

        let commentsCount = try await Comment.query(on: req.db)
            .filter(\.$post.$id == postID)
            .count()

        return PostResponseDTO(
            from: post,
            author: user,
            isLikedByCurrentUser: nil,
            commentsCount: commentsCount
        )
    }

    // DELETE /posts/:postID
    func deletePost(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)

        guard let postID = req.parameters.get("postID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid post ID")
        }

        guard let post = try await Post.find(postID, on: req.db) else {
            throw Abort(.notFound, reason: "Post not found")
        }

        // Only author can delete
        guard post.$author.id == user.id! else {
            throw Abort(.forbidden, reason: "You can only delete your own posts")
        }

        try await post.delete(on: req.db)

        return .noContent
    }

    // POST /posts/:postID/like
    func likePost(req: Request) async throws -> PostResponseDTO {
        let user = try req.auth.require(User.self)

        guard let postID = req.parameters.get("postID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid post ID")
        }

        guard let post = try await Post.find(postID, on: req.db) else {
            throw Abort(.notFound, reason: "Post not found")
        }

        // Check if already liked
        let existingLike = try await PostUserLike.query(on: req.db)
            .filter(\.$post.$id == postID)
            .filter(\.$user.$id == user.id!)
            .first()

        if existingLike == nil {
            let like = PostUserLike(postID: postID, userID: user.id!)
            try await like.save(on: req.db)

            post.likesCount += 1
            try await post.save(on: req.db)
        }

        let author = try await post.$author.get(on: req.db)

        let commentsCount = try await Comment.query(on: req.db)
            .filter(\.$post.$id == postID)
            .count()

        return PostResponseDTO(
            from: post,
            author: author,
            isLikedByCurrentUser: true,
            commentsCount: commentsCount
        )
    }

    // DELETE /posts/:postID/like
    func unlikePost(req: Request) async throws -> PostResponseDTO {
        let user = try req.auth.require(User.self)

        guard let postID = req.parameters.get("postID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid post ID")
        }

        guard let post = try await Post.find(postID, on: req.db) else {
            throw Abort(.notFound, reason: "Post not found")
        }

        // Find and delete the like
        if let like = try await PostUserLike.query(on: req.db)
            .filter(\.$post.$id == postID)
            .filter(\.$user.$id == user.id!)
            .first() {

            try await like.delete(on: req.db)

            post.likesCount = max(0, post.likesCount - 1)
            try await post.save(on: req.db)
        }

        let author = try await post.$author.get(on: req.db)

        let commentsCount = try await Comment.query(on: req.db)
            .filter(\.$post.$id == postID)
            .count()

        return PostResponseDTO(
            from: post,
            author: author,
            isLikedByCurrentUser: false,
            commentsCount: commentsCount
        )
    }
}
