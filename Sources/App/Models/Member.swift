//
//  Member.swift
//  App
//
//  Created by M. Sean Bonner on 8/10/19.
//

import Vapor
import FluentMySQL
import Authentication


/// Represent Team with User members
final class Member: ModifiablePivot {
    
    var id: UUID?
    var memberRoleEnum: Int = Member.Role.participant.rawValue
    
    // relationships
    var userID: User.ID
    var groupID: Group.ID
    
    typealias Left = User
    typealias Right = Group
    
    static var leftIDKey: LeftIDKey = \.userID
    static var rightIDKey: RightIDKey = \.groupID
    
    enum Role : Int {
        case participant = 0
        case expert
        case mentor
    }
    
    init(_ user: User, _ group: Group, role: Group.Role) throws {
        userID = try user.requireID()
        groupID = try group.requireID()
        memberRoleEnum = role.rawValue
    }
    
    init(_ user: User, _ group: Group) throws {
        userID = try user.requireID()
        groupID = try group.requireID()
        memberRoleEnum = Member.Role.participant.rawValue
    }

}


extension Member: MySQLUUIDModel {}
extension Member: Content {}
extension Member: Parameter {}

extension Member: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            // default behavior,
            try addProperties(to: builder)
        }
    }
    
}
