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
        var rel: Projection = Projection([1])

        XCTAssertEqual(rel.selectList.count, 1)
        XCTAssertTrue(rel.relation == nil)
        // XCTAssertEqual(select.baseTables, [])

        let expr = Expression.integer(1).label(as: "scalar")

        rel = Projection([expr])

        XCTAssertEqual(rel.selectList.count, 1)
        XCTAssertEqual(rel.selectList.keys, ["scalar"])
        XCTAssertTrue(rel.relation == nil)
        // XCTAssertEqual(select.baseTables, [])
    }
    // Table
    // -----
    func testSelectAllFromOneTable() {
        let select: Projection
        let select2: Projection

        select = Projection(events.columns, from: events) 
        XCTAssertEqual(select.selectList.keys, ["id", "name", "value"])
        if let relation = select.relation {
            XCTAssertTrue(relation == events)
        }
        else {
            XCTFail("Relation is nil")
        }
        // XCTAssertEqual(select.baseTables, [events])

        select2 = events.project() 
        XCTAssertEqual(select2.selectList.keys, ["id", "name", "value"])
        XCTAssertEqual(select, select2)
    }
    func testSelectSomethingFromTable() {
        let select: Projection

        let list: [ExpressionConvertible] = [events["id"], events["name"]]

        select = Projection(list, from: events)
        XCTAssertEqual(select.selectList.keys, ["id", "name"])
        // XCTAssertEqual(select.baseTables, [events])
    }

    // Alias
    // -----
    func testSelectFromAlias() {
        let select: Relation
        let alias: Relation

        select = events.project()
        alias = select.alias(as:"renamed")

        // XCTAssertEqual(select.baseTable, alias.baseTables)
        XCTAssertEqual(select.columns.map { $0.name },
                        alias.columns.map { $0.name })

    }

    func testSelectAliasColumns() {
        let selection = [
            events["name"].label(as:"type"),
            (events["value"] * 100).label(as: "greater_value"),
        ]

        let select = events.select(selection)
        XCTAssertEqual(select.columns.map {$0.name}, ["type", "greater_value"])

    }

    // test SELECT x.? FROM y
}
