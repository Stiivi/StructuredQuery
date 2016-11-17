public enum ExpressionError: Error, CustomStringConvertible, Equatable {
    /// There are more attributes with the same name
    case ambiguousAttribute(String, String)
    /// Attribute with given name does not exist
    case unknownAttribute(String, String)
    /// Attribute with given name does not exist
    case anonymousAttribute(Int, String)

    public var description: String {
        switch self {
        case let .ambiguousAttribute(name, relation):
            return "Abiguous attribute '\(name)' in '\(relation)'"
        case let .unknownAttribute(name, relation):
            return "Unknown attribute '\(name)' in '\(relation)'"
        case let .anonymousAttribute(i, relation):
            return "Anonymous attribute at index \(i) in '\(relation)'"
        }
    }
}

public func ==(lhs: ExpressionError, rhs: ExpressionError) -> Bool {
    // FIXME: Use proper comparison
    return lhs.description == rhs.description
}

public enum CompilerError: Error, CustomStringConvertible, Equatable {
    case unknownBinaryOperator(String)
    case unknownUnaryOperator(String)
    case expression(ExpressionError)
    case internalError(String)

    public var description: String {
        switch self {
        case let .unknownBinaryOperator(op): return "Unknown binary operator '\(op)'"
        case let .unknownUnaryOperator(op): return "Unknown unary operator '\(op)'"
        case let .expression(error): return "Expression error: \(error.description)"
        case let .internalError(error): return "Internal error: \(error)"
        }
    }
}

public func ==(lhs: CompilerError, rhs: CompilerError) -> Bool {
    // FIXME: Use proper comparison
    return lhs.description == rhs.description
}

