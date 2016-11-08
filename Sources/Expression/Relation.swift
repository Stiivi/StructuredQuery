import Basic
import Schema

public struct QualifiedRelationName {
    let name: String
    let schema: String?
    public init(name: String, schema: String? = nil) {
        self.name = name
        self.schema = schema
    }
}

extension QualifiedRelationName: CustomStringConvertible {
    public var description: String {
        return schema.map { schema in "\(schema).\(name)" } ?? name
    }
}

extension QualifiedRelationName: Hashable {
    public var hashValue: Int {
        return name.hashValue ^ (schema.map { $0.hashValue } ?? 0)
    }
    public static func ==(lhs: QualifiedRelationName, rhs: QualifiedRelationName) -> Bool {
        return lhs.name == rhs.name && lhs.schema == rhs.schema
    }
}

/// Represents a relation
public protocol Relation {
    /// Name of the relation
    var qualifiedName: QualifiedRelationName? { get }
    /// List of references to named columns of the relation.
    ///
    var columns: [ColumnReference] { get }
    
    /// Creates a `Projection` object.
    ///
    /// - Parameter selectList: list of expressions or expression-convertible
    ///                         objects. If `nil` is provided (usually
    ///                         default), then all columns from the selectable
    ///                         are included.
    func project(_ selectList: [ExpressionConvertible]?) -> Projection

    /// Creates an alias for the receiver.
    func alias(as name: String) -> Alias

    /// Returns a column expression for given column name.
    ///
    /// Default implementation returns first column with given name if multiple
    /// columns with the same name are present.
    ///
    /// If the selection does not have a column with given name, then an error
    /// expression is returned.
    // TODO: We need an Error reference here
    subscript(name: String) -> ColumnReference { get }

    /// List of errors associated with the receiver.
    ///
    /// The errors are not dialect specific.
    // var errors: [Error] { get }
}

public func ==(lhs: Relation, rhs: Relation) -> Bool {
// public func ==<T: Relation, U:Relation>(lhs: T, rhs: U) -> Bool {
    switch (lhs, rhs) {
    case let (lrel as Alias, rrel as Alias) where lrel == rrel: return true
    case let (lrel as Join, rrel as Join) where lrel == rrel: return true
    case let (lrel as Projection, rrel as Projection) where lrel == rrel: return true
    default: return false
    }
}

extension Relation {
    public func alias(as name: String) -> Alias {
        return Alias(self, as:name)
    }
    public func project(_ selectList: [ExpressionConvertible]?=nil) -> Projection {
        if let selectList = selectList {
            return Projection(selectList, from: self)   
        }
        else {
            return Projection(self.columns, from: self)   
        }
    }

    public subscript(name: String) -> ColumnReference {
        let ref = columns.first { $0.name == name } 
        return ref!
    }
}

/// Reference to a column of a table expression.
///
public struct ColumnReference: Equatable {
    /// Table expression that owns the column
    public let relation: Relation
    /// Name of the column within the relation thath this reference
    /// refers to
    public let name: String

    public init(name: String, relation: Relation) {
        self.name = name
        self.relation = relation
    }
}

public func ==(lhs: ColumnReference, rhs: ColumnReference) -> Bool {
    return lhs.name == rhs.name && lhs.relation == rhs.relation
}

extension ColumnReference: ExpressionConvertible {
    public var toExpression: Expression { return .columnReference(self) }
}


extension Table: Relation {
    public var qualifiedName: QualifiedRelationName? {
        return QualifiedRelationName(name: name, schema: schema)
    }

    /// List of references to colmns of this `Select` statement.
    public var columns: [ColumnReference] {
        let references = self.columnDefinitions.map {
            ColumnReference(name: $0.name, relation: self)
        }

        return references
    }
}
