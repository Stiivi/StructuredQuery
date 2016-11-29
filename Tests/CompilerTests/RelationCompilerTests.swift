import XCTest

@testable import Schema
@testable import Types
@testable import Relation
@testable import Compiler

class RelationCompilerTestCase: XCTestCase {
    let data = Relation.table(Table("data", 
        Column("i", INTEGER),
        Column("t", TEXT),
        Column("b", BOOLEAN))
    )
    let events = Relation.table(Table("events", 
        Column("id", INTEGER),
        Column("name", TEXT),
        Column("value", INTEGER))
    )
    let contacts = Relation.table(Table("contacts", 
        Column("id", INTEGER),
        Column("address", TEXT),
        Column("city", TEXT),
        Column("country", TEXT))
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
        let stmt = Relation.projection([1], .none)
        XCTAssertEqual(compile(stmt), "SELECT 1")
    }

    func testVisitExpression() {
        let expr: Expression = 10
        let stmt = Relation.projection([expr + 20 ], .none)
        XCTAssertEqual(compile(stmt), "SELECT 10 + 20")
    }
    func testVisitExpressionWithAlias() {
        let expr: Expression = 10
        let stmt = Relation.projection([expr.label(as:"x")], .none)
        XCTAssertEqual(compile(stmt), "SELECT 10 AS x")
    }

    func testVisitMultipleSelect() {
        let exprs: [Expression] = [10, 20, "thirty"]
        let stmt = Relation.projection(exprs, .none)
        XCTAssertEqual(compile(stmt), "SELECT 10, 20, 'thirty'")
    }

    func testVisitSimpleFromProjection() {
        let stmt = data.project([data["i"], data["b"]])
        XCTAssertEqual(compile(stmt), "SELECT data.i, data.b FROM data")
    }
    func testVisitSimpleFromAlias() {
        let other = data.alias(as: "other")
        let stmt = other.project([other["i"], other["b"]])
        XCTAssertEqual(compile(stmt),
                       "SELECT other.i, other.b FROM data AS other")
    }
    func testVisitJoin() {
        let joined = events.join(contacts).project()
        XCTAssertEqual(compile(joined),
                       "SELECT events.id, events.name, events.value, " +
                       "contacts.id, contacts.address, contacts.city, " +
                       "contacts.country " +
                       "FROM events JOIN contacts")

    }
    func testVisitJoinOn() {
        let cond: Expression = events["id"] == contacts["id"]
        let joined = events.join(contacts, on: cond).project([1])
        XCTAssertEqual(compile(joined),
                       "SELECT 1 " +
                       "FROM events JOIN contacts " +
                       "ON events.id = contacts.id")

    }

    // Test of this:
    // SELECT i,b, events.name, contacts.id FROM data
}

