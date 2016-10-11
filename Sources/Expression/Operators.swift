import Types

/// Definitions of operator signatures
//
// This is not the best solution, but works for now
//

public let NullBinarySignatures = [
	FunctionSignature(arguments: [DataType.NULL, DataType.ANY], returnType: DataType.NULL),
	FunctionSignature(arguments: [DataType.ANY, DataType.NULL], returnType: DataType.NULL)
]

public let ArithmeticOperatorSignatures = [
	FunctionSignature(arguments: [INTEGER, INTEGER], returnType: INTEGER),
	FunctionSignature(arguments: [DOUBLE, DOUBLE], returnType: DOUBLE),
	FunctionSignature(arguments: [INTEGER, DOUBLE], returnType: DOUBLE),
	FunctionSignature(arguments: [DOUBLE, INTEGER], returnType: DOUBLE)
]

public let BooleanBinarySignatures = [
	FunctionSignature(arguments: [BOOLEAN, BOOLEAN], returnType: BOOLEAN)
]

public let BooleanUnarySignatures = [
	FunctionSignature(arguments: [BOOLEAN], returnType: BOOLEAN)
]

public let NumericUnarySignatures = [
	FunctionSignature(arguments: [INTEGER], returnType: INTEGER),
	FunctionSignature(arguments: [DOUBLE], returnType: DOUBLE)
]

public let ExistenceSignatures = [
	FunctionSignature(arguments: [DataType.ANY], returnType: BOOLEAN),
]

public let TextOperatorSignatures = [
	FunctionSignature(arguments: [TEXT, TEXT], returnType: TEXT)
]

public let BasicBinarySignatures: Dictionary<String,[FunctionSignature]> = [
	"add": ArithmeticOperatorSignatures,
	"sub": ArithmeticOperatorSignatures,
	"mul": ArithmeticOperatorSignatures,
	"div": ArithmeticOperatorSignatures,
	"mod": ArithmeticOperatorSignatures,
	"exp": ArithmeticOperatorSignatures,

	"bitand": [],
	"bitor": [],
	"bitxor": [],
	"shl": [],
	"shr": [],

	"and": BooleanBinarySignatures,
	"or": BooleanBinarySignatures,

	"eq": BooleanBinarySignatures,
	"ne": BooleanBinarySignatures,
	"lt": BooleanBinarySignatures,
	"le": BooleanBinarySignatures,
	"gt": BooleanBinarySignatures,
	"ge": BooleanBinarySignatures,

	"concat": TextOperatorSignatures,
	"like": TextOperatorSignatures,

	"in": [],
	"notin": []
]

public let BasicUnarySignatures: Dictionary<String,[FunctionSignature]> = [
	"neg": NumericUnarySignatures,
	"not": BooleanUnarySignatures,
	"bitnot": [],
	"exists": ExistenceSignatures,
	"distinct": [],
	"any": ExistenceSignatures
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
func ==(left: Expression, right: Expression) -> Expression {
	return .binary("eq", left, right)
}

func !=(left: Expression, right: Expression) -> Expression {
	return .binary("neq", left, right)
}

infix operator <>: ComparisonPrecedence
func <>(left: Expression, right: Expression) -> Expression {
	return .binary("neq", left, right)
}

func <(left: Expression, right: Expression) -> Expression {
	return .binary("lt", left, right)
}

func <=(left: Expression, right: Expression) -> Expression {
	return .binary("le", left, right)
}

func >(left: Expression, right: Expression) -> Expression {
	return .binary("gt", left, right)
}

func >=(left: Expression, right: Expression) -> Expression {
	return .binary("ge", left, right)
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
