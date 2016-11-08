import XCTest

@testable import Schema
@testable import Types
@testable import Expression
@testable import Compiler

class RelationCompilerTestCase: XCTestCase {
    let data = Table("data", 
        Column("i", INTEGER),
        Column("t", TEXT),
        Column("b", BOOLEAN)
    )
    let events = Table("events", 
        Column("id", INTEGER),
        Column("name", TEXT),
        Column("value", INTEGER)
    )
    let contacts = Table("contacts", 
        Column("id", INTEGER),
        Column("address", TEXT),
        Column("city", TEXT),
        Column("country", TEXT)
    )

    func compile(_ relation: Relation) -> String {
        let compiler = Compiler()
        let result = compiler.visit(relation: relation)
        switch result {
        case .value(let str): return str
        case .failure(let _): return "ERROR"
        }
    }

    func testVisitSimple() {
        let stmt = Projection([1])
        XCTAssertEqual(compile(stmt), "SELECT 1")
    }

    func testVisitExpression() {
        let expr: Expression = 10
        let stmt = Projection([expr + 20 ])
        XCTAssertEqual(compile(stmt), "SELECT 10 + 20")
    }
    func testVisitExpressionWithAlias() {
        let expr: Expression = 10
        let stmt = Projection([expr.label(as:"x")])
        XCTAssertEqual(compile(stmt), "SELECT 10 AS x")
    }

    func testVisitMultipleSelect() {
        let exprs: [Expression] = [10, 20, "thirty"]
        let stmt = Projection(exprs)
        XCTAssertEqual(compile(stmt), "SELECT 10, 20, 'thirty'")
    }

    func testVisitSimpleFromSelect() {
        let stmt = data.project([data["i"], data["b"]])
        XCTAssertEqual(compile(stmt), "SELECT i, b FROM data")
    }
    // SELECT i,b, events.name, contacts.id FROM data

}

