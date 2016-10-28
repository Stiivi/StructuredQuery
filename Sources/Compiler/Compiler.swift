import Basic
import Schema
import Expression
import Foundation

// TODO: Use ResultString
//
// We need to use something like:


/// Complier of expressions into strings within context of a SQL dialect.
public class Compiler {
	let dialect: Dialect

	/// Creates an expression compiler for `dialect`. If `dialect` is not
	/// specified, then default dialect is used.
	init(dialect: Dialect?=nil){
		self.dialect = dialect ?? DefaultDialect()
	}
}


extension String {
	func wrap(left: String, right: String, when: Bool) -> String {
		if when {
			return left + self + right
		}
		else {
			return self
		}
	}
}

extension Compiler: ExpressionVisitor {
	public typealias VisitorResult = String

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

		guard let opinfo = self.dialect.binaryOperator(op) else {
			return "ERROR: Unknown binary operator '\(op)'"
		}

		let ls = visit(expression: left)
		let rs = visit(expression: right)
		let wrap: Bool
		
		if case .binary(let otherop, _, _) = left {
			guard let otherinfo = self.dialect.binaryOperator(otherop) else {
				return "ERROR: Unknown binary operator '\(otherop)'"
			}
			wrap = opinfo.precedence > otherinfo.precedence
		}
		else {
			wrap = false
		}

		var out: String

		out = ls.wrap(left: "(", right: ")", when: wrap)
		out += " " + opinfo.string + " " + rs

		return out
	}

	public func visit(unary op: String, _ arg: Expression) -> VisitorResult {
		guard let opinfo = self.dialect.unaryOperator(op) else {
			return "ERROR: Unknown unary operator '\(op)'"
		}
		let vs = visit(expression: arg)

		return "\(opinfo.string) \(vs)"
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

	public func visit(columnReference: ColumnReference) -> VisitorResult {
		// TODO: identifier formatter
		// TODO: What about multiple unnamed tables?
		return "<<COLUMN REFERENCE NOT IMPLEMENTED>>"
	}

	public func visit(alias: String, forExpression: Expression) -> VisitorResult {
		let result = visit(expression: forExpression)
		return "\(result ) AS \(alias)"
	}

	public func visit(parameter: String) -> VisitorResult {
		// FIXME: emit error
		return "<<PARAMETERS NOT IMPLEMENTED>>"
	}
	public func visit(error: ExpressionError) -> VisitorResult {
		// FIXME: emit error
		return "<<EXPRESSION ERROR: \(error.description)>>"
	}
}

extension Compiler: TableExpressionVisitor {
	public typealias TableExpressionResult = String

	public func visit(table: Table) -> TableExpressionResult {
		// TODO: User formatter and schema
		return table.name
	}

	public func visit(alias: Alias) -> TableExpressionResult {
		let aliased = visit(tableExpression: alias.aliased.toTableExpression)

		return "\(aliased) AS \(alias.name)"
	}

	public func visit(select: Select) -> TableExpressionResult {
		var out: TableExpressionResult
		let selectList = select.selectList.map { visit(expression: $0) }
		let selectListResult = selectList.joined(separator: ", ")

		out = "SELECT \(selectListResult)"

		if !select.fromExpressions.isEmpty {
			let froms = select.fromExpressions.map { visit(tableExpression: $0) }
			let fromsResult = froms.joined(separator: ", ")
			out += " FROM \(fromsResult)"
		}

		return out
	}

	public func visit(tableExpressionError error: TableExpressionError) -> TableExpressionResult {
		return "<<ERROR: \(error.description)>>"
	}

}
