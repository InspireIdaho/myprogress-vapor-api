import Vapor
import FluentMySQL
import Crypto

final class UserController: RouteCollection {
    
    func boot(router: Router) throws {
        let userRoutes = router.grouped("api", "user")
        
        // TODO: routes for testing **remove in production**
        
        // GET host/api/user
        // -> list of all users
        userRoutes.get(use: index)
        
        // GET host/api/user/{id}
        userRoutes.get(User.parameter, use: find)
        
        // GET host/api/user/{id}/progress
        userRoutes.get(User.parameter, "progress", use: progressList)
        
        // authenticated via Basic in HTTP Headers
        let basicAuthMiddleware = User.basicAuthMiddleware(using: BCryptDigest())
        let basicAuthGroup = userRoutes.grouped(basicAuthMiddleware)
        
        // POST host/api/user/login
        basicAuthGroup.post("login", use: login)
        
        // authenticated via Auth token in HTTP Headers
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = userRoutes.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware)
        
        // POST host/api/user (new user json in body)
        tokenAuthGroup.post(User.self, use: create)
        
        // POST host/api/user (new user json in body)
        tokenAuthGroup.post([User].self, use: createBatch)

        // GET host/api/user/me
        tokenAuthGroup.get("me", use: authUserForToken)
        
        // GET host/api/user/progress
        tokenAuthGroup.get("progress", use: authProgressList)
        
        // GET host/api/user/groups
        tokenAuthGroup.get("group", use: authGroupList)

    }
    
    func index(_ req: Request) throws -> Future<[User.Public]>  {
        return User.query(on: req).decode(data: User.Public.self) .all()
    }

    func find(_ req: Request) throws -> Future<User.Public>  {
        return try req.parameters.next(User.self).convertToPublic()
    }
    
    func authUserForToken(_ req: Request) throws -> Future<User.Public>  {
        let user = try req.requireAuthenticated(User.self)
        user.lastActivityDate = Date()
        return user.save(on: req).convertToPublic()
    }


    // use helper form of POST, pre-creates target model instance
    func create(_ req: Request, user: User) throws -> Future<User.Public>  {
        user.password = try BCrypt.hash(user.password)
        return user.save(on: req).convertToPublic()
    }

    func createBatch(_ req: Request, userList: [User]) throws -> Future<[User.Public]>  {
        return try userList.map { user in
            user.password = try BCrypt.hash(user.password)
            return user.save(on: req).convertToPublic()
        }.flatten(on: req)
    }

    func progressList(_ req: Request) throws -> Future<[Progress]> {
        return try req.parameters
            .next(User.self)
            .flatMap(to: [Progress].self) { user in
                return try user.progressList.query(on: req).all()
        }
    }
    
    func authProgressList(_ req: Request) throws -> Future<[Progress]> {
        let user = try req.requireAuthenticated(User.self)
        return try user.progressList.query(on: req).all()
    }

    func authGroupList(_ req: Request) throws -> Future<[Group]> {
        let user = try req.requireAuthenticated(User.self)
        return try user.groups.query(on: req).all()
    }

    
    func login(_ req: Request) throws -> Future<Response> {
        
        // this auth looks for 
        let user = try req.requireAuthenticated(User.self)
        user.lastActivityDate = Date()
        let token = try Token.generate(for: user)
        return flatMap(
            user.save(on: req),
            token.save(on: req)) { user, token in
                let resp = req.response()
                try resp.content.encode(user.convertToPublic())
                resp.http.headers.add(name: HTTPHeaderName.authenticationInfo, value: token.token)
                return req.future(resp)
        }
    }
}
