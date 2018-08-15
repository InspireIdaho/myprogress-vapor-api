import Vapor
import FluentMySQL

final class ProgressController: RouteCollection {
    
    func boot(router: Router) throws {
        let progressRoutes = router.grouped("api", "progress")
        
        progressRoutes.get(use: index)
        // use helper form of POST
        progressRoutes.post(Progress.self, use: create)
        progressRoutes.get(Progress.parameter, use: find)
        progressRoutes.put(Progress.parameter, use: update)
        progressRoutes.delete(Progress.parameter, use: delete)
    }
    
    func index(_ req: Request) throws -> Future<[Progress]>  {
        return Progress.query(on: req).all()
    }
    
    func find(_ req: Request) throws -> Future<Progress>  {
        return try req.parameters.next(Progress.self)
    }
    
    // use helper form of POST, pre-creates target model instance
    func create(_ req: Request, progress: Progress) throws -> Future<Progress>  {
        return progress.save(on: req)
    }
    
    func update(_ req: Request) throws -> Future<Progress>  {
        return try flatMap(
            to: Progress.self,
            req.parameters.next(Progress.self),
            req.content.decode(Progress.self)) {
                targetProgress, sourceProgress in
                targetProgress.indexPath = sourceProgress.indexPath
                targetProgress.completedOn = sourceProgress.completedOn
                return targetProgress.save(on: req)
        }
    }

    func delete(_ req: Request) throws -> Future<HTTPStatus>  {
        return try req.parameters
            .next(Progress.self)
            .delete(on: req)
            .transform(to: HTTPStatus.noContent)
    }


}
