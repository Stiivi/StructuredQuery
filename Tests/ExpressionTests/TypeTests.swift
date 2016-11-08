import XCTest

@testable import Types

class DataTypeTestCase: XCTestCase {

    func testNullType(){
        XCTAssertTrue(DataType.NULL.isNull)
        XCTAssertFalse(INTEGER.isNull)
        XCTAssertFalse(TEXT.isNull)
    }

    func testDefaultFullyQualifiedName(){
        XCTAssertEqual(DataType.NULL.fullyQualifiedName, "default.NULL")
    }

}

class FunctionSignatureTestCase: XCTestCase {
    func testBasicMatch(){
        let sig = FunctionSignature(arguments: [INTEGER, INTEGER], returnType: INTEGER)
        XCTAssertTrue(sig.matches(arguments: [INTEGER, INTEGER]))
        XCTAssertFalse(sig.matches(arguments: [TEXT, INTEGER]))
        XCTAssertFalse(sig.matches(arguments: [INTEGER, TEXT]))
    }

    func testAnyMatch(){
        let sig = FunctionSignature(arguments: [DataType.ANY, DataType.ANY], returnType: INTEGER)
        XCTAssertTrue(sig.matches(arguments: [INTEGER, INTEGER]))
        XCTAssertTrue(sig.matches(arguments: [TEXT, INTEGER]))
        XCTAssertTrue(sig.matches(arguments: [INTEGER, TEXT]))
    }

}
