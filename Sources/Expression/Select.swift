import Basic
import Schema

public typealias ExpressionLookupList = LookupList<String, Expression>

// Add: Executable
/// The main object representing a query.
///
public final class Select: Equatable {
	let selectList: ExpressionLookupList
	let fromExpressions: [TableExpression]

	/// Creates a `Select` object which is the main object to contain full
	/// query specification.
	///
	/// - Precondition: The `selectList` must not be empty.
	///
	public init(_ selectList: [ExpressionConvertible]=[], from: Selectable?=nil) {
		precondition(selectList.count != 0)

		// If we have the select list, then we use it...
		let expressions = selectList.map { $0.toExpression }
		self.selectList = ExpressionLookupList(expressions) {
			$0.alias
		}

		if let from = from {
			fromExpressions = [from.toTableExpression]
		}
		else {
			fromExpressions = []
		}
	}
}

extension Select: Selectable {
	public var toTableExpression: TableExpression {
		return .select(self)
	}

	/// List of references to colmns of this `Select` statement.
	public var columns: [ColumnReference] {
		let tableExpression = self.toTableExpression
		let references = self.selectList.keys.map {
			ColumnReference(name: $0, tableExpression: tableExpression)
		}

		return references
	}

}


public func ==(lhs: Select, rhs: Select) -> Bool {
	return lhs.selectList == rhs.selectList
			&& lhs.fromExpressions == rhs.fromExpressions
}

