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

	// TODO:
	// CASE
	// CAST
	// EXTRACT

	case label(Expression, String)
	// case column(Column)

	case tableColumn(String, Table)
	case tablelikeColumn(String, Tablelike)

	public var alias: String? {
		switch self {
		case let .label(_, value): return value
		default: return nil
		}
	}
}

extension Table: ColumnExpressionListable {
	public var columnExpressions: ColumnExpressionList {
		// TODO: ColumnExpressionList
		let expressions:[Expression] = columnDescriptions.map {
			.tableColumn($0.name, self)
		}

		return ColumnExpressionList(expressions) {
			$0.alias
		}
	}

	/// Get the first column with name `name` if exists. Otherwise returns nil.
	public subscript(name: String) -> Expression? {
		return columnDescriptions.first { $0.name == name }
					  .map { .tableColumn($0.name, self) } 
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
