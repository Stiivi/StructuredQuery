import XCTest
@testable import CompilerTests
@testable import ExpressionTests

XCTMain([
     testCase(CompilerTests.allTests),
     testCase(ExpressionTests.allTests),
])
