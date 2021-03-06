import XCTest

@testable import Types
@testable import Relation
@testable import Compiler

class TypeInspectorTestCase: XCTestCase {
    func compile(_ expression: Expression) -> DataType {
        let inspector = TypeInspector()
        return inspector.visit(expression: expression)
    }

    func testVisitNull() {
        XCTAssertEqual(compile(nil), DataType.NULL)
    }

    func testVisitInteger() {
        XCTAssertEqual(compile(1024), INTEGER)
    }

    func testVisitBool() {
        XCTAssertEqual(compile(true), BOOLEAN)
        XCTAssertEqual(compile(false), BOOLEAN)
    }

    // TODO: test for special characters, newlines
    func testVisitString() {
        XCTAssertEqual(compile("text"), TEXT)
    }

    func testVisitBinary() {
        let e: Expression = 1
        let b: Expression = true

        XCTAssertEqual(compile(e + 2), INTEGER)
        XCTAssertEqual(compile(b && false), BOOLEAN)
        XCTAssertEqual(compile(b || false), BOOLEAN)

        XCTAssertTrue(compile(e == 2).isError)
    }

    func testVisitUnary() {
        let e: Expression = 1
        let b: Expression = true

        XCTAssertEqual(compile(-e), INTEGER)
        XCTAssertEqual(compile(!b), BOOLEAN)
    }
}
