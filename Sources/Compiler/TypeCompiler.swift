import Types
import Schema
import Expression

/// Expression compiler that returns expression's data type.
public class TypeCompiler: ExpressionVisitor {
	public typealias VisitorResult = DataType

	let dialect: Dialect

	/// Creates a type compiler for `dialect`. If dialect is not specified then
	/// `DefaultDialect` is used.
	init(dialect: Dialect?=nil) {
		self.dialect = dialect ?? DefaultDialect()
	}

	public func visitNull() -> VisitorResult {
		return DataType.NULL	
	}

	public func visit(integer value: Int) -> VisitorResult {
		return INTEGER
	}

	public func visit(string value: String) -> VisitorResult {
		return TEXT
	}

	public func visit(bool value: Bool) -> VisitorResult {
		return BOOLEAN
	}

	public func visit(binary op: String, _ left: Expression,_ right: Expression) -> VisitorResult {
		let leftType = self.visit(expression: left)
		let rightType = self.visit(expression: right)
		let signatures: [FunctionSignature] = dialect.signatures(forBinary: op)

		let match = signatures.first {
			signature in signature.matches(arguments: [leftType, rightType])
		}

		return match.map { $0.returnType }
				?? ErrorDataType(message: "Unable to match binary operator '\(op)'")
	}

	public func visit(unary op: String, _ arg: Expression) -> VisitorResult {
		let argType = self.visit(expression: arg)
		let signatures = dialect.signatures(forUnary: op)

		let match = signatures.first {
			signature in signature.matches(arguments: [argType])
		}

		return match.map { $0.returnType }
				?? ErrorDataType(message: "Unable to match unary operator '\(op)'")
	}

	public func visit(function: String, _ args: [Expression]) -> VisitorResult {
		let types = args.map { visit(expression: $0) }
		let signatures = dialect.signatures(forFunction: function)

		let match = signatures.first {
			signature in signature.matches(arguments: types)
		}

		return match.map { $0.returnType }
				?? ErrorDataType(message: "Unable to match function '\(function)'")
	}

	public func visit(column name: String, inTable table: Table) -> VisitorResult {
		let columns = table.columnDescriptions
		if columns.duplicateKeys.contains(name) {
			// TODO: Add table name to the error
			return ErrorDataType(message: "Duplicate column '\(name)'")
		}
		else if let column = columns[name] {
			return column.type
		}
		else {
			// TODO: Add table name to the error
			return ErrorDataType(message: "Unknown column \(name)")
		}
	}

	public func visit(column name: String,inTablelike tablelike: Tablelike) -> VisitorResult {
		// 
		let expressions = tablelike.columnExpressions
		if expressions.duplicateKeys.contains(name) {
			// TODO: Add table name to the error
			return ErrorDataType(message: "Duplicate column expression '\(name)'")
		}
		else if let expression = expressions[name] {
			return visit(expression: expression)
		}
		else {
			// TODO: Add table name to the error
			return ErrorDataType(message: "Unknown column \(name)")
		}
	}

	public func visit(parameter: String) -> VisitorResult {
	    return ErrorDataType(message: "Type compilation of parameters is not implemented")
	}

}

