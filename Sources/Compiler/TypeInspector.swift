import Basic
import Types
import Schema
import Expression

/// Expression compiler that returns expression's data type.
public class TypeInspector: ExpressionVisitor {
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
        guard let opinfo = self.dialect.binaryOperator(op) else {
            return ErrorDataType(message: "Unknown binary operator '\(op)'")
        }

        let leftType = self.visit(expression: left)
        let rightType = self.visit(expression: right)

        let match = opinfo.signatures.first {
            signature in signature.matches(arguments: [leftType, rightType])
        }

        return match.map { $0.returnType }
                ?? ErrorDataType(message: "Unable to match binary operator '\(op)'")
    }

    public func visit(unary op: String, _ arg: Expression) -> VisitorResult {
        guard let opinfo = self.dialect.unaryOperator(op) else {
            return ErrorDataType(message: "Unknown unary operator '\(op)'")
        }

        let argType = self.visit(expression: arg)

        let match = opinfo.signatures.first {
            signature in signature.matches(arguments: [argType])
        }

        return match.map { $0.returnType }
                ?? ErrorDataType(message: "Unable to match unary operator '\(op)'")
    }

    public func visit(function: String, _ args: [Expression]) -> VisitorResult {
        return ErrorDataType(message: "Visit function type not implemented")
    }

    public func visit(column name: String, inTable table: Table) -> VisitorResult {
        let columns = table.columnDefinitions
        if columns.ambiguous.contains(name) {
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

    public func visit(columnReference ref: ColumnReference) -> VisitorResult {
        // 
        /*
        let expressions = ref.tableExpression.selectable.
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
        */
        return ErrorDataType(message: "<<VISIT COLUMN REF NOT IMPLEMENTED>>")
    }

    public func visit(parameter: String) -> VisitorResult {
        return ErrorDataType(message: "Type compilation of parameters is not implemented")
    }

    public func visit(error: ExpressionError) -> VisitorResult {
        return ErrorDataType(message: "Expression error: \(error.description)")
    }

}

