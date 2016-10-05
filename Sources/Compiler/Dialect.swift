import Expression

/// Protocol that specifies a SQL dialect properties.
protocol Dialect {
	func signatures(forBinary:String) -> [FunctionSignature]
	func signatures(forUnary:String) -> [FunctionSignature]
	func signatures(forFunction:String) -> [FunctionSignature]
}


/// Default SQL dialect that other dialects are recommended to inherit from.
class DefaultDialect: Dialect {
	func signatures(forBinary name:String) -> [FunctionSignature] {
		return BasicBinarySignatures[name] ?? []
	}
	func signatures(forUnary name:String) -> [FunctionSignature] {
		return BasicUnarySignatures[name] ?? []
	}
	func signatures(forFunction name:String) -> [FunctionSignature] {
		return []
	}
}


