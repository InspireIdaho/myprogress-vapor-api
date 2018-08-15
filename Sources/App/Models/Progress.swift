import Vapor
import FluentMySQL

final class Progress: Codable {
    var id: Int?
    var indexPath: String
    var completedOn: Double
    var creatorID: User.ID

    
    init(indexPath: String, completedOn: Double, creatorID: User.ID) {
        self.indexPath = indexPath
        self.completedOn = completedOn
        self.creatorID = creatorID
    }
    
    /// convenience method to update properties in this instance from another
    /// keep internal knowledge in one place
    func patch(from: Progress) {
        self.indexPath = from.indexPath
        self.completedOn = from.completedOn
        // TODO: check both instances have same owner before copying; throw error?
        self.creatorID = from.creatorID
    }
}

/// derived property
extension Progress {
    var creator: Parent<Progress, User> {
        return parent(\.creatorID)
    }
}
extension Progress: MySQLModel {}
extension Progress: Content {}
extension Progress: Parameter {}

extension Progress: Migration {
    
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            
            // default behavior,
            try addProperties(to: builder)
            
            builder.reference (from: \.creatorID, to: \User.id)
        }
    }
}

