import Vapor
import FluentMySQL
import Authentication

/// Represent User that can be auth'd
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
    
    /// public representation of User w/o password
    final class Public: Codable {
        var id: UUID?
        var email: String
        var username: String?
        
        init(id: UUID?, email: String, username: String?) {
            self.id = id
            self.email = email
            self.username = username
        }

    }
}

extension User.Public: Content {}

extension User {
    /// derived list of associated Progress nodes
    var progressList: Children<User, Progress> {
        return children(\.creatorID)
    }
    
    /// derived list of groups the user is a member of
    var groups: Siblings<User, Group, Member> {
        return siblings()
    }
    
    ///
    func convertToPublic() -> User.Public {
        return User.Public(id: id, email: email, username: username)
    }
}

extension Future where T: User {
    
    func convertToPublic() -> Future<User.Public> {
        return self.map(to: User.Public.self) { user in
            return user.convertToPublic()
        }
    }
}

extension User: MySQLUUIDModel {}
extension User: Content {}
extension User: Parameter {}

extension User: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            
            // default behavior,
            try addProperties(to: builder)
            
            builder.unique(on: \.email)
        }
    }

}

extension User: BasicAuthenticatable {
    static var usernameKey: UsernameKey = \User.email
    static var passwordKey: PasswordKey = \User.password
}

extension User: TokenAuthenticatable {
    typealias TokenType = Token
}

struct AdminUser: Migration {
    typealias Database = MySQLDatabase
    
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        let password = try? BCrypt.hash("vapor")
        guard let hashedPassword = password else {
            fatalError("failed to create admin user")
        }
        let user = User(email: "admin@bv.com", password: hashedPassword)
        return user.save(on: conn).transform(to: ())
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return .done(on: conn)
    }
}
