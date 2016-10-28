import XCTest

@testable import Expression
@testable import Schema
@testable import Types

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

    func testChilren() {
        var e: Expression
        

        e = nil
        XCTAssertEqual(e.children.count, 0)

        e = 1
        XCTAssertEqual(e.children.count, 0)

        e = "text"
        XCTAssertEqual(e.children.count, 0)

        e = Expression.integer(1) + (Expression.integer(2) + 3)

        XCTAssertEqual(e.children.count, 2)
        XCTAssertEqual(e.children[0], Expression.integer(1))
    }

    // FIXME: Enable this test
    func _testBaseTables() {
        var e: Expression

        e = nil
        // XCTAssertEqual(e.baseTables.count, 0)

        let table = Table("events", Column("id", INTEGER))
    }

}
