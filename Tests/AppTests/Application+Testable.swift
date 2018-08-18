@testable import App
import Vapor
import FluentMySQL
import Authentication

extension Application {
    
    /// Perform setup for testing env
    static func testable(envArgs: [String]? = nil) throws
        -> Application {
            var config = Config.default()
            var services = Services.default()
            var env = Environment.testing
            
            if let environmentArgs = envArgs {
                env.arguments = environmentArgs
            }
            
            try App.configure(&config, &env, &services)
            let app = try Application(
                config: config,
                environment: env,
                services: services)
            
            try App.boot(app)
            return app
    }
    
    /// Execute Fluent commands to revert/migrate leaving empty DB
    static func reset() throws {
        let revertEnvironment = ["vapor", "revert", "--all", "-y"]
        try Application.testable(envArgs: revertEnvironment)
            .asyncRun()
            .wait()
        let migrateEnvironment = ["vapor", "migrate", "-y"]
        try Application.testable(envArgs: migrateEnvironment)
            .asyncRun()
            .wait()
    }
    
    // MARK: request sending helpers
    // 1
    /// Primary Testing helper to send wrapped Request
    func sendRequest<T>(
        to path: String,
        method: HTTPMethod,
        headers: HTTPHeaders = .init(),
        body: T? = nil,
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws -> Response where T: Content {
        
        var headers = headers
        if (loggedInRequest || loggedInUser != nil) {
            let email: String
            if let user = loggedInUser {
                email = user.email
            } else {
                email = "admin@bv.com"
            }
            
            let credentials = BasicAuthorization(username: email, password: "vapor")
            var tokenHeaders = HTTPHeaders()
            tokenHeaders.basicAuthorization = credentials
            
            let tokenResponse = try self.sendRequest(
                to: "/api/user/login",
                method: .POST,
                headers: tokenHeaders)
            
            let token = try tokenResponse.content.syncDecode(Token.self)
            headers.add(name: .authorization, value: "Bearer \(token.token)")
        }
        
        let responder = try self.make(Responder.self)
        // 2
        let request = HTTPRequest(
            method: method,
            url: URL(string: path)!,
            headers: headers)
        let wrappedRequest = Request(http: request, using: self)
        // 3
        if let body = body {
            try wrappedRequest.content.encode(body)
        }
        // 4
        return try responder.respond(to: wrappedRequest).wait()
    }
    
    // 5
    /// allow request with no body/content, just status resp
    func sendRequest(
        to path: String,
        method: HTTPMethod,
        headers: HTTPHeaders = .init(),
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws -> Response {
        // 6
        let emptyContent: EmptyContent? = nil
        // 7
        return try sendRequest(
            to: path,
            method: method,
            headers: headers,
            body: emptyContent,
            loggedInRequest: loggedInRequest,
            loggedInUser: loggedInUser
        )
    }
    
    // 8
    /// allow request send with data T in body, just status resp
    func sendRequest<T>(
        to path: String,
        method: HTTPMethod,
        headers: HTTPHeaders,
        data: T,
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws where T: Content {
        // 9
        _ = try self.sendRequest(
            to: path,
            method: method,
            headers: headers,
            body: data,
            loggedInRequest: loggedInRequest,
            loggedInUser: loggedInUser
        )
    }
    
    // MARK: response helpers

    // 1
    /// Testing helper to decode Response T after sending data C to server,
    func getResponse<C, T>(
        to path: String,
        method: HTTPMethod = .GET,
        headers: HTTPHeaders = .init(),
        data: C? = nil,
        decodeTo type: T.Type,
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws -> T where C: Content, T: Decodable {
        // 2
        let response = try self.sendRequest(
            to: path,
            method: method,
            headers: headers,
            body: data,
            loggedInRequest: loggedInRequest,
            loggedInUser: loggedInUser
        )
        return try response.content.decode(type).wait()
    }
    
    // 4
    /// just decode T returned, no content sent
    func getResponse<T>(
        to path: String,
        method: HTTPMethod = .GET,
        headers: HTTPHeaders = .init(),
        decodeTo type: T.Type,
        loggedInRequest: Bool = false,
        loggedInUser: User? = nil
        ) throws -> T where T: Decodable {
        // 5
        let emptyContent: EmptyContent? = nil
        // 6
        return try self.getResponse(
            to: path,
            method: method,
            headers: headers,
            data: emptyContent,
            decodeTo: type,
            loggedInRequest: loggedInRequest,
            loggedInUser: loggedInUser
        )
    }
    
}

struct EmptyContent: Content {}
