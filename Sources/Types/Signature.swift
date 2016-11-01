public class FunctionSignature: CustomStringConvertible {
    public let arguments: [DataType]
    public let returnType: DataType

    public init(arguments: [DataType], returnType: DataType) {
        self.arguments = arguments
        self.returnType = returnType
    }

    // TODO: Variadic matching is not supported yet
    public func matches(arguments: [DataType]) -> Bool {
        if arguments.count != self.arguments.count {
            return false
        }
        else {
            return self.arguments.elementsEqual(arguments) {
                (this, other) in
                this == DataType.ANY || this == other
            }
        }
    }

    public var description: String {
        let strings = arguments.map { $0.description }
        let fullString = strings.joined(separator:", ")

        return "[\(fullString)] -> \(returnType.description)"
    
    }
}

infix operator |^|: AdditionPrecedence

public func |^|(lhs: DataType, rhs: DataType) -> FunctionSignature {
    return FunctionSignature(
        arguments: [lhs],
        returnType: rhs
    )
}
public func |^|(lhs: (DataType, DataType), rhs: DataType) -> FunctionSignature {
    return FunctionSignature(
        arguments: [lhs.0, lhs.1],
        returnType: rhs
    )
}


