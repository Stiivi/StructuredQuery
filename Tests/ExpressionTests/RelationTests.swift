import XCTest

@testable import Expression
@testable import Schema
@testable import Types

// TODO: Base Tables!!!

class ProjectionTestCase: XCTestCase {
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

    func testProjectionFromNothing(){
        //
        // SELECT 1
        //
        var rel: Projection = Projection([1])

        // Basic sanity check
        XCTAssertEqual(rel.selectList.count, 1)
        XCTAssertTrue(rel.relation == nil)

        // Relation Conformance
        XCTAssertEqual(rel.attributeExpressions, rel.selectList)
        XCTAssertEqual(rel.attributes, [
            AttributeReference(index:.concrete(0), name: nil, relation: rel)
        ])

        //
        // SELECT 1 as scalar
        //
        let expr = Expression.integer(1).label(as: "scalar")

        rel = Projection([expr])

        XCTAssertTrue(rel.relation == nil)
        XCTAssertEqual(rel.attributes, [
            AttributeReference(index:.concrete(0), name: "scalar", relation: rel)
        ])
        // XCTAssertEqual(select.baseTables, [])
    }
    // TODO: Ambiguous column
    // Table
    // -----
    func testSelectAllFromOneTable() {
        //
        // SELECT id, name, value FROM events
        //
        let p1: Projection
        let p2: Projection

        p1 = Projection(events.attributes, from: events) 
        XCTAssertEqual(p1.attributes, [
            AttributeReference(index:.concrete(0), name: "id", relation: p1),
            AttributeReference(index:.concrete(1), name: "name", relation: p1),
            AttributeReference(index:.concrete(2), name: "value", relation: p1)
        ])

        // XCTAssertEqual(select.baseTables, [events])

        //
        // SELECT id, name, value FROM (SELECT id, name, value FROM events)
        //
        p2 = events.project() 
        XCTAssertEqual(p2.attributes, [
            AttributeReference(index:.concrete(0), name: "id", relation: p2),
            AttributeReference(index:.concrete(1), name: "name", relation: p2),
            AttributeReference(index:.concrete(2), name: "value", relation: p2)
        ])
        XCTAssertEqual(p1, p2)
    }
    func testSelectSomethingFromTable() {
        //
        // SELECT id, name FROM events
        //
        let p: Projection
        let list: [ExpressionConvertible] = [events["name"], events["id"]]

        p = Projection(list, from: events)
        XCTAssertEqual(p.attributes, [
            AttributeReference(index:.concrete(0), name: "name", relation: p),
            AttributeReference(index:.concrete(1), name: "id", relation: p)
        ])
    }

    // Alias
    // -----
    func testSelectFromAlias() {
        let p: Relation
        let alias: Relation

        p = events.project()
        alias = p.alias(as:"renamed")

        XCTAssertEqual(alias.attributes, [
            AttributeReference(index:.concrete(0), name: "id", relation: alias),
            AttributeReference(index:.concrete(1), name: "name", relation: alias),
            AttributeReference(index:.concrete(2), name: "value", relation: alias)
        ])

    }
/*
    func testSelectAliasColumns() {
        let list = [
            events["name"].label(as:"type"),
            (events["value"] * 100).label(as: "greater_value"),
        ]

        let p = events.select(list)
        XCTAssertEqual(alias.attributes, [
            AttributeReference(index:.concrete(0), name: "type", relation: p),
            AttributeReference(index:.concrete(1), name: "greater_value", relation: p),
        ])
    }
*/
    // TODO: SELECT x.? FROM y
}
