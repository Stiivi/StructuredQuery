import XCTest

@testable import Expression
@testable import Compiler

class ExpressionCompilerTestCase: XCTestCase {
	func compile(_ expression: Expression) -> String {
		let compiler = Compiler()
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

class TableExpressionCompilerTestCase: XCTestCase {
	func compile(_ selectable: Selectable) -> String {
		let compiler = Compiler()
		return compiler.visit(tableExpression: selectable.toTableExpression)
	}

	func testVisitSimple() {
		let stmt = Select([1])
		XCTAssertEqual(compile(stmt), "SELECT 1")
	}

	func testVisitExpression() {
		let expr: Expression = 10
		let stmt = Select([expr + 20 ])
		XCTAssertEqual(compile(stmt), "SELECT 10 + 20")
	}
	func testVisitExpressionWithAlias() {
		let expr: Expression = 10
		let stmt = Select([expr.label(as:"x")])
		XCTAssertEqual(compile(stmt), "SELECT 10 AS x")
	}
}

