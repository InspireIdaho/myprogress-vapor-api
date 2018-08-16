import Vapor
import Leaf
import FluentMySQL

final class WebsiteController: RouteCollection {
    
    func boot(router: Router) throws {
        router.get(use: index)
    }
    
    func index(_ req: Request) throws -> Future<View>  {
        return Progress.query(on: req)
        .all()
            .flatMap(to: View.self) { nodes in
                
                let nodesData = nodes.isEmpty ? nil : nodes
        let context = IndexContent(
            title: "Homepage",
            progressNodes: nodesData)
        return try req.view().render("index", context)
        }
    }
    
    
    struct IndexContent: Encodable {
        let title: String
        let progressNodes: [App.Progress]?
    }
}
