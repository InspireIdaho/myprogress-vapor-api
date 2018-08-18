import Foundation
import Vapor
import FluentMySQL
import Authentication

final class Token: Codable {
    var id: UUID?
    var token: String
    var userID: User.ID
    
    init(token: String, userID: User.ID) {
        self.token = token
        self.userID = userID
    }
}

extension Token: MySQLUUIDModel {}

extension Token: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            try addProperties(to: builder)
            builder.reference(from: \.userID, to: \User.id)
        }
    }
}

extension Token: Content {}

extension Token {
    // 1
    static func generate(for user: User) throws -> Token {
        // 2
        let random = try CryptoRandom().generateData(count: 16)
        // 3
        return try Token(
            token: random.base64EncodedString(),
            userID: user.requireID())
    }
}

extension Token: Authentication.Token {
    typealias UserType = User
    static let userIDKey: UserIDKey = \Token.userID
}

extension Token: BearerAuthenticatable {
    static let tokenKey: TokenKey = \Token.token
}
