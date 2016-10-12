import Schema
import Expression
import Foundation

// TODO: Use ResultString
//
// We need to use something like:
// enum ResultString { case value, error(String) }

/// Complier of expressions into strings within context of a SQL dialect.
public class ExpressionCompiler: ExpressionVisitor {
	public typealias VisitorResult = String

	let dialect: Dialect

	/// Creates an expression compiler for `dialect`. If `dialect` is not
	/// specified, then default dialect is used.
	init(dialect: Dialect?=nil){
		self.dialect = dialect ?? DefaultDialect()
	}

	public func visitNull() -> VisitorResult {
		return "NULL"
	}

	public func visit(integer value: Int) -> VisitorResult {
		return String(value)
	}

	public func visit(string value: String) -> VisitorResult {
		let quoted: String
		// TODO: Special characters, newlines, ...
		quoted = value.replacingOccurrences(of:"'", with:"''")
		return "'\(quoted)'"
	}

	public func visit(bool value: Bool) -> VisitorResult {
		switch value {
		case true: return "true"
		case false: return "false"
		}
	}

	public func visit(binary op: String, _ left: Expression,_ right: Expression) -> VisitorResult {
		let ls = visit(expression: left)
		let rs = visit(expression: right)

		if let opstr = DefaultBinaryOperators[op] {
			return "\(ls) \(opstr) \(rs)"
		}
		else {
			return "ERROR: Unknown binary operator '\(op)'"
		}

	}

	public func visit(unary op: String, _ arg: Expression) -> VisitorResult {
		let vs = visit(expression: arg)
		if let opstr = DefaultUnaryOperators[op] {
			return "\(opstr) \(vs)"
		}
		else {
			return "ERROR: Unknown unary operator '\(op)'"
		}
	}

	public func visit(function: String, _ args: [Expression]) -> VisitorResult {
		let argstrings = args.map {
			arg in visit(expression: arg)
		}

		let argstring = argstrings.joined(separator: ", ")
		return "\(function)(\(argstring))"
	}

	public func visit(column: String, inTable table: Table) -> VisitorResult {
		// TODO: identifier formatter
		return "\(table.name).\(column)"
	}

	public func visit(column: String, inRelation relation: Relation) -> VisitorResult {
		// TODO: identifier formatter
		// TODO: What about multiple unnamed tables?
		return "\(relation.name).\(column)"
	}

	public func visit(parameter: String) -> VisitorResult {
		return "BINDUNSUPPORTED"
	}
}

