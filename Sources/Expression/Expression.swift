import Basic
import Schema


public protocol ExpressionConvertible {
    var toExpression: Expression { get }

    func label(as alias: String) -> Expression
}

extension ExpressionConvertible {
    public func label(as alias: String) -> Expression {
        return .alias(toExpression, alias)
    }
}


/// SQL Expression.
///
/// Core data type that represents multiple types of a SQL expression nodes:
/// literals, NULL, binary and unary operators, function calls, etc.

public indirect enum Expression: Equatable, ExpressionConvertible {
    // Literals
    /// `NULL` literal
    case null
    /// Integer number literal
    case integer(Int)
    /// String or text literal
    case string(String)
    /// Boolean literal
    case bool(Bool)

    /// Binary operator
    case binary(String, Expression, Expression)
    /// Unary operator
    case unary(String, Expression)

    /// Function with multiple expressions as arguments
    case function(String, [Expression])

    // Bind parameter
    case parameter(String)

    /// Expression with a name. Any expression can be given a name with
    /// `Expression.alias(as: name)`.
    ///
    /// - See: Expression.alias(as:)
    case alias(Expression, String)

    /// Reference to an attribute of any relation
    ///
    /// - See: AttributeReference
    case attributeReference(AttributeReference)

    /// Reference to physical table column
    ///
    case tableColumn(String, Table)

    /// Represents an errorneous expression – an expression that was not
    /// possible to determine. For example a column was missing.
    ///
    /// - See: ExpressionError
    ///
    case error(ExpressionError)

    // TODO: case, cast, extract

    /// Has value of `true` if the expression is an error, otherwise `false`.
    public var isError: Bool {
        switch self {
        case .error: return true
        default: return false
        }
    }

    /// List of all errors in the expression tree
    public var allErrors: [ExpressionError] {
        switch self {
        case let .error(error): return [error]
        default: return Array(children.map { $0.allErrors }.joined())
        }
    }

    public var alias: String? {
        switch self {
        case let .alias(_, name): return name
        case let .tableColumn(name, _): return name
        case let .attributeReference(ref): return ref.name
        default: return nil
        }
    }

    /// List of children from which the expression is composed. Does not go
    /// to underlying table expressions.
    public var children: [Expression] {
        switch self {
        case let .binary(_, lhs, rhs): return [lhs, rhs]
        case let .unary(_, expr): return [expr]
        case let .function(_, exprs): return exprs
        case let .alias(expr, _): return [expr]
        default: return []
        }
    }

    public var toExpression: Expression {
        return self
    }
}

public func ==(left: Expression, right: Expression) -> Bool {
    switch (left, right) {
    case (.null, .null): return true
    case let(.integer(lval), .integer(rval)) where lval == rval: return true
    case let(.string(lval), .string(rval)) where lval == rval: return true
    case let(.bool(lval), .bool(rval)) where lval == rval: return true
    case let(.binary(lop, lv1, lv2), .binary(rop, rv1, rv2))
                where lop == rop && lv1 == rv1 && lv2 == rv2: return true
    case let(.unary(lop, lv), .unary(rop, rv))
                where lop == rop && lv == rv: return true
    case let(.alias(lval), .alias(rval)) where lval == rval: return true
    case let(.function(lname, largs), .function(rname, rargs))
                where lname == rname && largs == rargs: return true
    case let(.parameter(lval), .parameter(rval)) where lval == rval: return true
    case let(.tableColumn(ln, lr), .tableColumn(rn, rr)) where ln == rn && lr == rr: return true
    case let(.attributeReference(lval), .attributeReference(rval)) where lval == rval: return true
    case let(.error(lval), .error(rval)) where lval == rval: return true
            
    default: return false
    }
}

extension Expression: ExpressibleByStringLiteral {
    public init(stringLiteral value: String.StringLiteralType) {
        self = .string(value)
    }
    public init(extendedGraphemeClusterLiteral value:
            String.ExtendedGraphemeClusterLiteralType){
        self = .string(value)
    }
    public init(unicodeScalarLiteral value: String.UnicodeScalarLiteralType) {
        self = .string(value)
    }
}

extension String: ExpressionConvertible {
    public var toExpression: Expression { return .string(self) }
}

extension Expression: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int.IntegerLiteralType) {
        self = .integer(value)
    }
}

extension Int: ExpressionConvertible {
    public var toExpression: Expression { return .integer(self) }
}

extension Expression: ExpressibleByBooleanLiteral {
    public init(booleanLiteral value: Bool.BooleanLiteralType){
        self = .bool(value)
    }
}

extension Bool: ExpressionConvertible {
    public var toExpression: Expression { return .bool(self) }
}

extension Expression: ExpressibleByNilLiteral {
    public init(nilLiteral: ()) {
        self = .null
    }
}

