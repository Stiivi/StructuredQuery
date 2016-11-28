import Basic
import Types

public typealias ColumnList = LookupList<String, Column>

/// Table in a relational database
///
public class Table: Hashable {
    public let name: String
    public let schema: String?
    public let columnDefinitions: ColumnList

    public init(_ name: String, schema: String?=nil, columns: [Column] ) {
        self.name = name
        self.schema = schema
        self.columnDefinitions = ColumnList(columns) { $0.name }
    }
    public convenience init(_ name: String, schema: String?=nil, _ columns: Column... ) {
        self.init(name, schema: schema, columns: columns)
    }

    public var hashValue: Int {
        return name.hashValue ^ (schema.map { $0.hashValue } ?? 0)
    }
}

public func ==(lhs: Table, rhs: Table) -> Bool {
    return lhs.name == rhs.name
            && lhs.schema == rhs.schema
            && lhs.columnDefinitions == rhs.columnDefinitions
}

public class Column: Equatable {
    public let name: String
    public let type: DataType

    required public init(_ name: String, _ type: DataType) {
        self.name = name
        self.type = type
    }
}

public func ==(lhs: Column, rhs: Column) -> Bool {
    return lhs.name == rhs.name && lhs.type == rhs.type
}
