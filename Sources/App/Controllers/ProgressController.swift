import Vapor
import FluentSQLite

final class ProgressController: RouteCollection {
    
    func boot(router: Router) throws {
        let progressRoutes = router.grouped("api", "progress")
        
        progressRoutes.get(use: index)
        progressRoutes.post(use: create)
//        categoryRoutes.post(Category.parameter, "delete", use: self.delete)
//        categoryRoutes.post(Category.parameter, "edit", use: self.edit)
//        categoryRoutes.post(Category.parameter, "update", use: self.update)
    }
    
    func index(_ req: Request) throws -> Future<[Progress]>  {
        return Progress.query(on: req).all()
    }
    
    func create(_ req: Request) throws -> Future<Progress>  {
        return try req.content.decode(Progress.self)
            .flatMap(to: Progress.self) { progress in
                return progress.save(on: req)
        }
    }

}
