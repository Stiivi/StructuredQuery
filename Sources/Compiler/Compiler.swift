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

    public func visit(attribute reference: AttributeReference) -> VisitorResult {
        // TODO: Identifier formatter
        // TODO: Handle error
        let prefix: String

        if let error = reference.error {
            return .failure([.expression(error)])
        }

        if let qualifiedName = reference.relation.qualifiedName {
            prefix = qualifiedName.description + "."
        }
        else {
            prefix = ""
        }

        // Name is guaranteed to exist, if there is no error
        return .value(prefix + reference.name!)

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

extension Compiler: RelationVisitor {
    public typealias RelationResult = ResultString<CompilerError>

    public func visit(table: Table) -> RelationResult {
        // TODO: User formatter and schema
        return .value(table.name)
    }

    public func visit(alias: Alias) -> RelationResult {
        let aliased = visit(relation: alias.relation)

        return aliased + " AS \(alias.name)"
    }

    public func visit(projection: Projection) -> RelationResult {
        var out: RelationResult
        let selectList = projection.selectList.map { visit(expression: $0) }
        let selectListResult = concatenate(selectList, separator: ", ")

        out = "SELECT " + selectListResult

        if let relation = projection.relation {
            out += " FROM " + visit(relation: relation)
        }

        return out
    }

    public func visit(selection: Selection) -> RelationResult {
        var out: RelationResult
        let projectionResult = self.visit(relation: selection.relation)
        let predicate = self.visit(expression: selection.predicate)

        out =  projectionResult + " WHERE " + predicate

        return out
    }

    public func visit(join: Join) -> RelationResult {
        var out: RelationResult
        let joinString: RelationResult
        switch join.type {
        case .inner: joinString = "JOIN"
        case .leftOuter: joinString = "LEFT OUTER JOIN"
        case .rightOuter: joinString = "RIGHT OUTER JOIN"
        case .fullOuter: joinString = "FULL OUTER JOIN"
        }

        let left = visit(relation: join.left)
        let right = visit(relation: join.right)

        out = left + joinString.pad() + right

        if let predicate = join.predicate {
            out += " ON " + visit(expression: predicate)
        }

        return out
    }

    public func visit(unknownRelationType relation: Relation) -> RelationResult {
        let typeName = String(describing: type(of:relation))
        return .failure([.internalError("Unknown relation type: \(typeName)")])
    }

}
