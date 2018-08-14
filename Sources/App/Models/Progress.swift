import Vapor
import FluentSQLite

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

extension Progress: SQLiteModel {}
extension Progress: Migration {}
extension Progress: Content {}
