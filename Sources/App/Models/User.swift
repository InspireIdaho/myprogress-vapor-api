import Vapor
import FluentMySQL

final class User: Codable {
    var id: UUID?
    var email: String
    var password: String
    var username: String?
    
    init(email: String, password: String, username: String? = nil) {
        self.email = email
        self.password = password
        self.username = username
    }
}

extension User: MySQLUUIDModel {}
extension User: Migration {}
extension User: Content {}
extension User: Parameter {}

extension User {
    var progressList: Children<User, Progress> {
        return children(\.creatorID)
    }
}
