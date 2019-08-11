//
//  MemberController.swift
//  App
//
//  Created by M. Sean Bonner on 8/11/19.
//

import Vapor
import FluentMySQL
import Crypto

final class MemberController: RouteCollection {
    
    func boot(router: Router) throws {
        let groupRoutes = router.grouped("api", "member")
        
        let tokenAuthMiddleware = User.tokenAuthMiddleware()
        let guardAuthMiddleware = User.guardAuthMiddleware()
        let tokenAuthGroup = groupRoutes.grouped(
            tokenAuthMiddleware,
            guardAuthMiddleware)
        
        // POST host/api/member (body: json)
        tokenAuthGroup.post(Member.AttachUserToGroup.self, use: attachMember)
        
        // POST host/api/member (body: [json])
        tokenAuthGroup.post([Member.AttachUserToGroup].self, use: attachBatch)
        
        
    }
    
    
    func attachMember(_ req: Request, data: Member.AttachUserToGroup) throws -> Future<Member>
    {
        return try Member.attach(member: data, on: req)
    }
    
    func attachBatch(_ req: Request, data: [Member.AttachUserToGroup]) throws -> Future<[Member]>
    {
        return try data.map { memberData in
            return try Member.attach(member: memberData, on: req)
            }.flatten(on: req)
    }
    
}
