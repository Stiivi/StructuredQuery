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

public indirect enum Expression: Hashable, ExpressionConvertible {
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
    case attribute(AttributeReference)

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
        case let .attribute(ref): return ref.name
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

    /// Return all attribute references used in the expression tree
    ///
    /// All occurences are returned as they are observed during the children
    /// tree traversal.
    public var attributeReferences: [AttributeReference] {
        // TODO: Use this flatMap (does not compile)
        /*
        let refs: [AttributeReference] = children.flatMap {
            child in
            let out: [AttributeReference]
            switch child {
            case .attribute(let attr): out = [attr]
            default: out = child.attributeReferences
            }
            return out
        }*/
        var refs = [AttributeReference]()
        children.forEach {
            child in
            switch child {
            case .attribute(let attr): refs.append(attr)
            default: refs += child.attributeReferences
            }
        }
        return refs
    }

    // TODO: Do we still need this?
    public var toExpression: Expression {
        return self
    }

    /// List of children from which the expression is composed. Does not go
    /// to underlying table expressions.
    public var hashValue: Int {
        switch self {
        case .null: return 0
        case let .bool(value): return value.hashValue
        case let .integer(value): return value.hashValue
        case let .string(value): return value.hashValue
        case let .attribute(value): return value.hashValue
        case let .parameter(value): return value.hashValue
        case let .binary(op, lhs, rhs):
                return op.hashValue ^ lhs.hashValue ^ rhs.hashValue
        case let .unary(op, expr): return op.hashValue ^ expr.hashValue
        case let .function(f, exprs):
                return exprs.reduce(f.hashValue) {
                    acc, elem in acc ^ elem.hashValue
                }
        case let .alias(expr, name): return expr.hashValue ^ name.hashValue
        case .error(_): return 0
        }
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
    case let(.attribute(lval), .attribute(rval)) where lval == rval: return true
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

