import Expression
import Foundation

// TODO: Use ResultString
public class ExpressionCompiler {
	public func visit(expression: Expression) -> String {
		let out: String

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
		case let .label(expr, _):
			out = self.visit(expression: expr)
		case let .function(name, args):
			out = self.visit(function: name, args)
		case let .parameter(name):
			out = self.visit(parameter: name)
		}

		return out
	}
	
	func visitNull() -> String {
		return "NULL"
	}

	func visit(integer value: Int) -> String {
		return String(value)
	}

	func visit(string value: String) -> String {
		let quoted: String
		// TODO: Special characters, newlines, ...
		quoted = value.replacingOccurrences(of:"'", with:"''")
		return "'\(quoted)'"
	}

	func visit(bool value: Bool) -> String {
		switch value {
		case true: return "true"
		case false: return "false"
		}
	}

	func visit(binary op: BinaryOperator, _ left: Expression,_ right: Expression) -> String {
		let ls = visit(expression: left)
		let rs = visit(expression: right)

		return "\(ls) \(op.description) \(rs)"
	}

	func visit(unary op: UnaryOperator, _ arg: Expression) -> String {
		let vs = visit(expression: arg)
		return "\(op.description) \(vs)"
	}

	func visit(function: String, _ args: [Expression]) -> String {
		let argstrings = args.map {
			arg in visit(expression: arg)
		}

		let argstring = argstrings.joined(separator: ", ")
		return "\(function)(\(argstring))"
	}

	func visit(parameter: String) -> String {
		return "BINDUNSUPPORTED"
	}
}

