import XCTest

@testable import Expression
@testable import Schema
@testable import Types

// TODO: Base Tables!!!

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

class ProjectionTestCase: XCTestCase {
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
}

class AliasTestCase: XCTestCase {
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
}
class JoinTestCase: XCTestCase {

    // Join
    // ----
    func testJoin() {
        let joined: Relation
        let left = events.alias(as: "left")
        let right = events.alias(as: "right")

        joined = left.join(right)

        XCTAssertEqual(joined.attributes, [
            AttributeReference(index:.concrete(0), name: "id", relation: left),
            AttributeReference(index:.concrete(1), name: "name", relation: left),
            AttributeReference(index:.concrete(2), name: "value", relation: left),
            AttributeReference(index:.concrete(0), name: "id", relation: right),
            AttributeReference(index:.concrete(1), name: "name", relation: right),
            AttributeReference(index:.concrete(2), name: "value", relation: right)
        ])
    }
}

class RelationTestCase: XCTestCase {
    // Attribute Reference Errors
    // --------------------------
    func testAmbiguousReference() {
        var p: Relation

        p = events.project([events["id"], events["id"]])
        XCTAssertEqual(p.attributes, [
            AttributeReference(index:.ambiguous, name: "id", relation: p),
            AttributeReference(index:.ambiguous, name: "id", relation: p)
        ])

        p = events.project([events["name"].label(as: "other"),
                            events["value"].label(as: "other")])
        XCTAssertEqual(p.attributes, [
            AttributeReference(index:.ambiguous, name: "other", relation: p),
            AttributeReference(index:.ambiguous, name: "other", relation: p)
        ])
    }

    // Errors
    // ------

    // Select column from nothing
    // SELECT id
    // SELECT events.id FROM contacts
    func testInvalidColumn() {
        let p = Projection([events["id"]])
    }


    func assertEqual(_ lhs: [Relation], _ rhs: [Relation], file: StaticString = #file, line: UInt = #line) {
        if lhs.count != rhs.count
                || zip(lhs, rhs).first(where: { l, r in l != r }) != nil {
            XCTFail("Relation lists are not equal: left: \(lhs) right: \(rhs)",
                    file: file, line: line)    
        }
    }

    // Children and bases
    //
    func testChildren() {
        let a = Table("a", Column("id", INTEGER))
        let b = Table("b", Column("id", INTEGER))
        let c = Table("c", Column("id", INTEGER))
        var rel: Relation
        var x: Relation

        // SELECT * FROM a
        //      C: a
        //      B: a
        rel = a.project()
        assertEqual(rel.immediateRelations, [a])
        assertEqual(rel.baseRelations, [a])
        //
        // SELECT * FROM a JOIN b
        //      C: a, b
        //      B: a, b

        rel = a.join(b)
        assertEqual(rel.immediateRelations, [a, b])
        assertEqual(rel.baseRelations, [a, b])

        rel = a.join(b).project()
        assertEqual(rel.immediateRelations, [a, b])
        assertEqual(rel.baseRelations, [a, b])

        // SELECT * FROM a AS x
        //
        x = a.alias(as: "x")
        rel = x.project()
        assertEqual(rel.immediateRelations, [x])
        assertEqual(rel.baseRelations, [a])

        // SELECT * FROM (SELECT * FROM a) AS x)
        x = a.project().alias(as: "x")
        rel = a.join(b).project()
        assertEqual(rel.immediateRelations, [a, b])
        assertEqual(rel.baseRelations, [a, b])

        //
        // SELECT * FROM (SELECT * FROM a JOIN b) x
        //      C: x
        //      B: a, b

        x = a.join(b).alias(as: "x")
        rel = x.project()
        assertEqual(rel.immediateRelations, [x])
        assertEqual(rel.baseRelations, [a, b])

        //
        // SELECT * FROM a JOIN b JOIN c
        //      C: a, b, c
        //      B: a, b, c
        rel = a.join(b).join(c)
        assertEqual(rel.immediateRelations, [a, b, c])
        assertEqual(rel.baseRelations, [a, b, c])

        //
        // SELECT * FROM a JOIN b JOIN c AS x
        //      C: a, b, x
        //      B: a, b, c
        x = c.alias(as: "x")
        rel = a.join(b).join(x)
        assertEqual(rel.immediateRelations, [a, b, x])
        assertEqual(rel.baseRelations, [a, b, c])

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
