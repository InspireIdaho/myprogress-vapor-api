
<style>
div.black { background-color: #606060 }
</style>

<div class = "black">
<p align="center" >
    <img src="https://www.inspireidaho.com/wp-content/uploads/2018/01/InspireIdaho-Home-1280.png" width="480" alt="InspireIdaho">
</div>

<p align="center">
    <br>
       <a href="https://vapor.codes">
        <img src="https://img.shields.io/badge/Vapor-3-brightgreen.svg" alt="Vapor Version">
    </a>
    <a href="LICENSE">
        <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
    </a>
    <a href="https://swift.org">
        <img src="http://img.shields.io/badge/swift-5.0.1-brightgreen.svg" alt="Swift 5.0.1">
    </a>
</p>


# myprogress-vapor-api

This pure Swift webservice serves as the persistent store for the MyProgress app. Leverages the powerful, robust and fast Vapor 3 framework. Provides JSON-based apis to the myprogress-ios app to centrally store participant course progress. 

## Requirements:

- Swift 5.0.1+
- MySQL 5.7+ database instance

## Installation

For most all learners, this service will be running in a cloud environment managed by InspireIdaho and accessible from your MyProgress app.  However, the service can be built and run in a local configuration (on Mac or linux) for testing, contributing and/or just kicking the tires! 

To install locally, open a Terminal (shell) and run the following:

```sh
cd <local project dir>
git clone https://github.com/InspireIdaho/myprogress-vapor-api.git
```
- project repo is downloaded 

```sh
cd myprogress-vapor-api
swift package generate-xcodeproj
```
- SPM fetches project dependencies defined in `Package.swift`
- Xcode project file is constructed from the swift package structure

```sh
open progress-server.xcodeproj
```

- Xcode project opens
- edit `./Sources/App/configure.swift`; update DB config to match local instance
	- 	Extra Points: you can also edit the `Run` scheme to set these `ENV` vars

```swift
    // Configure a MySQL database
    let mysqlConfig = MySQLDatabaseConfig(
        hostname: Environment.get("DATABASE_HOSTNAME") ?? "localhost",
        port: 3306,
        username: Environment.get("DATABASE_USER") ?? "vapor",
        password: Environment.get("DATABASE_PASSWORD") ?? "vapor",
        database: Environment.get("DATABASE_DB") ?? "inspire_idaho")
```

- **Important:** you have to provide your own, empty MySQL DB instance.  Vapor will manage initial schema creation, but it has to have credentials to create/modify/insert/delete.
	- Extra Points: with more-than-a-few tweaks, Vapor also supports Mongo DB (or even an in-memory SQLLite store, which is simpler to set-up, but any test data goes away when service stops!)

- in Xcode, set the Run scheme to `Run`, set target to `My Mac`
- then &#8984;-R to (build) & run the service
- look for last console message (within Xcode)

```sh
Server starting on http://localhost:8080
```

#### ALL SET!
Now you can update the [MyProgress](https://github.com/InspireIdaho/myprogress-ios) app `Config.swift` to use `.dev` Environment so app connects to your local dev service!

```swift

    static var current: Environment = .dev

        case .dev:
            return Config(displayName: "Development",
                          serverUrl: "http://localhost:8080/api/",
                          authHeaderKey: "Authentication-Info")
```

**Note:** this process uses the [Swift Package Manager (SPM)](https://swift.org/package-manager) which is still evolving in design and development, for more information checkout its [GitHub Page](https://github.com/apple/swift-package-manager)



## Slack Channel

Questions, bugs reports, comments, suggestions, and feature ideas are always welcome,  so come [join our Slack channel](http://inspireidaho.slack.com).

## Credits

This service is developed and maintained by [M. Sean Bonner](https://github.com/mseanbonner) with the collaboration of the [InspireIdaho](https://www.inspireidaho.com) community.

## License

myprogress-vapor-api is released under an MIT license. See [license](LICENSE) for more information.
