import Types

// Operators
// ---------
//
// Operators are referenced by their name/identifiert. Their string
// representation might vary between dialects.


public enum OperatorAssociativity {
    case left
    case right
}

public class Operator {
    /// Default string representation of the operator. Dialects might have
    /// their own string.
    public let string: String
    /// Defgault type signatures. Dialect might append/prepend its own.
    public let signatures: [FunctionSignature]
    /// Default operator precedence.
    public let precedence: Int
    /// Default operator associativity.
    public let associativity: OperatorAssociativity

    public init(_ string: String, signatures: [FunctionSignature], 
                precedence: Int=0, associativity: OperatorAssociativity = .left) {
        self.string = string
        self.signatures = signatures
        self.precedence = precedence
        self.associativity = associativity
    }
}

/// Definitions of default operator signatures

public let NullBinarySignatures = [
    (DataType.NULL, DataType.ANY)  |^| DataType.NULL,
    (DataType.ANY,  DataType.NULL) |^| DataType.NULL
]

public let ArithmeticOperatorSignatures = [
    (INTEGER, INTEGER) |^| INTEGER,
    (DOUBLE,  DOUBLE)  |^| DOUBLE,
    (INTEGER, DOUBLE)  |^| DOUBLE,
    (DOUBLE,  INTEGER) |^| DOUBLE
]

public let BitwiseOperatorSignatures = [
    (INTEGER, INTEGER) |^| INTEGER
]

public let BooleanBinarySignatures = [
    (BOOLEAN, BOOLEAN) |^| BOOLEAN
]

public let BooleanUnarySignatures = [
    BOOLEAN |^| BOOLEAN
]

public let NumericUnarySignatures = [
    INTEGER |^| INTEGER,
    DOUBLE |^| DOUBLE
]

public let BitUnarySignatures = [
    INTEGER |^| INTEGER,
]

public let ExistenceSignatures = [
    DataType.ANY |^| BOOLEAN,
]

public let TextOperatorSignatures = [
    (TEXT, TEXT) |^| TEXT
]


public let BasicBinaryOperators: [String:Operator] = [
    // Exponentiative precedence
    "exp": Operator("^",
                    signatures: ArithmeticOperatorSignatures,
                    precedence: 160),
    "shl": Operator("<<",
                    signatures: BitwiseOperatorSignatures,
                    precedence: 160),
    "shr": Operator(">>",
                    signatures: BitwiseOperatorSignatures,
                    precedence: 160),

    // Multiplicative precedence
    "mul": Operator("*",
                    signatures: ArithmeticOperatorSignatures,
                    precedence: 150),
    "div": Operator("/",
                    signatures: ArithmeticOperatorSignatures,
                    precedence: 150),
    "mod": Operator("%",
                    signatures: ArithmeticOperatorSignatures,
                    precedence: 150),

    "bitand": Operator("&",
                    signatures: [],
                    precedence: 150),


    // Additive precedence
    "add": Operator("+",
                    signatures: ArithmeticOperatorSignatures,
                    precedence: 140),
    "sub": Operator("-",
                    signatures: ArithmeticOperatorSignatures,
                    precedence: 140),

    "bitor": Operator("|",
                    signatures: BitwiseOperatorSignatures,
                    precedence: 140),
    "bitxor": Operator("#",
                    signatures: BitwiseOperatorSignatures,
                    precedence: 140),

    "concat": Operator("||",
                    signatures: TextOperatorSignatures,
                    precedence: 140),


    // Comparative
    "eq": Operator("=",
                    signatures: BooleanBinarySignatures,
                    precedence: 130),
    "ne": Operator("!=",
                    signatures: BooleanBinarySignatures,
                    precedence: 130),
    "lt": Operator("<",
                    signatures: BooleanBinarySignatures,
                    precedence: 130),
    "le": Operator("<=",
                    signatures: BooleanBinarySignatures,
                    precedence: 130),
    "gt": Operator(">=",
                    signatures: BooleanBinarySignatures,
                    precedence: 130),
    "ge": Operator(">",
                    signatures: BooleanBinarySignatures,
                    precedence: 130),

    "like": Operator("LIKE",
                    signatures: TextOperatorSignatures,
                    precedence: 130),


    // Logical
    "and": Operator("AND",
                    signatures: BooleanBinarySignatures,
                    precedence: 110),
    "or": Operator("OR",
                    signatures: BooleanBinarySignatures,
                    precedence: 110,
                    associativity: .right),
]


public let BasicUnaryOperators: [String:Operator] = [
    "neg": Operator("-",
                    signatures: NumericUnarySignatures),
    "not": Operator("NOT",
                    signatures: BooleanUnarySignatures),
    "bitnot": Operator("~",
                    signatures: BitUnarySignatures),
]


// Arithmetic Operators
//
func +(left: Expression, right: Expression) -> Expression {
    return .binary("add", left, right)
}

func -(left: Expression, right: Expression) -> Expression {
    return .binary("sub", left, right)
}

func *(left: Expression, right: Expression) -> Expression {
    return .binary("mul", left, right)
}

func /(left: Expression, right: Expression) -> Expression {
    return .binary("div", left, right)
}

func %(left: Expression, right: Expression) -> Expression {
    return .binary("mod", left, right)
}


// Comparison Operators
//
func ==(left: ExpressionConvertible, right: ExpressionConvertible) -> Expression {
    return .binary("eq", left.toExpression, right.toExpression)
}

func !=(left: ExpressionConvertible, right: ExpressionConvertible) -> Expression {
    return .binary("neq", left.toExpression, right.toExpression)
}

infix operator <>: ComparisonPrecedence
func <>(left: ExpressionConvertible, right: ExpressionConvertible) -> Expression {
    return .binary("neq", left.toExpression, right.toExpression)
}

func <(left: ExpressionConvertible, right: ExpressionConvertible) -> Expression {
    return .binary("lt", left.toExpression, right.toExpression)
}

func <=(left: ExpressionConvertible, right: ExpressionConvertible) -> Expression {
    return .binary("le", left.toExpression, right.toExpression)
}

func >(left: ExpressionConvertible, right: ExpressionConvertible) -> Expression {
    return .binary("gt", left.toExpression, right.toExpression)
}

func >=(left: ExpressionConvertible, right: ExpressionConvertible) -> Expression {
    return .binary("ge", left.toExpression, right.toExpression)
}

// TODO: Question: should we follow the "swift" convention of these operators
// or the target (SQL) expression of the operators?
func ||(left: Expression, right: Expression) -> Expression {
    return .binary("or", left, right)
}

func &&(left: Expression, right: Expression) -> Expression {
    return .binary("and", left, right)
}

func &(left: Expression, right: Expression) -> Expression {
    return .binary("bitand", left, right)
}

func |(left: Expression, right: Expression) -> Expression {
    return .binary("bitor", left, right)
}

// Unary
prefix func -(right: Expression) -> Expression {
    return .unary("neg", right)
}

prefix func !(right: Expression) -> Expression {
    return .unary("not", right)
}

prefix func ~(right: Expression) -> Expression {
    return .unary("bitnot", right)
}
