import Vapor
import Fluent

struct TopicController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let topics = routes.grouped("topics")

        topics.get(use: listTopics)
        topics.get(":topicID", use: getTopic)

        // Protected routes
        let protected = topics.grouped(UserAuthenticator(), User.guardMiddleware())
        protected.post(use: createTopic)
    }

    // GET /topics
    func listTopics(req: Request) async throws -> [TopicResponseDTO] {
        let topics = try await Topic.query(on: req.db)
            .sort(\.$createdAt, .descending)
            .all()

        var responseDTOs: [TopicResponseDTO] = []
        for topic in topics {
            let postsCount = try await TopicPost.query(on: req.db)
                .filter(\.$topic.$id == topic.id!)
                .count()

            responseDTOs.append(TopicResponseDTO(from: topic, postsCount: postsCount))
        }

        return responseDTOs
    }

    // GET /topics/:topicID
    func getTopic(req: Request) async throws -> TopicResponseDTO {
        guard let topicID = req.parameters.get("topicID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid topic ID")
        }

        guard let topic = try await Topic.find(topicID, on: req.db) else {
            throw Abort(.notFound, reason: "Topic not found")
        }

        let postsCount = try await TopicPost.query(on: req.db)
            .filter(\.$topic.$id == topicID)
            .count()

        return TopicResponseDTO(from: topic, postsCount: postsCount)
    }

    // POST /topics
    func createTopic(req: Request) async throws -> TopicResponseDTO {
        _ = try req.auth.require(User.self)
        let createDTO = try req.content.decode(CreateTopicDTO.self)

        let topic = Topic(name: createDTO.name, topicDescription: createDTO.topicDescription)

        try await topic.save(on: req.db)

        return TopicResponseDTO(from: topic, postsCount: 0)
    }
}
