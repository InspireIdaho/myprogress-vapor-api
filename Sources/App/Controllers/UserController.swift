import Vapor
import FluentMySQL

final class UserController: RouteCollection {
    
    func boot(router: Router) throws {
        let userRoutes = router.grouped("api", "user")
        
        userRoutes.get(use: index)
        // use helper form of POST
        userRoutes.post(User.self, use: create)
        userRoutes.get(User.parameter, use: find)
//        userRoutes.put(Progress.parameter, use: update)
//        userRoutes.delete(Progress.parameter, use: delete)
        
        userRoutes.get(User.parameter, "progress", use: progressList)
    }
    
    func index(_ req: Request) throws -> Future<[User]>  {
        return User.query(on: req).all()
    }

    func find(_ req: Request) throws -> Future<User>  {
        return try req.parameters.next(User.self)
    }

    // use helper form of POST, pre-creates target model instance
    func create(_ req: Request, user: User) throws -> Future<User>  {
        return user.save(on: req)
    }

    func progressList(_ req: Request) throws -> Future<[Progress]> {
        return try req.parameters
            .next(User.self)
            .flatMap(to: [Progress].self) { user in
                return try user.progressList.query(on: req).all()
        }
    }
}
