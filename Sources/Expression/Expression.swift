import Schema

/// SQL Expression.
///
/// Core data type that represents multiple types of a SQL expression nodes:
/// literals, NULL, binary and unary operators, function calls, etc.
public indirect enum Expression: Equatable {
	// Literals
	case null
	case integer(Int)
	case string(String)
	case bool(Bool)

	// Operators
	case binary(String, Expression, Expression)
	case unary(String, Expression)

	case function(String, [Expression])

	// Bind parameter
	case parameter(String)

	case alias(Expression, String)
	// case column(Column)

	case tableColumn(String, Table)
	case relationColumn(String, Relation)

	// TODO: case, cast, extract

	public var name: String? {
		switch self {
		case let .alias(_, value): return value
		case let .tableColumn(name, _): return name
		case let .relationColumn(name, _): return name
		default: return nil
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
