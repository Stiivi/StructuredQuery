public enum BinaryOperator: CustomStringConvertible {
	case add
	case sub
	case mul
	case div
	case mod
	case exp

	case bitand
	case bitor
	case bitxor
	case shl
	case shr

	case and
	case or

	case eq
	case ne
	case lt
	case le
	case gt
	case ge

	case concat
	case like

	case `in`
	case notin

	public var description: String {
		switch self {
		case .add    : return "+"
		case .sub    : return "-"
		case .mul    : return "*"
		case .div    : return "/"
		case .mod    : return "%"
		case .exp    : return "^"

		case .bitand  : return "&"
		case .bitor   : return "|"
		case .bitxor  : return "#"
		case .shl    : return "<<"
		case .shr    : return ">>"

		case .and    : return "AND"
		case .or     : return "OR"

		case .eq     : return "="
		case .ne     : return "!="
		case .lt     : return "<"
		case .le     : return "<="
		case .gt     : return ">"
		case .ge     : return ">="

		case .concat : return "||"
		case .like   : return "LIKE"

		case .`in`   : return "IN"
		case .notin  : return "NOT IN"
		}

	}
}
public enum UnaryOperator: CustomStringConvertible {
	// Unary

	case neg
	case not
	case bitnot
	case exists
	case distinct
	case any
	
	public var description: String {
		switch self {
		case .neg       : return "-"
		case .not       : return "NOT"
		case .bitnot    : return "~"
		case .exists    : return "EXISTS"
		case .distinct  : return "DISTINCT"
		case .any       : return "ANY"
		}

	}
}

