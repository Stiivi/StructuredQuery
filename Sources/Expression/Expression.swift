public indirect enum Expression: Equatable {
	// Literals
	case null
	case integer(Int)
	case string(String)
	case bool(Bool)

	// Operators
	case binary(BinaryOperator, Expression, Expression)
	case unary(UnaryOperator, Expression)

	case function(String, [Expression])

	// Bind parameter
	case parameter(String)

	// case column(Column)

	// CASE
	// CAST
	// EXTRACT

	case label(Expression, String)
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
	case let(.label(lval), .label(rval)) where lval == rval: return true
	case let(.function(lname, largs), .function(rname, rargs))
				where lname == rname && largs == rargs: return true
	case let(.parameter(lval), .parameter(rval)) where lval == rval: return true
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

extension Expression: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Int.IntegerLiteralType) {
		self = .integer(value)
	}
}
extension Expression: ExpressibleByNilLiteral {
	public init(nilLiteral: ()) {
		self = .null
	}
}
extension Expression: ExpressibleByBooleanLiteral {
	public init(booleanLiteral value: Bool.BooleanLiteralType){
		self = .bool(value)
	}
}

// Arithmetic Operators
//
func +(left: Expression, right: Expression) -> Expression {
	return .binary(.add, left, right)
}

func -(left: Expression, right: Expression) -> Expression {
	return .binary(.sub, left, right)
}

func *(left: Expression, right: Expression) -> Expression {
	return .binary(.mul, left, right)
}

func /(left: Expression, right: Expression) -> Expression {
	return .binary(.div, left, right)
}

func %(left: Expression, right: Expression) -> Expression {
	return .binary(.mod, left, right)
}


// Comparison Operators
//
func ==(left: Expression, right: Expression) -> Expression {
	return .binary(.eq, left, right)
}

func !=(left: Expression, right: Expression) -> Expression {
	return .binary(.ne, left, right)
}

infix operator <>: ComparisonPrecedence
func <>(left: Expression, right: Expression) -> Expression {
	return .binary(.ne, left, right)
}

func <(left: Expression, right: Expression) -> Expression {
	return .binary(.lt, left, right)
}

func <=(left: Expression, right: Expression) -> Expression {
	return .binary(.le, left, right)
}

func >(left: Expression, right: Expression) -> Expression {
	return .binary(.gt, left, right)
}

func >=(left: Expression, right: Expression) -> Expression {
	return .binary(.ge, left, right)
}

// TODO: Question: should we follow the "swift" convention of these operators
// or the target (SQL) expression of the operators?
func ||(left: Expression, right: Expression) -> Expression {
	return .binary(.or, left, right)
}

func &&(left: Expression, right: Expression) -> Expression {
	return .binary(.and, left, right)
}

func &(left: Expression, right: Expression) -> Expression {
	return .binary(.bitand, left, right)
}

func |(left: Expression, right: Expression) -> Expression {
	return .binary(.bitor, left, right)
}

// Unary
prefix func -(right: Expression) -> Expression {
	return .unary(.neg, right)
}

prefix func !(right: Expression) -> Expression {
	return .unary(.not, right)
}

prefix func ~(right: Expression) -> Expression {
	return .unary(.bitnot, right)
}


