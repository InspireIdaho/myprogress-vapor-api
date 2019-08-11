//
//  Team.swift
//  App
//
//  Created by M. Sean Bonner on 8/10/19.
//

import Vapor
import FluentMySQL
import Authentication


/// Represent Team with User members
final class Group: Codable {
    var id: UUID?
    var name: String
    var slackChannelName: String
    var location: String
    var groupRoleEnum: Int //= Group.Role.participant.rawValue
    var owner: User.ID

    enum Role : Int {
        case participant = 0
        case reporting
        case admin
        case undef

        static let names = ["Participant", "Reporting", "Admin", "Unknown"]
        
        var displayName: String {
            get {
                return Group.Role.names[self.rawValue]
            }
        }
    }
    
    init(data: GroupCreateData, owner: User.ID) {
        self.name = data.name
        self.slackChannelName = data.slackChannelName
        self.location = data.location
        self.groupRoleEnum = data.groupRoleEnum ?? Group.Role.participant.rawValue
        self.owner = owner
    }

    /// public representation of Group
    final class Public: Codable {
        var id: UUID?
        var name: String
        //var slackChannelName: String
        var location: String
        var groupRoleEnum: Int
        var owner: User.ID
        
        init(group: Group) {
            self.id = group.id
            self.name = group.name
            self.location = group.location
            self.groupRoleEnum = group.groupRole.rawValue
            self.owner = group.owner
        }
    }
    
    struct GroupCreateData: Content {
        let name: String
        let slackChannelName: String
        let location: String
        let groupRoleEnum: Int?
    }


}

extension Group.Public: Content {}

extension Group {
    
    var groupRole: Group.Role {
        get {
            return Group.Role(rawValue: self.groupRoleEnum) ?? Group.Role.undef
        }
    }
    /// derived list of members of this group
    var members: Siblings<Group, User, Member> {
        return siblings()
    }

}

extension Group: MySQLUUIDModel {}
extension Group: Content {}
extension Group: Parameter {}

extension Group: Migration {
    static func prepare(on connection: MySQLConnection) -> Future<Void> {
        return Database.create(self, on: connection) { builder in
            
            // default behavior,
            try addProperties(to: builder)
            
            builder.unique(on: \.name)
        }
    }
    
}
