import XCTest

@testable import Expression
@testable import Compiler

class ExpressionCompilerTestCase: XCTestCase {

    func compile(_ expression: Expression) -> String {
        let compiler = Compiler()
        let result = compiler.visit(expression: expression)

        switch result {
        case .value(let str): return str
        case .failure(_): return "ERROR"
        }
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

    func testPriority() {
        let a: Expression = 10  
        let b: Expression = 20  
        let c: Expression = 30

        var e: Expression

        e = a * b + c
        XCTAssertEqual(compile(e), "10 * 20 + 30")

        e = a + b * c
        XCTAssertEqual(compile(e), "10 + 20 * 30")

        e = (a + b) * c
        XCTAssertEqual(compile(e), "(10 + 20) * 30")

        e = a * a + b * b
        XCTAssertEqual(compile(e), "10 * 10 + 20 * 20")
    }
}

