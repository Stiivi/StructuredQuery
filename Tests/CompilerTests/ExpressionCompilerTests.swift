import XCTest

@testable import Expression
@testable import Compiler

class ExpressionCompilerTestCase: XCTestCase {
	func compile(_ expression: Expression) -> String {
		let compiler = ExpressionCompiler()
		return compiler.visit(expression: expression)
	}

	func testVisitNull() {
		XCTAssertEqual(compile(nil), "NULL")
	}

	func testVisitInteger() {
		XCTAssertEqual(compile(1024), "1024")
	}

	func testVisitBool() {
		XCTAssertEqual(compile(true), "true")
		XCTAssertEqual(compile(false), "false")
	}

	// TODO: test for special characters, newlines
	func testVisitString() {
		XCTAssertEqual(compile("text"), "'text'")
		XCTAssertEqual(compile("qu'ote"), "'qu''ote'")
	}

	func testVisitBinary() {
		let e: Expression = 1
		let b: Expression = true

		XCTAssertEqual(compile(e + 2), "1 + 2")
		XCTAssertEqual(compile(e == 2), "1 = 2")
		XCTAssertEqual(compile(b && false), "true AND false")
		XCTAssertEqual(compile(b || false), "true OR false")
	}

	func testVisitUnary() {
		let e: Expression = 1
		let b: Expression = true

		XCTAssertEqual(compile(-e), "- 1")
		XCTAssertEqual(compile(!b), "NOT true")
	}
}
