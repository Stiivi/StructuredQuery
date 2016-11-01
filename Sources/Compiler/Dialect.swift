import Types
import Expression

/// Protocol that specifies a SQL dialect properties.
protocol Dialect {
    func binaryOperator(_ name:String) -> Operator?
    func unaryOperator(_ name:String) -> Operator?
}


/// Default SQL dialect that other dialects are recommended to inherit from.
class DefaultDialect: Dialect {
    func binaryOperator(_ name:String) -> Operator? {
        return BasicBinaryOperators[name] ?? nil
    }
    func unaryOperator(_ name:String) -> Operator? {
        return BasicUnaryOperators[name] ?? nil
    }
}


