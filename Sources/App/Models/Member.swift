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
    
    init(_ user: User, _ group: Group, _ role: Member.Role) throws {
        userID = try user.requireID()
        groupID = try group.requireID()
        memberRoleEnum = role.rawValue
    }
    
    init(_ user: User, _ group: Group) throws {
        userID = try user.requireID()
        groupID = try group.requireID()
        memberRoleEnum = Member.Role.participant.rawValue
    }

    struct AttachUserToGroup: Content {
        let userID: User.ID
        let groupID: Group.ID
        let role: Int?
    }

    static func attach(member: AttachUserToGroup,
        on conn: DatabaseConnectable) throws -> Future<Member> {
        
        var role = Member.Role.participant
        if let roleID = member.role {
            if let possRole = Member.Role.init(rawValue: roleID) {
                role = possRole
            }
        }

        return flatMap(to: Member.self,
                       User.find(member.userID, on: conn),
                       Group.find(member.groupID, on: conn)) { user, group in
                        guard let user = user else {
                            throw HelpfulError(identifier: "Invalid Membership", reason: "User with ID[\(member.userID)] not found")
                        }
                        guard let group = group else {
                            throw HelpfulError(identifier: "Invalid Membership", reason: "Group with ID[\(member.groupID)] not found")
                        }
                        return try Member(user, group, role).save(on: conn)
        }
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
