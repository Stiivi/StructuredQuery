import Basic
import Schema

public typealias ColumnExpressionList = PropertyLookupArray<Expression,String>

public protocol ColumnExpressionListable {
	var columnExpressions: ColumnExpressionList { get }
}

public protocol Relation: ColumnExpressionListable {
	var name: String { get }
	var schema: String? { get }
}

extension Table: Relation {
	public var columnExpressions: ColumnExpressionList {
		// TODO: ColumnExpressionList
		let expressions:[Expression] = columnDescriptions.map {
			.tableColumn($0.name, self)
		}

		return ColumnExpressionList(expressions) { $0.name }
	}
}

