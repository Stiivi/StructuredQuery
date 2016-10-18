import Basic
import Schema


/// Wrapper for Selectables to allow static case-checking.
public enum TableExpression: Hashable {
	case table(Table)
	case alias(Alias)
	case select(Select)
	// case join(Join)	
	case error(TableExpressionError)

	public var isError: Bool {
		switch self {
		case .error(_): return true
		default: return false
		}
	}
	
	public var hashValue: Int {
		switch self {
		case let .table(t): return t.hashValue
		case let .alias(t): return t.name.hashValue
		case let .select(t): return t.selectList.count
		case let .error(error): return error.description.hashValue
		}
	}
}

public func ==(lhs: TableExpression, rhs: TableExpression) -> Bool {
	switch (lhs, rhs) {
	case let (.table(left), .table(right)) where left == right:
		return true
	case let (.alias(left), .alias(right)) where left == right:
		return true
	case let (.select(left), .select(right)) where left == right:
		return true
	case let (.error(left), .error(right)) where left == right:
		return true
	default:
		return false
	}
}


public protocol TableExpressionVisitor {
	associatedtype TableExpressionResult
	func visit(tableExpression: TableExpression) -> TableExpressionResult
	func visit(table: Table) -> TableExpressionResult
	func visit(alias: Alias) -> TableExpressionResult
	func visit(select: Select) -> TableExpressionResult
	func visit(tableExpressionError: TableExpressionError) -> TableExpressionResult
}

extension TableExpressionVisitor {
	public func visit(tableExpression: TableExpression) -> TableExpressionResult {
		switch tableExpression {
		case let .table(t): return visit(table: t)
		case let .alias(t): return visit(alias: t)
		case let .select(t): return visit(select: t)
		case let .error(error): return visit(tableExpressionError: error)
		}
	}
}


public protocol TableExpressionConvertible {
	var toTableExpression: TableExpression { get }
}

extension Table: TableExpressionConvertible {
	public var toTableExpression: TableExpression {
		return .table(self)
	}
}

/// Reference to a column of a table expression.
///
public struct ColumnReference: Hashable {
	/// Table expression that owns the column
	let tableExpression: TableExpression
	/// Name of the column within the table expression thath this reference
	/// refers to
	let name: String

	public init(name: String, tableExpression: TableExpression) {
		self.name = name
		self.tableExpression = tableExpression
	}

	public var hashValue: Int {
		return name.hashValue ^ tableExpression.hashValue
	}
}

public func ==(lhs: ColumnReference, rhs: ColumnReference) -> Bool {
	return lhs.name == rhs.name && lhs.tableExpression == rhs.tableExpression
}

extension ColumnReference: ExpressionConvertible {
	public var toExpression: Expression { return .columnReference(self) }
}

