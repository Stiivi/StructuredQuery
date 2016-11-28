import XCTest

@testable import Expression
@testable import Schema
@testable import Types

// TODO: Base Tables!!!

let events = Relation.table(Table("events", 
    Column("id", INTEGER),
    Column("name", TEXT),
    Column("value", INTEGER)
))

let contacts = Relation.table(Table("contacts", 
    Column("id", INTEGER),
    Column("address", TEXT),
    Column("city", TEXT),
    Column("country", TEXT)
))

let a = Relation.table(Table("a", Column("id", INTEGER)))
let b = Relation.table(Table("b", Column("id", INTEGER)))
let c = Relation.table(Table("c", Column("id", INTEGER)))


class ProjectionTestCase: XCTestCase {
    func testProjectionFromNothing(){
        //
        // SELECT 1
        //
        let list: [Expression] = [1]
        var rel: Relation = Relation.projection(list, .none)

        // Relation Conformance
        XCTAssertEqual(rel.projectedExpressions, list)
        XCTAssertEqual(rel.attributeReferences, [
            AttributeReference(index:.concrete(0), name: nil, relation: rel)
        ])

        //
        // SELECT 1 as scalar
        //
        let expr = Expression.integer(1).label(as: "scalar")

        rel = Relation.projection([expr], .none)

        XCTAssertEqual(rel.attributeReferences, [
            AttributeReference(index:.concrete(0), name: "scalar", relation: rel)
        ])
    }
    // Table
    // -----
    func testSelectAllFromOneTable() {
        //
        // SELECT id, name, value FROM events
        //
        let p1: Relation
        let p2: Relation
        let exprs = events.projectedExpressions

        p1 = .projection(exprs, events.relation) 

        XCTAssertEqual(p1.attributeReferences, [
            AttributeReference(index:.concrete(0), name: "id", relation: p1),
            AttributeReference(index:.concrete(1), name: "name", relation: p1),
            AttributeReference(index:.concrete(2), name: "value", relation: p1)
        ])

        // XCTAssertEqual(select.baseTables, [events])

        //
        // SELECT id, name, value FROM (SELECT id, name, value FROM events)
        //
        p2 = events.project() 
        XCTAssertEqual(p2.attributeReferences, [
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
        let p: Relation
        let list: [Expression] = [events["name"], events["id"]]

        p = .projection(list, events.relation)
        XCTAssertEqual(p.attributeReferences, [
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

        XCTAssertEqual(alias.attributeReferences, [
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

        XCTAssertEqual(joined.attributeReferences, [
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
        XCTAssertEqual(p.attributeReferences, [
            AttributeReference(index:.ambiguous, name: "id", relation: p),
            AttributeReference(index:.ambiguous, name: "id", relation: p)
        ])

        p = events.project([events["name"].label(as: "other"),
                            events["value"].label(as: "other")])
        XCTAssertEqual(p.attributeReferences, [
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
        // let p = Relation.projection([events["id"]], Relation.none)
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

    func testInvalidRelationReference() {
        // SELECT a.id FROM b
        var rel: Relation

        rel = b.project([a["id"]])
        if rel.error == nil {
            XCTFail("Invalid reference should cause an error: \(rel)")
        }
        
    }
    // TODO: SELECT x.? FROM y
}
