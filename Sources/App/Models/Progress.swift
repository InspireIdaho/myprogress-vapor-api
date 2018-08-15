import Vapor
import FluentMySQL

final class Progress: Codable {
    var id: Int?
    var indexPath: String
    var completedOn: Double
    //var _creator: Int
    
    init(indexPath: String, completedOn: Double) {
        self.indexPath = indexPath
        self.completedOn = completedOn
    }
}

extension Progress: MySQLModel {}
extension Progress: Migration {}
extension Progress: Content {}
extension Progress: Parameter {}
