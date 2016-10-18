import Basic
import Schema

/// Type that visits nodes in a SQL expression and returns `VisitorResult`
public protocol ExpressionVisitor {
	associatedtype VisitorResult
	func visit(expression: Expression) -> VisitorResult

	func visitNull() -> VisitorResult
	func visit(integer value: Int) -> VisitorResult
	func visit(string value: String) -> VisitorResult
	func visit(bool value: Bool) -> VisitorResult

	func visit(binary op: String, _ left: Expression,_ right: Expression) -> VisitorResult
	func visit(unary op: String, _ arg: Expression) -> VisitorResult
	func visit(function: String, _ args: [Expression]) -> VisitorResult
	func visit(parameter: String) -> VisitorResult
	func visit(column: String, inTable: Table) -> VisitorResult
	func visit(columnReference: ColumnReference) -> VisitorResult
	func visit(error: ExpressionError) -> VisitorResult

	func visit(alias: String, forExpression: Expression) -> VisitorResult
}

/// Default implementation of the top level entry function that dispatches
/// various expression nodes into their respective visit functions.
extension ExpressionVisitor {
	public func visit(expression: Expression) -> VisitorResult {
		let out: VisitorResult

		switch expression {
		case .null:
			out = self.visitNull()
		case let .integer(value):
			out = self.visit(integer: value)
		case let .string(value):
			out = self.visit(string:value)
		case let .bool(value):
			out = self.visit(bool:value)
		case let .binary(op, left, right):
			out = self.visit(binary: op, left, right)
		case let .unary(op, arg):
			out = self.visit(unary: op, arg)
		case let .alias(expr, name):
			out = self.visit(alias: name, forExpression: expr)
		case let .function(name, args):
			out = self.visit(function: name, args)
		case let .parameter(name):
			out = self.visit(parameter: name)
		case let .tableColumn(name, table):
			out = self.visit(column: name, inTable: table)
		case let .columnReference(ref):
			out = self.visit(columnReference: ref)
		case let .error(error):
			out = self.visit(error:error)
		}

		return out
	}
	public func visit(alias: String, forExpression: Expression) -> VisitorResult {
		return visit(expression: forExpression)
	}
}

