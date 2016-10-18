import XCTest

@testable import Expression
@testable import Schema
@testable import Types

// TODO: Base Tables!!!

class SelectTestCase: XCTestCase {
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

	func testSelectFromNothing(){
		var select: Select = Select([1])

		XCTAssertEqual(select.selectList.count, 1)
		XCTAssertEqual(select.fromExpressions, [])
		// XCTAssertEqual(select.baseTables, [])

		let expr = Expression.integer(1).label(as: "scalar")

		select = Select([expr])

		XCTAssertEqual(select.selectList.count, 1)
		XCTAssertEqual(select.selectList.keys, ["scalar"])
		XCTAssertEqual(select.fromExpressions, [])
		// XCTAssertEqual(select.baseTables, [])
	}
	// Table
	// -----
	func testSelectAllFromOneTable() {
		let select: Select
		let select2: Select

		select = Select(events.columns, from: events) 
		XCTAssertEqual(select.selectList.keys, ["id", "name", "value"])
		XCTAssertEqual(select.fromExpressions, [events.toTableExpression])
		// XCTAssertEqual(select.baseTables, [events])

		select2 = events.select() 
		XCTAssertEqual(select2.selectList.keys, ["id", "name", "value"])
		XCTAssertEqual(select, select2)
	}
	func testSelectSomethingFromTable() {
		let select: Select

		let list: [ExpressionConvertible] = [events["id"], events["name"]]

		select = Select(list, from: events)
		XCTAssertEqual(select.selectList.keys, ["id", "name"])
		// XCTAssertEqual(select.baseTables, [events])
	}

	// Alias
	// -----
	func testSelectFromAlias() {
		let select: Selectable
		let alias: Selectable

		select = events.select()
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
