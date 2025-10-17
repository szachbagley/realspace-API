import Vapor
import Fluent

struct EntityController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let entities = routes.grouped("entities")

        entities.get(use: listEntities)
        entities.get(":entityID", use: getEntity)

        // Protected routes
        let protected = entities.grouped(UserAuthenticator(), User.guardMiddleware())
        protected.post(use: createEntity)
        protected.put(":entityID", use: updateEntity)
    }

    // GET /entities
    func listEntities(req: Request) async throws -> [EntityResponseDTO] {
        let entities = try await Entity.query(on: req.db)
            .sort(\.$createdAt, .descending)
            .all()

        var responseDTOs: [EntityResponseDTO] = []
        for entity in entities {
            let eventsCount = try await Event.query(on: req.db)
                .filter(\.$entity.$id == entity.id!)
                .count()

            responseDTOs.append(EntityResponseDTO(from: entity, eventsCount: eventsCount))
        }

        return responseDTOs
    }

    // GET /entities/:entityID
    func getEntity(req: Request) async throws -> EntityResponseDTO {
        guard let entityID = req.parameters.get("entityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid entity ID")
        }

        guard let entity = try await Entity.find(entityID, on: req.db) else {
            throw Abort(.notFound, reason: "Entity not found")
        }

        let eventsCount = try await Event.query(on: req.db)
            .filter(\.$entity.$id == entityID)
            .count()

        return EntityResponseDTO(from: entity, eventsCount: eventsCount)
    }

    // POST /entities
    func createEntity(req: Request) async throws -> EntityResponseDTO {
        _ = try req.auth.require(User.self)
        let createDTO = try req.content.decode(CreateEntityDTO.self)

        let entity = Entity(
            name: createDTO.name,
            address: createDTO.address,
            imageURL: createDTO.imageURL
        )

        try await entity.save(on: req.db)

        return EntityResponseDTO(from: entity, eventsCount: 0)
    }

    // PUT /entities/:entityID
    func updateEntity(req: Request) async throws -> EntityResponseDTO {
        _ = try req.auth.require(User.self)

        guard let entityID = req.parameters.get("entityID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid entity ID")
        }

        guard let entity = try await Entity.find(entityID, on: req.db) else {
            throw Abort(.notFound, reason: "Entity not found")
        }

        let updateDTO = try req.content.decode(UpdateEntityDTO.self)

        if let name = updateDTO.name {
            entity.name = name
        }
        if let address = updateDTO.address {
            entity.address = address
        }
        if let imageURL = updateDTO.imageURL {
            entity.imageURL = imageURL
        }

        try await entity.save(on: req.db)

        let eventsCount = try await Event.query(on: req.db)
            .filter(\.$entity.$id == entityID)
            .count()

        return EntityResponseDTO(from: entity, eventsCount: eventsCount)
    }
}
