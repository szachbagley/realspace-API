import Vapor
import Fluent

struct ListItemController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let list = routes.grouped("list").grouped(UserAuthenticator(), User.guardMiddleware())

        list.get(use: getList)
        list.post(use: addListItem)
        list.delete(":listItemID", use: removeListItem)
    }

    // GET /list
    func getList(req: Request) async throws -> [ListItemResponseDTO] {
        let user = try req.auth.require(User.self)

        let listItems = try await ListItem.query(on: req.db)
            .filter(\.$user.$id == user.id!)
            .sort(\.$createdAt, .descending)
            .all()

        return listItems.map { ListItemResponseDTO(from: $0) }
    }

    // POST /list
    func addListItem(req: Request) async throws -> ListItemResponseDTO {
        let user = try req.auth.require(User.self)
        let createDTO = try req.content.decode(CreateListItemDTO.self)

        let listItem = ListItem(
            action: createDTO.action,
            subject: createDTO.subject,
            isPublic: createDTO.isPublic ?? false,
            userID: user.id!
        )

        try await listItem.save(on: req.db)

        return ListItemResponseDTO(from: listItem)
    }

    // DELETE /list/:listItemID
    func removeListItem(req: Request) async throws -> HTTPStatus {
        let user = try req.auth.require(User.self)

        guard let listItemID = req.parameters.get("listItemID", as: UUID.self) else {
            throw Abort(.badRequest, reason: "Invalid list item ID")
        }

        guard let listItem = try await ListItem.find(listItemID, on: req.db) else {
            throw Abort(.notFound, reason: "List item not found")
        }

        guard listItem.$user.id == user.id! else {
            throw Abort(.forbidden, reason: "You can only delete your own list items")
        }

        try await listItem.delete(on: req.db)

        return .noContent
    }
}
