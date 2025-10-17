import Vapor
import Fluent

struct TopicPostController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let topics = routes.grouped("topics", ":topicID", "posts")
        topics.get(use: listTopicPosts)

        let topicposts = routes.grouped("topicposts")
        topicposts.get(":topicPostID", use: getTopicPost)

        // Protected routes
        let protectedTopics = topics.grouped(UserAuthenticator(), User.guardMiddleware())
        protectedTopics.post(use: createTopicPost)

        let protectedTopicPosts = topicposts.grouped(UserAuthenticator(), User.guardMiddleware())
        protectedTopicPosts.put(":topicPostID", use: updateTopicPost)
        protectedTopicPosts.delete(":topicPostID", use: deleteTopicPost)
        protectedTopicPosts.post(":topicPostID", "like", use: likeTopicPost)
        protectedTopicPosts.delete(":topicPostID", "like", use: unlikeTopicPost)
    }

    // GET /topics/:topicID/posts
    func listTopicPosts(req: Request) async throws -> [TopicPostResponseDTO] {
        guard let topicID = req.parameters.get("topicID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid topic ID")
        }

        guard let topic = try await Topic.find(topicID, on: req.db) else {
            throw Abort(.notFound, reason: "Topic not found")
        }

        let topicPosts = try await TopicPost.query(on: req.db)
            .filter(\.$topic.$id == topicID)
            .sort(\.$createdAt, .descending)
            .all()

        let currentUser = try? req.auth.require(User.self)

        var responseDTOs: [TopicPostResponseDTO] = []
        for topicPost in topicPosts {
            let author = try await topicPost.$author.get(on: req.db)

            var isLiked: Bool? = nil
            if let currentUser = currentUser {
                let likeExists = try await TopicPostUserLike.query(on: req.db)
                    .filter(\.$topicPost.$id == topicPost.id!)
                    .filter(\.$user.$id == currentUser.id!)
                    .first()
                isLiked = likeExists != nil
            }

            let commentsCount = try await Comment.query(on: req.db)
                .filter(\.$topicPost.$id == topicPost.id!)
                .count()

            responseDTOs.append(TopicPostResponseDTO(
                from: topicPost,
                author: author,
                topic: topic,
                isLikedByCurrentUser: isLiked,
                commentsCount: commentsCount
            ))
        }

        return responseDTOs
    }

    // GET /topicposts/:topicPostID
    func getTopicPost(req: Request) async throws -> TopicPostResponseDTO {
        guard let topicPostID = req.parameters.get("topicPostID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid topic post ID")
        }

        guard let topicPost = try await TopicPost.find(topicPostID, on: req.db) else {
            throw Abort(.notFound, reason: "Topic post not found")
        }

        let author = try await topicPost.$author.get(on: req.db)
        let topic = try await topicPost.$topic.get(on: req.db)

        let currentUser = try? req.auth.require(User.self)
        var isLiked: Bool? = nil
        if let currentUser = currentUser {
            let likeExists = try await TopicPostUserLike.query(on: req.db)
                .filter(\.$topicPost.$id == topicPostID)
                .filter(\.$user.$id == currentUser.id!)
                .first()
            isLiked = likeExists != nil
        }

        let commentsCount = try await Comment.query(on: req.db)
            .filter(\.$topicPost.$id == topicPostID)
            .count()

        return TopicPostResponseDTO(
            from: topicPost,
            author: author,
            topic: topic,
            isLikedByCurrentUser: isLiked,
            commentsCount: commentsCount
        )
    }

    // POST /topics/:topicID/posts
    func createTopicPost(req: Request) async throws -> TopicPostResponseDTO {
        let user = try req.auth.require(User.self)

        guard let topicID = req.parameters.get("topicID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid topic ID")
        }

        guard let topic = try await Topic.find(topicID, on: req.db) else {
            throw Abort(.notFound, reason: "Topic not found")
        }

        let createDTO = try req.content.decode(CreateTopicPostDTO.self)

        let topicPost = TopicPost(
            content: createDTO.content,
            authorID: user.id!,
            topicID: topicID
        )

        try await topicPost.save(on: req.db)

        return TopicPostResponseDTO(
            from: topicPost,
            author: user,
            topic: topic,
            isLikedByCurrentUser: false,
            commentsCount: 0
        )
    }

    // PUT /topicposts/:topicPostID
    func updateTopicPost(req: Request) async throws -> TopicPostResponseDTO {
        let user = try req.auth.require(User.self)

        guard let topicPostID = req.parameters.get("topicPostID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid topic post ID")
        }

        guard let topicPost = try await TopicPost.find(topicPostID, on: req.db) else {
            throw Abort(.notFound, reason: "Topic post not found")
        }

        guard topicPost.$author.id == user.id! else {
            throw Abort(.forbidden, reason: "You can only update your own posts")
        }

        let updateDTO = try req.content.decode(UpdateTopicPostDTO.self)
        topicPost.content = updateDTO.content

        try await topicPost.save(on: req.db)

        let topic = try await topicPost.$topic.get(on: req.db)

        let commentsCount = try await Comment.query(on: req.db)
            .filter(\.$topicPost.$id == topicPostID)
            .count()

        return TopicPostResponseDTO(
            from: topicPost,
            author: user,
            topic: topic,
            isLikedByCurrentUser: nil,
            commentsCount: commentsCount
        )
    }

    // DELETE /topicposts/:topicPostID
    func deleteTopicPost(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)

        guard let topicPostID = req.parameters.get("topicPostID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid topic post ID")
        }

        guard let topicPost = try await TopicPost.find(topicPostID, on: req.db) else {
            throw Abort(.notFound, reason: "Topic post not found")
        }

        guard topicPost.$author.id == user.id! else {
            throw Abort(.forbidden, reason: "You can only delete your own posts")
        }

        try await topicPost.delete(on: req.db)

        return .noContent
    }

    // POST /topicposts/:topicPostID/like
    func likeTopicPost(req: Request) async throws -> TopicPostResponseDTO {
        let user = try req.auth.require(User.self)

        guard let topicPostID = req.parameters.get("topicPostID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid topic post ID")
        }

        guard let topicPost = try await TopicPost.find(topicPostID, on: req.db) else {
            throw Abort(.notFound, reason: "Topic post not found")
        }

        let existingLike = try await TopicPostUserLike.query(on: req.db)
            .filter(\.$topicPost.$id == topicPostID)
            .filter(\.$user.$id == user.id!)
            .first()

        if existingLike == nil {
            let like = TopicPostUserLike(topicPostID: topicPostID, userID: user.id!)
            try await like.save(on: req.db)

            topicPost.likesCount += 1
            try await topicPost.save(on: req.db)
        }

        let author = try await topicPost.$author.get(on: req.db)
        let topic = try await topicPost.$topic.get(on: req.db)

        let commentsCount = try await Comment.query(on: req.db)
            .filter(\.$topicPost.$id == topicPostID)
            .count()

        return TopicPostResponseDTO(
            from: topicPost,
            author: author,
            topic: topic,
            isLikedByCurrentUser: true,
            commentsCount: commentsCount
        )
    }

    // DELETE /topicposts/:topicPostID/like
    func unlikeTopicPost(req: Request) async throws -> TopicPostResponseDTO {
        let user = try req.auth.require(User.self)

        guard let topicPostID = req.parameters.get("topicPostID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid topic post ID")
        }

        guard let topicPost = try await TopicPost.find(topicPostID, on: req.db) else {
            throw Abort(.notFound, reason: "Topic post not found")
        }

        if let like = try await TopicPostUserLike.query(on: req.db)
            .filter(\.$topicPost.$id == topicPostID)
            .filter(\.$user.$id == user.id!)
            .first() {

            try await like.delete(on: req.db)

            topicPost.likesCount = max(0, topicPost.likesCount - 1)
            try await topicPost.save(on: req.db)
        }

        let author = try await topicPost.$author.get(on: req.db)
        let topic = try await topicPost.$topic.get(on: req.db)

        let commentsCount = try await Comment.query(on: req.db)
            .filter(\.$topicPost.$id == topicPostID)
            .count()

        return TopicPostResponseDTO(
            from: topicPost,
            author: author,
            topic: topic,
            isLikedByCurrentUser: false,
            commentsCount: commentsCount
        )
    }
}
