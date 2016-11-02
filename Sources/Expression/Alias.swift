import Schema

/// Assignment of a name to a selectable.
public final class Alias: Equatable {
    /// Selectable that is aliased with a name
    public let relation: Relation
    /// Name assigned to the selectable
    public let name: String

    /// Creates an alias `name` for `selectable`.
    public init(_ relation: Relation, as name: String) {
        self.relation = relation
        self.name = name
    }
}

public func ==(lhs: Alias, rhs: Alias) -> Bool {
    return lhs.name == rhs.name && lhs.relation == rhs.relation
}

extension Alias: Relation {
    /// List of references to colmns of this `Select` statement.
    public var columns: [ColumnReference] {
        let references = self.relation.columns.map {
            ColumnReference(name: $0.name, relation: self)
        }

        return references
    }
}
