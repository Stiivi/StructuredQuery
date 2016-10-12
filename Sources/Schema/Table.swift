import Basic
import Types

public typealias ColumnList = PropertyLookupArray<Column,String>

public class Table {
	public let name: String
	public let schema: String?
	public let columnDescriptions: ColumnList

	public init(_ name: String, schema: String?=nil, columns: [Column] ) {
		self.name = name
		self.schema = schema
		self.columnDescriptions = ColumnList(columns) { $0.name }
	}
	public convenience init(_ name: String, schema: String?=nil, _ columns: Column... ) {
		self.init(name, schema: schema, columns: columns)
	}
}

public class Column {
	public let name: String
	public let type: DataType

	required public init(_ name: String, _ type: DataType) {
		self.name = name
		self.type = type
	}
}

