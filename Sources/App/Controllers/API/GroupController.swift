//
//  GroupController.swift
//  App
//
//  Created by M. Sean Bonner on 8/10/19.
//

import Vapor
import FluentMySQL
import Crypto

final class GroupController: RouteCollection {
    
    func boot(router: Router) throws {
        let groupRoutes = router.grouped("api", "group")

        // GET host/api/group
        // -> list of all groups
        groupRoutes.get(use: index)
        
        // GET host/api/group/:group_id/members
        groupRoutes.get(Group.parameter, "members", use: getMembers)
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = groupRoutes.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware)

        // POST host/api/group  (json in body)
        tokenAuthGroup.post(Group.GroupCreateData.self, use: create)

        // POST host/api/group  (array of json in body)
        tokenAuthGroup.post([Group.GroupCreateData].self, use: createBatch)

        // POST host/api/group/:group_id/add/:user_id
        tokenAuthGroup.post(Group.parameter, "add", User.parameter, use: addMember)

    }
    
    func index(_ req: Request) throws -> Future<[Group.Public]>  {
        return Group.query(on: req).decode(data: Group.Public.self).all()
    }
    
    func getMembers(_ req: Request) throws -> Future<[User.Public]>  {
        return try req.parameters
            .next(Group.self)
            .flatMap(to: [User.Public].self) { group in
                return try group.members.query(on: req)
                    .decode(data: User.Public.self).all()
        }
    }
    
    func addMember(_ req: Request) throws -> Future<Member>  {
        return try flatMap(
            to: Member.self,
            req.parameters.next(Group.self),
            req.parameters.next(User.self) ){
                group, user in
                let member = try Member(user, group)
                return member.save(on: req)
        }
    }
    
    func create(_ req: Request, data: Group.GroupCreateData) throws -> Future<Group>
    {
        let user = try req.requireAuthenticated(User.self)
        let group = try Group(data: data, owner: user.requireID())
        return group.save(on: req)
    }

    func createBatch(_ req: Request, data: [Group.GroupCreateData]) throws -> Future<[Group]>
    {
        let user = try req.requireAuthenticated(User.self)
        return try data.map { groupData in
            return try Group(data: groupData, owner: user.requireID()).save(on: req)
        }.flatten(on: req)
    }

    
}
