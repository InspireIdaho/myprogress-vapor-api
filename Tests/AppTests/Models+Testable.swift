@testable import App

import Vapor
import XCTest
import FluentMySQL
import Crypto

extension User {
    
    /// Testing helper; provides defaults, if needed
    static func create(
        email: String = "mickey@bv.com",
        password: String = "steamboat",
        username: String? = "mickey",
        on connection: MySQLConnection
        ) throws -> User {
        
        let hashedPassword = try BCrypt.hash(password)
        let user = User(
            email: email,
            password: hashedPassword,
            username: username)
        return try user.save(on: connection).wait()
    }
    
}

extension App.Progress {
    
    /// Testing helper; provides defaults, if needed
    static func create(
        indexPath: String = "[1,2,3,4]",
        completedOn: Date = Date(),
        creator: User? = nil,
        on connection: MySQLConnection
        ) throws -> App.Progress {
        
        var progressCreator = creator
        
        if progressCreator == nil {
            progressCreator = try User.create(on: connection)
        }
        let item = Progress(
            indexPath: indexPath,
            completedOn: completedOn.timeIntervalSinceReferenceDate,
            creatorID: progressCreator!.id!)
        return try item.save(on: connection).wait()
    }

}
