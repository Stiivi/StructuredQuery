import Basic
import Schema

/// Represents a relation
public protocol Relation {
    /// Name of the relation
    var name: String?
    /// List of references to named columns of the relation.
    ///
    var columns: [ColumnReference] { get }
    
    /// Creates a `Projection` object.
    ///
    /// - Parameter selectList: list of expressions or expression-convertible
    ///                         objects. If `nil` is provided (usually
    ///                         default), then all columns from the selectable
    ///                         are included.
    //func project(_ selectList: [ExpressionConvertible]?) -> Projection

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

extension Relation {
    public func alias(as name: String) -> Alias {
        return Alias(self, as:name)
    }

    public subscript(name: String) -> ColumnReference {
        let ref = columns.first { $0.name == name } 
        return ref!
    }
}


public func ==(lhs: Relation, rhs: Relation) -> Bool {
    return type(of: lhs) == type(of: rhs) && lhs == rhs
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
    /// List of references to colmns of this `Select` statement.
    public var columns: [ColumnReference] {
        let references = self.columnDefinitions.map {
            ColumnReference(name: $0.name, relation: self)
        }

        return references
    }
}
