//
//  HelpfulError.swift
//  App
//
//  Created by M. Sean Bonner on 8/11/19.
//

import Debugging
import Foundation

/// Errors that can be thrown while working with ProgressServer.
public struct HelpfulError: Debuggable {
    /// See `Debuggable`.
    public static let readableName = "Progress Server Error"
    
    /// See `Debuggable`.
    public let identifier: String
    
    /// See `Debuggable`.
    public var reason: String
    
    /// See `Debuggable`.
    public var possibleCauses: [String]
    
    /// See `Debuggable`.
    public var suggestedFixes: [String]
    
    /// See `Debuggable`.
    public var documentationLinks: [String]
    
    /// See `Debuggable`.
    public var sourceLocation: SourceLocation?
    
    /// See `Debuggable`.
    public var stackTrace: [String]
    
    /// Create a new `HelpfulError`.
    public init(
        identifier: String,
        reason: String,
        possibleCauses: [String] = [],
        suggestedFixes: [String] = [],
        documentationLinks: [String] = [],
        file: String = #file,
        function: String = #function,
        line: UInt = #line,
        column: UInt = #column
        ) {
        self.identifier = identifier
        self.reason = reason
        self.possibleCauses = possibleCauses
        self.suggestedFixes = suggestedFixes
        self.documentationLinks = documentationLinks
        self.sourceLocation = .init(file: file, function: function, line: line, column: column, range: nil)
        self.stackTrace = HelpfulError.makeStackTrace()
    }
    
//    /// Creates a new MySQL parse error.
//    static func parse(
//        _ identifier: String,
//        file: String = #file,
//        function: String = #function,
//        line: UInt = #line,
//        column: UInt = #column
//        ) -> HelpfulError {
//        return HelpfulError(identifier: "parse.\(identifier)", reason: "Could not parse MySQL packet.", file: file, function: function, line: line, column: column)
//    }
}

func ERROR(_ string: @autoclosure () -> (String)) {
    print("[ERROR] [PROGRESS] \(string())")
}

func VERBOSE(_ string: @autoclosure () -> (String)) {
    #if VERBOSE
    print("[VERBOSE] [PROGRESS] \(string())")
    #endif
}

