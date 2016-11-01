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
    public typealias VisitorResult = ResultString<CompilerError>

    public func visitNull() -> VisitorResult {
        return "NULL"
    }

    public func visit(integer value: Int) -> VisitorResult {
        return .value(String(value))
    }

    public func visit(string value: String) -> VisitorResult {
        let quoted: String
        // TODO: Special characters, newlines, ...
        quoted = value.replacingOccurrences(of:"'", with:"''")
        return .value("'\(quoted)'")
    }

    public func visit(bool value: Bool) -> VisitorResult {
        switch value {
        case true: return "true"
        case false: return "false"
        }
    }

    public func visit(binary op: String, _ left: Expression,_ right: Expression) -> VisitorResult {

        guard let opinfo = dialect.binaryOperator(op) else {
            return .failure([.unknownBinaryOperator(op)])
        }

        let ls = visit(expression: left)
        let rs = visit(expression: right)
        let wrap: Bool
        
        if case .binary(let otherop, _, _) = left {
            guard let otherinfo = dialect.binaryOperator(otherop) else {
                return .failure([.unknownBinaryOperator(op)])
            }
            wrap = opinfo.precedence > otherinfo.precedence
        }
        else {
            wrap = false
        }

        var out: VisitorResult

        out = ls.wrap(left: "(", right: ")", when: wrap)
        out += " " + opinfo.string + " " + rs

        return out
    }

    public func visit(unary op: String, _ arg: Expression) -> VisitorResult {
        guard let opinfo = dialect.unaryOperator(op) else {
            return .failure([.unknownUnaryOperator(op)])
        }
        let operand = visit(expression: arg)

        return .value("\(opinfo.string) ") + operand
    }

    public func visit(function: String, _ args: [Expression]) -> VisitorResult {
        let argstrings = args.map {
            arg in visit(expression: arg)
        }

        let argstring = concatenate(argstrings, separator: ", ")
        return .value("\(function)(\(argstring))")
    }

    public func visit(column: String, inTable table: Table) -> VisitorResult {
        // TODO: identifier formatter
        return .value("\(table.name).\(column)")
    }

    public func visit(columnReference reference: ColumnReference) -> VisitorResult {
        // TODO: identifier formatter
        // TODO: What about multiple unnamed tables?
        var out: VisitorResult
        if let relationName = reference.tableExpression.name {
            out = .value("\(relationName).")
        }
        else {
            out = ""
        }
        out += reference.name

        return out
    }

    public func visit(alias: String, forExpression: Expression) -> VisitorResult {
        let result = visit(expression: forExpression)
        return result + " AS \(alias)"
    }

    public func visit(parameter: String) -> VisitorResult {
        preconditionFailure("Parameters not implemented")
    }
    public func visit(error: ExpressionError) -> VisitorResult {
        return .failure([.expression(error)])
    }
}

extension Compiler: TableExpressionVisitor {
    public typealias TableExpressionResult = ResultString<CompilerError>

    public func visit(table: Table) -> TableExpressionResult {
        // TODO: User formatter and schema
        return .value(table.name)
    }

    public func visit(alias: Alias) -> TableExpressionResult {
        let aliased = visit(tableExpression: alias.aliased.toTableExpression)

        return aliased + " AS \(alias.name)"
    }

    public func visit(select: Select) -> TableExpressionResult {
        var out: TableExpressionResult
        let selectList = select.selectList.map { visit(expression: $0) }
        let selectListResult = concatenate(selectList, separator: ", ")

        out = "SELECT " + selectListResult

        if !select.fromExpressions.isEmpty {
            let froms = select.fromExpressions.map { visit(tableExpression: $0) }
            let fromsResult = concatenate(froms, separator: ", ")
            out += " FROM " + fromsResult
        }

        return out
    }

    public func visit(tableExpressionError error: TableExpressionError) -> TableExpressionResult {
        return .failure([.tableExpression(error)])
    }

}
