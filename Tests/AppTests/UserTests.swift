@testable import App

import Vapor
import XCTest
import FluentMySQL

final class UserTests: XCTestCase {
    
    let userEmail = "alice@bv.com"
    let userPassword = "wonder"
    let userUsername = "alice"

    let userAPI = "/api/user/"
    
    var app: Application!
    var conn: MySQLConnection!
    
    override func setUp() {
        try! Application.reset()
        app = try! Application.testable()
        conn = try! app.newConnection(to: .mysql).wait()
    }
    
    override func tearDown() {
        conn.close()
    }
    
    /// this test is vulnerable to fail if not executed first
    func testUsersCanBeRetrievedFromAPI() throws {
        
        let user = try User.create(
            email: userEmail,
            password: userPassword,
            username: userUsername,
            on: conn)
        
        _ = try User.create(on: conn)
        
        let users = try app.getResponse(to: userAPI, decodeTo: [User].self)
        
        XCTAssertEqual(users.count, 2)
        XCTAssertEqual(users[0].email, userEmail)
        XCTAssertEqual(users[0].password, userPassword)
        XCTAssertEqual(users[0].username, userUsername)
        XCTAssertEqual(users[0].id, user.id)
    }
    
    func testUserCanBeSavedWithAPI() throws {
       
        let user = User(
            email: userEmail,
            password: userPassword,
            username: userUsername)
        
        let receivedUser = try app.getResponse(
            to: userAPI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: user,
            decodeTo: User.self)
        
        XCTAssertEqual(receivedUser.email, userEmail)
        XCTAssertEqual(receivedUser.password, userPassword)
        XCTAssertEqual(receivedUser.username, userUsername)
        XCTAssertNotNil(receivedUser.id)

        let users = try app.getResponse(to: userAPI, decodeTo: [User].self)
        
        XCTAssertEqual(users.count, 1)
        XCTAssertEqual(users[0].email, userEmail)
        XCTAssertEqual(users[0].password, userPassword)
        XCTAssertEqual(users[0].username, userUsername)
        XCTAssertEqual(users[0].id, receivedUser.id)
    }
    
    func testGettingASingleUserFromTheAPI() throws {
        
        let user = try User.create(
            email: userEmail,
            password: userPassword,
            username: userUsername,
            on: conn)

        let receivedUser = try app.getResponse(
            to: "\(userAPI)\(user.id!)",
            decodeTo: User.self)

        XCTAssertEqual(receivedUser.email, userEmail)
        XCTAssertEqual(receivedUser.password, userPassword)
        XCTAssertEqual(receivedUser.username, userUsername)
        XCTAssertEqual(receivedUser.id, user.id)
    }
    
    func testGettingAUsersProgressItemsFromTheAPI() throws {
        
        let user = try User.create(on: conn)
        
        let progressIndexPath = "[9,7,5,3]"
        let progressCompletedOn = Date.init(timeInterval: 360, since: Date())
        
        let progress1 = try Progress.create(
            indexPath: progressIndexPath,
            completedOn: progressCompletedOn,
            creator: user,
            on: conn)
        _ = try Progress.create(
            creator: user,
            on: conn)
        
        let items = try app.getResponse(
            to: "\(userAPI)\(user.id!)/progress",
            decodeTo: [App.Progress].self)

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].id, progress1.id)
        XCTAssertEqual(items[0].indexPath, progressIndexPath)
        XCTAssertEqual(items[0].completedOn, progressCompletedOn.timeIntervalSinceReferenceDate)

    }
}
