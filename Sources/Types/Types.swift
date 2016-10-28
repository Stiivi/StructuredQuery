// Data Types
//
// This is initial version of simple data types, their properties and
// meachanisms around them. Not the best, but works for now.
//
// Design requirements:
//
//   * types have to be extensible – anyone can create their own data type
//
// Future plans:
//
//   * Custom functions for parameter conversion and for result value-to-object
//     conversion 


public class DataType: Hashable, CustomStringConvertible, CustomDebugStringConvertible {

	/// Special data type of a NULL constant
	public static let NULL = DataType(name: "NULL")

	/// Special data type for function signatures
	public static let ANY = DataType(name: "ANY")

	/// Data type name as used in a dialect
	public let name: String
	/// Name of a dialect to which the data type belongs or `default` for
	/// default dialect.
	public let dialectName: String

	/// Fully qualified data type name in form `dialect`.`typeName`.
	var fullyQualifiedName: String {
		return "\(dialectName).\(name)"
	}

	var isNull: Bool { return self == DataType.NULL }
	var isConcatenable: Bool { return false }
	var isError: Bool { return false }

	public var description: String { return name }
	public var debugDescription: String { return fullyQualifiedName }

	/// Creates a new DataType `name` for dialect with name `dialectName`. If
	/// `dialectName` is not specified then `"default"` is used
	public init(name: String, dialectName: String="default") {
		self.name = name
		self.dialectName = dialectName
	}
}


public class ConcatenableDataType: DataType {
	public override var isConcatenable: Bool {
		return false
	}
}


extension DataType {
	public var hashValue: Int {
		return self.fullyQualifiedName.hashValue
	}
}

public func ==(lhs: DataType, rhs: DataType) -> Bool {
	return lhs.fullyQualifiedName == rhs.fullyQualifiedName
}

// TODO: Make an enum of known error data types
public class ErrorDataType: DataType {
	let message: String

	override var isError: Bool { return true }

	override public var description: String {
		return "\(name)(\(message))"
	}
	override public var debugDescription: String {
		return "\(fullyQualifiedName)(\(message))"
	}

	public init(message: String) {
		self.message = message
		super.init(name: "ERROR")
	}
}
// Basic Types
//

public let BOOLEAN = DataType(name: "BOOLEAN")
public let INTEGER = DataType(name: "INTEGER")
public let DOUBLE = DataType(name: "DOUBLE")
public let TEXT = DataType(name: "TEXT")

