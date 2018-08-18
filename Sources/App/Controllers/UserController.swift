import Vapor
import FluentMySQL
import Crypto

final class UserController: RouteCollection {
    
    func boot(router: Router) throws {
        let userRoutes = router.grouped("api", "user")
        
        userRoutes.get(use: index)
        userRoutes.get(User.parameter, use: find)
        
//        userRoutes.put(Progress.parameter, use: update)
//        userRoutes.delete(Progress.parameter, use: delete)
        
        userRoutes.get(User.parameter, "progress", use: progressList)
        
        let basicAuthMiddleware =
            User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = userRoutes.grouped(basicAuthMiddleware)
        basicAuthGroup.post("login", use: login)
        
        let tokenAuthMiddleware =
            User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = userRoutes.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware)
        
        tokenAuthGroup.post(User.self, use: create)
    }
    
    func index(_ req: Request) throws -> Future<[User.Public]>  {
        return User.query(on: req).decode(data: User.Public.self) .all()
    }

    func find(_ req: Request) throws -> Future<User.Public>  {
        return try req.parameters.next(User.self).convertToPublic()
    }

    // use helper form of POST, pre-creates target model instance
    func create(_ req: Request, user: User) throws -> Future<User.Public>  {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).convertToPublic()
    }

    func progressList(_ req: Request) throws -> Future<[Progress]> {
        return try req.parameters
            .next(User.self)
            .flatMap(to: [Progress].self) { user in
                return try user.progressList.query(on: req).all()
        }
    }
    
    func login(_ req: Request) throws -> Future<Token> {
        let user = try req.requireAuthenticated(User.self)
        let token = try Token.generate(for: user)
        return token.save(on: req)
    }
}
