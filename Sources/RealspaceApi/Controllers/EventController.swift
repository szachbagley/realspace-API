import Vapor
import Fluent

struct EventController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let events = routes.grouped("events")

        events.get(use: listEvents)
        events.get(":eventID", use: getEvent)

        // Protected routes
        let protected = events.grouped(UserAuthenticator(), User.guardMiddleware())
        protected.post(use: createEvent)
        protected.put(":eventID", use: updateEvent)
    }

    // GET /events
    func listEvents(req: Request) async throws -> [EventResponseDTO] {
        let events = try await Event.query(on: req.db)
            .sort(\.$date, .descending)
            .all()

        var responseDTOs: [EventResponseDTO] = []
        for event in events {
            let entity = try await event.$entity.get(on: req.db)
            responseDTOs.append(EventResponseDTO(from: event, entity: entity))
        }

        return responseDTOs
    }

    // GET /events/:eventID
    func getEvent(req: Request) async throws -> EventResponseDTO {
        guard let eventID = req.parameters.get("eventID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid event ID")
        }

        guard let event = try await Event.find(eventID, on: req.db) else {
            throw Abort(.notFound, reason: "Event not found")
        }

        let entity = try await event.$entity.get(on: req.db)

        return EventResponseDTO(from: event, entity: entity)
    }

    // POST /events
    func createEvent(req: Request) async throws -> EventResponseDTO {
        _ = try req.auth.require(User.self)
        let createDTO = try req.content.decode(CreateEventDTO.self)

        guard let entity = try await Entity.find(createDTO.entityID, on: req.db) else {
            throw Abort(.notFound, reason: "Entity not found")
        }

        let event = Event(
            name: createDTO.name,
            date: createDTO.date,
            entityID: createDTO.entityID,
            eventDescription: createDTO.eventDescription,
            link: createDTO.link,
            imageURL: createDTO.imageURL
        )

        try await event.save(on: req.db)

        return EventResponseDTO(from: event, entity: entity)
    }

    // PUT /events/:eventID
    func updateEvent(req: Request) async throws -> EventResponseDTO {
        _ = try req.auth.require(User.self)

        guard let eventID = req.parameters.get("eventID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid event ID")
        }

        guard let event = try await Event.find(eventID, on: req.db) else {
            throw Abort(.notFound, reason: "Event not found")
        }

        let updateDTO = try req.content.decode(UpdateEventDTO.self)

        if let name = updateDTO.name {
            event.name = name
        }
        if let date = updateDTO.date {
            event.date = date
        }
        if let eventDescription = updateDTO.eventDescription {
            event.eventDescription = eventDescription
        }
        if let link = updateDTO.link {
            event.link = link
        }
        if let imageURL = updateDTO.imageURL {
            event.imageURL = imageURL
        }

        try await event.save(on: req.db)

        let entity = try await event.$entity.get(on: req.db)

        return EventResponseDTO(from: event, entity: entity)
    }
}
