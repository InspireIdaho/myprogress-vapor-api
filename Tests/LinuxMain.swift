import XCTest
@testable import AppTests

XCTMain([
    testCase(ProgressTests.allTests),
    testCase(UserTests.allTests)
])
