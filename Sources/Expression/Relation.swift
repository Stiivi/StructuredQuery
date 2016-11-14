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

public enum AttributeIndex: Equatable {
    case concrete(Int)
    case ambiguous
    case unknown

    public var value: Int? {
        switch self {
        case .concrete(let index): return index
        default: return nil
        }
    }

    public static func ==(lhs: AttributeIndex, rhs: AttributeIndex) -> Bool {
        switch (lhs, rhs) {
        case let (.concrete(lval), .concrete(rval)) where lval == rval: return true
        case (.ambiguous, .ambiguous): return true
        case (.unknown, .unknown): return true
        default: return false
        }
    }
}

public struct AttributeReference {
    public let index: AttributeIndex
    public let name: String?
    public let relation: Relation

    public init(index: AttributeIndex, name: String?, relation: Relation) {
        self.index = index
        self.name = name
        self.relation = relation
    }

    public var error: ExpressionError? {
        switch index {
        case .concrete(let i):
            if name != nil {
                // We have both: index and name
                return nil
            }
            else {
                return .anonymousAttribute(i, relation.debugName)
            }
        case .ambiguous:
                return .ambiguousAttribute(name ?? "(unnamed)", relation.debugName)
        case .unknown:
                return .unknownAttribute(name ?? "(unnamed)", relation.debugName)
        }
    }
}

extension AttributeReference: CustomStringConvertible {
    public var description: String {
        let key = name ?? "[\(index)]"
        return "\(relation.debugName).\(key)"
    }
}

extension AttributeReference: ExpressionConvertible {
    public var toExpression: Expression {
        return .attributeReference(self)
    }
}

func ==(lhs: AttributeReference, rhs: AttributeReference) -> Bool {
    return lhs.index == rhs.index
            && lhs.name == rhs.name
            && lhs.relation == rhs.relation
}

/// Represents a relation
public protocol Relation {
    /// Name of the relation
    var qualifiedName: QualifiedRelationName? { get }

    /// List of references to named columns of the relation.
    ///
    var attributes: [AttributeReference] { get }
    var attributeExpressions: [Expression] { get }
    
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
    subscript(name: String) -> AttributeReference { get }

    /// List of errors associated with the receiver.
    ///
    /// The errors are not dialect specific.
    // var hasErrors: Bool { get }
    /// Concrete relation instance errors combined with the common errors
    // var errors: [Error] { get }
    /// Common relation errors
    // var commonErrors: [Error] { get }
    // var baseRelations: [Relation] { get }
    // var allErrors: [(Relation, Error)] { get }
    /// Name of the relation used for debugging purposes or error reporting
    var debugName: String { get }
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
            return Projection(self.attributes, from: self)   
        }
    }

    public subscript(name: String) -> AttributeReference {
        // TODO: Do we need to check for existence of `name` here?
        let first = attributes.first { $0.name == name }
        return first ?? 
                AttributeReference(index: .unknown, name: name, relation: self)
    }

    public var debugName: String {
        return self.qualifiedName.map { $0.description } ?? "(anonymous)"
    }
}

extension Table: Relation {
    public var qualifiedName: QualifiedRelationName? {
        return QualifiedRelationName(name: name, schema: schema)
    }

    public var attributes: [AttributeReference] {
        // We assume that table makes sure that the columns are not ambiguous
        return self.columnDefinitions.enumerated().map {
            i, col in
            AttributeReference(index: .concrete(i),
                               name: col.name,
                               relation: self)
        }
    }

    public var attributeExpressions: [Expression] {
        return self.columnDefinitions.map {
            .tableColumn($0.name, self)
        }
    }
}
