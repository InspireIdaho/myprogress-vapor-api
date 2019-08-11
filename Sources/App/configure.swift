import FluentMySQL
import Vapor
import Leaf
import Authentication

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    /// Register providers first
    try services.register(LeafProvider())
    try services.register(FluentMySQLProvider())
    try services.register(AuthenticationProvider())

    config.prefer(LeafRenderer.self, for: ViewRenderer.self)

    /// Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)

    /// Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    // Configure a MySQL database
    
    let databaseName: String
    
    if (env == .testing) {
        databaseName = "inspire_test"
    } else {
        databaseName = Environment.get("DATABASE_DB") ?? "inspire_idaho"
    }
    
    let mysqlConfig = MySQLDatabaseConfig(
        hostname: Environment.get("DATABASE_HOSTNAME") ?? "localhost",
        port: 3306,
        username: Environment.get("DATABASE_USER") ?? "vapor",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor",
        database: databaseName)

    /// Register the configured SQLite database to the database config.
    var databases = DatabasesConfig()
    let database = MySQLDatabase(config: mysqlConfig)
    databases.add(database: database, as: .mysql)
    services.register(databases)

    /// Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .mysql)
    // must create User first, as Progress FK references
    migrations.add(model: Progress.self, database: .mysql)
    migrations.add(model: Token.self, database: .mysql)
    migrations.add(model: Member.self, database: .mysql)
    migrations.add(model: Group.self, database: .mysql)

    migrations.add(migration: AdminUser.self, database: .mysql)
    services.register(migrations)

    /// Configure commands
    var commandConfig = CommandConfig.default()
    commandConfig.useFluentCommands()
    services.register(commandConfig)
}
