import Common

public typealias ColumnExpressionList = PropertyLookupArray<Expression,String>

public protocol ColumnExpressionListable {
	var columnExpressions: ColumnExpressionList { get }
}

public protocol Tablelike: ColumnExpressionListable {
	var name: String { get }
	var schema: String? { get }
}
