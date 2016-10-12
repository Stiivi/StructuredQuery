import XCTest

@testable import Expression

// TODO: name for alias, tableColumn, tablelikeColumn

class ExpressionTestCase: XCTestCase {

	func testNullLiteral(){
		let e: Expression
		e = nil
		XCTAssertEqual(e, Expression.null)
	}

	func testStringLiteral(){
		let e: Expression
		e = "text"
		XCTAssertEqual(e, Expression.string("text"))
	}

	func testIntLiteral(){
		let e: Expression
		e = 1024
		XCTAssertEqual(e, Expression.integer(1024))
	}

	func testBoolLiteral(){
		let e: Expression
		e = true
		XCTAssertEqual(e, Expression.bool(true))
	}

	func testBinaryOperator(){
		let a: Expression = 1
		let b: Expression = 2
		var e: Expression

		e = a + b

		if case .binary = e {
		}
		else {
			XCTFail("Expression is not a binary expression")
		}

		e = a == b

		if case .binary = e {
		}
		else {
			XCTFail("Expression is not a binary expression")
		}
	}
}
