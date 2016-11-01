import Basic

public enum ResultString<ErrorType> where ErrorType: Error {
    case value(String)
    case failure([ErrorType])

    public init(error: ErrorType) {
        self = .failure([error])
    }

    public var isFailure: Bool {
        switch self {
        case .value: return false   
        case .failure: return true
        }
    }

    public var errors: [ErrorType] {
        switch self {
        case .value: return []  
        case .failure(let errors): return errors
        }
    }

    public var string: String? {
        switch self {
        case let .value(str): return str
        case .failure: return nil
        }
    }

    public func wrap(left: String, right: String, when: Bool=false) -> ResultString {
        switch self {
        case let .value(str) where when == true: return .value(left + str + right)
        default: return self
        }
    }
}

extension ResultString: Concatenable {
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

