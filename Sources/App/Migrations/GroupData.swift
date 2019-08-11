//
//  GroupData.swift
//  App
//
//  Created by M. Sean Bonner on 8/11/19.
//

import Vapor
import FluentMySQL

struct GroupData: Migration {
    typealias Database = MySQLDatabase
    
    static func prepare(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return .done(on: conn)
    }
    
    static func revert(on conn: MySQLConnection) -> EventLoopFuture<Void> {
        return .done(on: conn)
    }
}
