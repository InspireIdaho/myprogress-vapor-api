@testable import App

import Vapor
import XCTest
import FluentMySQL

final class ProgressTests: XCTestCase {
    
    let testIndexPath = "[2,4,6,8]"
    let testCompletedOn = Date()
    
    let progressAPI = "/api/progress/"
    
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
    
    func testProgressCanBeRetrievedFromAPI() throws {
        
        let user = try? User.create(
            email: "goofy@bv.com",
            password: "yukyuk",
            on: conn)
        
        let progress = try Progress.create(
            indexPath: testIndexPath,
            completedOn: testCompletedOn,
            creator: user,
            on: conn)

        _ = try Progress.create(on: conn)
        
        let progressNodes = try app.getResponse(to: progressAPI, decodeTo: [App.Progress].self)
        
        XCTAssertEqual(progressNodes.count, 2)
        XCTAssertEqual(progressNodes[0].indexPath, testIndexPath)
        XCTAssertEqual(progressNodes[0].completedOn, testCompletedOn.timeIntervalSinceReferenceDate)
        XCTAssertEqual(progressNodes[0].id, progress.id)
    }
    
    func testProgressCanBeSavedWithAPI() throws {
        
        let user = try User.create(on: conn)
        
        let progress = Progress(
            indexPath: testIndexPath,
            completedOn: testCompletedOn.timeIntervalSinceReferenceDate,
            creatorID: user.id!)

        let receivedNode = try app.getResponse(
            to: progressAPI,
            method: .POST,
            headers: ["Content-Type": "application/json"],
            data: progress,
            decodeTo: App.Progress.self,
            loggedInRequest: true)

        XCTAssertEqual(receivedNode.indexPath, testIndexPath)
        XCTAssertEqual(receivedNode.completedOn, testCompletedOn.timeIntervalSinceReferenceDate)
        XCTAssertNotNil(receivedNode.id)

        let nodes = try app.getResponse(to: progressAPI, decodeTo: [App.Progress].self)

        XCTAssertEqual(nodes.count, 1)
        XCTAssertEqual(nodes[0].indexPath, testIndexPath)
        XCTAssertEqual(nodes[0].completedOn, testCompletedOn.timeIntervalSinceReferenceDate)
        XCTAssertEqual(nodes[0].id, receivedNode.id)
    }
    
    func testGettingASingleProgressFromTheAPI() throws {
        
        let user = try User.create(on: conn)
        
        let progress = try Progress.create(
            indexPath: testIndexPath,
            completedOn: testCompletedOn,
            creator: user,
            on: conn)

        let receivedNode = try app.getResponse(
            to: "\(progressAPI)\(progress.id!)",
            decodeTo: App.Progress.self)
        
        XCTAssertEqual(receivedNode.indexPath, testIndexPath)
        XCTAssertEqual(receivedNode.completedOn, testCompletedOn.timeIntervalSinceReferenceDate)
        XCTAssertEqual(receivedNode.id, progress.id)

    }
    
}
