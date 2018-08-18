import Vapor
import FluentMySQL
import Authentication

final class ProgressController: RouteCollection {
    
    func boot(router: Router) throws {
        let progressRoutes = router.grouped("api", "progress")
        
        progressRoutes.get(use: index)
        // use helper form of POST
        //progressRoutes.post(Progress.self, use: create)
        progressRoutes.get(Progress.parameter, use: find)
        
        progressRoutes.get(Progress.parameter, "creator", use: getCreator)
        
        let tokenAuthMiddleware =
            User.tokenAuthMiddleware()
        // 2
        let guardAuthMiddleware = User.guardAuthMiddleware()
        // 3
        let tokenAuthGroup = progressRoutes.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware)
        // 4
        tokenAuthGroup.post(Progress.ProgressCreateData.self, use: create)
        tokenAuthGroup.put(Progress.parameter, use: update)
        tokenAuthGroup.delete(Progress.parameter, use: delete)
  }
    
    func index(_ req: Request) throws -> Future<[Progress]>  {
        return Progress.query(on: req).all()
    }
    
    func find(_ req: Request) throws -> Future<Progress>  {
        return try req.parameters.next(Progress.self)
    }
    
    // use helper form of POST, pre-creates target model instance
    //func create(_ req: Request, progress: Progress) throws -> Future<Progress>  {
    func create(_ req: Request, data: Progress.ProgressCreateData) throws -> Future<Progress>
    {
        let user = try req.requireAuthenticated(User.self)
        let progress = try Progress(indexPath: data.indexPath,
                                    completedOn: data.completedOn,
                                    creatorID: user.requireID())
        return progress.save(on: req)
    }
    
    func update(_ req: Request) throws -> Future<Progress>  {
        return try flatMap(
            to: Progress.self,
            req.parameters.next(Progress.self),
            req.content.decode(Progress.ProgressCreateData.self)) {
                targetProgress, sourceProgress in
                targetProgress.patch(from: sourceProgress)
                let user = try req.requireAuthenticated(User.self)
                targetProgress.creatorID = try user.requireID()
                return targetProgress.save(on: req)
        }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus>  {
        return try req.parameters
            .next(Progress.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }

    func getCreator(_ req: Request) throws -> Future<User> {
        return try req.parameters
            .next(Progress.self)
            .flatMap(to: User.self) { progress in
                return progress.creator.get(on: req)
        }
    }
    
}
