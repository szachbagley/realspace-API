import Vapor
import Fluent
import JWT

struct AuthController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")

        auth.post("register", use: register)
        auth.post("login", use: login)

        // Protected route - requires authentication
        let protected = auth.grouped(UserAuthenticator(), User.guardMiddleware())
        protected.get("me", use: getCurrentUser)
    }

    // POST /auth/register
    func register(req: Request) async throws -> AuthResponseDTO {
        let createUser = try req.content.decode(CreateUserDTO.self)

        // Validate username is unique
        if let _ = try await User.query(on: req.db)
            .filter(\.$username == createUser.username)
            .first() {
            throw Abort(.badRequest, reason: "Username already taken")
        }

        // Validate email is unique
        if let _ = try await User.query(on: req.db)
            .filter(\.$email == createUser.email)
            .first() {
            throw Abort(.badRequest, reason: "Email already registered")
        }

        // Hash password
        let passwordHash = try Bcrypt.hash(createUser.password)

        // Create user
        let user = User(
            username: createUser.username,
            displayName: createUser.displayName,
            email: createUser.email,
            passwordHash: passwordHash,
            bio: createUser.bio ?? ""
        )

        try await user.save(on: req.db)

        // Generate JWT token
        let token = try generateToken(for: user, req: req)

        return AuthResponseDTO(
            token: token,
            user: UserResponseDTO(from: user)
        )
    }

    // POST /auth/login
    func login(req: Request) async throws -> AuthResponseDTO {
        let loginDTO = try req.content.decode(LoginDTO.self)

        // Find user by email
        guard let user = try await User.query(on: req.db)
            .filter(\.$email == loginDTO.email)
            .first() else {
            throw Abort(.unauthorized, reason: "Invalid email or password")
        }

        // Verify password
        let isValid = try Bcrypt.verify(loginDTO.password, created: user.passwordHash)
        guard isValid else {
            throw Abort(.unauthorized, reason: "Invalid email or password")
        }

        // Generate JWT token
        let token = try generateToken(for: user, req: req)

        return AuthResponseDTO(
            token: token,
            user: UserResponseDTO(from: user)
        )
    }

    // GET /auth/me
    func getCurrentUser(req: Request) async throws -> UserResponseDTO {
        let user = try req.auth.require(User.self)
        return UserResponseDTO(from: user)
    }

    // Helper: Generate JWT token
    private func generateToken(for user: User, req: Request) throws -> String {
        let payload = UserPayload(
            userID: user.id!,
            username: user.username,
            exp: ExpirationClaim(value: Date().addingTimeInterval(60 * 60 * 24 * 30)) // 30 days
        )
        return try req.jwt.sign(payload)
    }
}

// JWT Payload
struct UserPayload: JWTPayload {
    var userID: UUID
    var username: String
    var exp: ExpirationClaim

    func verify(using signer: JWTSigner) throws {
        try exp.verifyNotExpired()
    }
}

// User Authenticator Middleware
struct UserAuthenticator: AsyncJWTAuthenticator {
    typealias Payload = UserPayload

    func authenticate(jwt: UserPayload, for request: Request) async throws {
        guard let user = try await User.find(jwt.userID, on: request.db) else {
            return
        }
        request.auth.login(user)
    }
}
