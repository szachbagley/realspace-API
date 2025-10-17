import Vapor
import Fluent

struct CommentController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let protected = routes.grouped(UserAuthenticator(), User.guardMiddleware())

        // POST /posts/:postID/comments
        protected.post("posts", ":postID", "comments", use: createPostComment)

        // POST /topicposts/:topicPostID/comments
        protected.post("topicposts", ":topicPostID", "comments", use: createTopicPostComment)

        // DELETE /comments/:commentID
        protected.delete("comments", ":commentID", use: deleteComment)

        // GET /posts/:postID/comments
        routes.get("posts", ":postID", "comments", use: getPostComments)

        // GET /topicposts/:topicPostID/comments
        routes.get("topicposts", ":topicPostID", "comments", use: getTopicPostComments)
    }

    // POST /posts/:postID/comments
    func createPostComment(req: Request) async throws -> CommentResponseDTO {
        let user = try req.auth.require(User.self)

        guard let postID = req.parameters.get("postID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid post ID")
        }

        guard let _ = try await Post.find(postID, on: req.db) else {
            throw Abort(.notFound, reason: "Post not found")
        }

        let createDTO = try req.content.decode(CreateCommentDTO.self)

        let comment = Comment(
            content: createDTO.content,
            authorID: user.id!,
            postID: postID
        )

        try await comment.save(on: req.db)

        return CommentResponseDTO(from: comment, author: user)
    }

    // POST /topicposts/:topicPostID/comments
    func createTopicPostComment(req: Request) async throws -> CommentResponseDTO {
        let user = try req.auth.require(User.self)

        guard let topicPostID = req.parameters.get("topicPostID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid topic post ID")
        }

        guard let _ = try await TopicPost.find(topicPostID, on: req.db) else {
            throw Abort(.notFound, reason: "Topic post not found")
        }

        let createDTO = try req.content.decode(CreateCommentDTO.self)

        let comment = Comment(
            content: createDTO.content,
            authorID: user.id!,
            topicPostID: topicPostID
        )

        try await comment.save(on: req.db)

        return CommentResponseDTO(from: comment, author: user)
    }

    // GET /posts/:postID/comments
    func getPostComments(req: Request) async throws -> [CommentResponseDTO] {
        guard let postID = req.parameters.get("postID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid post ID")
        }

        let comments = try await Comment.query(on: req.db)
            .filter(\.$post.$id == postID)
            .sort(\.$createdAt, .ascending)
            .all()

        var responseDTOs: [CommentResponseDTO] = []
        for comment in comments {
            let author = try await comment.$author.get(on: req.db)
            responseDTOs.append(CommentResponseDTO(from: comment, author: author))
        }

        return responseDTOs
    }

    // GET /topicposts/:topicPostID/comments
    func getTopicPostComments(req: Request) async throws -> [CommentResponseDTO] {
        guard let topicPostID = req.parameters.get("topicPostID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid topic post ID")
        }

        let comments = try await Comment.query(on: req.db)
            .filter(\.$topicPost.$id == topicPostID)
            .sort(\.$createdAt, .ascending)
            .all()

        var responseDTOs: [CommentResponseDTO] = []
        for comment in comments {
            let author = try await comment.$author.get(on: req.db)
            responseDTOs.append(CommentResponseDTO(from: comment, author: author))
        }

        return responseDTOs
    }

    // DELETE /comments/:commentID
    func deleteComment(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)

        guard let commentID = req.parameters.get("commentID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid comment ID")
        }

        guard let comment = try await Comment.find(commentID, on: req.db) else {
            throw Abort(.notFound, reason: "Comment not found")
        }

        guard comment.$author.id == user.id! else {
            throw Abort(.forbidden, reason: "You can only delete your own comments")
        }

        try await comment.delete(on: req.db)

        return .noContent
    }
}
