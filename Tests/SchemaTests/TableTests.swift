import XCTest

@testable import Schema
@testable import Types

class TableTestCase: XCTestCase {
	func testColumns() {
		let table = Table("events",
			Column("id", INTEGER),
			Column("name", TEXT),
			Column("value", INTEGER)
		)

		XCTAssertEqual(table.columnDefinitions.count, 3)

		let columns = table.columnDefinitions

		XCTAssertEqual(columns[1].name, "name")
		XCTAssertEqual(columns["name"]!.name, "name")
		XCTAssertEqual(columns[2].name, "value")
		XCTAssertEqual(columns["value"]!.name, "value")
	}
	func testDuplicateColumns() {
		let table = Table("events",
			Column("id", INTEGER),
			Column("name", TEXT),
			Column("name", TEXT),
			Column("value", INTEGER),
			Column("other", INTEGER),
			Column("other", TEXT)
		)

		let columns = table.columnDefinitions
		XCTAssertEqual(columns.count, 6)
		XCTAssertEqual(columns.ambiguous.count, 2)
		XCTAssertEqual(columns.ambiguous, ["name", "other"])

		// Should not be TEXT
		XCTAssertEqual(columns["other"]!.type, INTEGER)
	}
}
