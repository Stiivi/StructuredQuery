public enum ExpressionError: Error, CustomStringConvertible, Equatable {
	/// There are more columns with the same name
	case ambiguousColumn(String)
	/// Column with given name does not exist
	case unknownColumn(String)

	public var description: String {
		switch self {
		case let .ambiguousColumn(name): return "Abiguous column '\(name)'"
		case let .unknownColumn(name): return "Unknown column '\(name)'"
		}
	}
}

public func ==(lhs: ExpressionError, rhs: ExpressionError) -> Bool {
	// FIXME: Use proper comparison
	return lhs.description == rhs.description
}

public enum TableExpressionError: Error, CustomStringConvertible, Equatable {
	case emptySelectList

	public var description: String {
		switch self {
		case .emptySelectList: return "Select list is empty"
		}
	}
}

public func ==(lhs: TableExpressionError, rhs: TableExpressionError) -> Bool {
	// FIXME: Use proper comparison
	return lhs.description == rhs.description
}

