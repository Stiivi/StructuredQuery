import Basic

/// Type that wraps a string or a list of failures. `ResultString` is used for
/// constructing a result that is composed by concatenation of multiple
/// strings. Multiple errors might occur during the concatenation and they
/// gathered in the failure case of the object.
/// 
public enum ResultString<ErrorType> where ErrorType: Error {
    case value(String)
    case failure([ErrorType])

    public init(error: ErrorType) {
        self = .failure([error])
    }

    /// Is `true` if the receiver is a failure.
    public var isFailure: Bool {
        switch self {
        case .value: return false   
        case .failure: return true
        }
    }

    /// Get list of errors if the receiver is a failure, otherwise `nil`.
    public var errors: [ErrorType] {
        switch self {
        case .value: return []  
        case .failure(let errors): return errors
        }
    }

    /// Get strnig value of the receiver or `nil` if the receivers is a
    /// failure.
    public var string: String? {
        switch self {
        case let .value(str): return str
        case .failure: return nil
        }
    }

    
    /// Prefix the value with `left` and suffix with `right` when condition is
    /// `true`.
    public func wrap(left: String, right: String, when: Bool=false) -> ResultString {
        switch self {
        case let .value(str) where when == true: return .value(left + str + right)
        default: return self
        }
    }

    /// Pad the value with spaces on both sides.
    public func pad() -> ResultString {
        switch self {
        case let .value(str): return .value(" \(str) ")
        default: return self
        }
    }
}

extension ResultString: Concatenable {
    /// Concatenate two results and produce another result string. If both
    /// objects are string values, the result is a value of concatenated
    /// strings. If one of the results is a failure, then result is concatenation
    /// of the failures.
    ///
    public func concatenate(_ other: ResultString<ErrorType>)
        -> ResultString<ErrorType>
    {
        switch (self, other) {
        case let (.value(lvalue), .value(rvalue)): return .value(lvalue + rvalue)
        case let (.failure(error), .value(_)): return .failure(error)
        case let (.value(_), .failure(error)): return .failure(error)
        case let (.failure(lerror), .failure(rerror)): return .failure(lerror + rerror)
        }
    }
}
public func +<E: Error>(lhs: ResultString<E>, rhs: ResultString<E>) -> ResultString<E> {
    return lhs.concatenate(rhs)
}

public func +<E: Error>(lhs: ResultString<E>, error: E) -> ResultString<E> {
    switch lhs {
    case .value: return .failure([error])
    case .failure(let errors): return .failure(errors + [error])
    }
}

public func +<E: Error>(lhs: ResultString<E>, string: String) -> ResultString<E> {
    switch lhs {
    case .value(let value): return .value(value + string)
    case .failure: return lhs
    }
}

public func +<E: Error>(string: String, rhs: ResultString<E>) -> ResultString<E> {
    switch rhs {
    case .value(let value): return .value(string + value)
    case .failure: return rhs
    }
}

public func +=<E: Error>(lhs: inout ResultString<E>, error: E) {
    lhs = lhs + error
}

public func +=<E: Error>(lhs: inout ResultString<E>, string: String) {
    lhs = lhs + string
}

public func +=<E: Error>(lhs: inout ResultString<E>, rhs: ResultString<E>) {
    lhs = lhs + rhs
}

// Comparison
// TODO: Add error comparison
public func ==<E: Error>(lhs: ResultString<E>, string: String) -> Bool {
    switch lhs {
    case .value(let value) where value == string: return true
    default: return false
    }
}

extension ResultString: ExpressibleByStringLiteral {
    public init(stringLiteral value: String.StringLiteralType) {
        self = .value(value)
    }
    public init(extendedGraphemeClusterLiteral value:
            String.ExtendedGraphemeClusterLiteralType){
        self = .value(value)
    }
    public init(unicodeScalarLiteral value: String.UnicodeScalarLiteralType) {
        self = .value(value)
    }
}

