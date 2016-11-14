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
    public var qualifiedName: QualifiedRelationName? {
        return QualifiedRelationName(name: name)
    }

    public var attributes: [AttributeReference] {
        let attributes = relation.attributes.map {
            attr in
            return AttributeReference(index: attr.index,
                                      name: attr.name,
                                      relation: self)
        }
        return attributes
    }

    /// List of references to colmns of this `Select` statement.
    public var attributeExpressions: [Expression] {
        return relation.attributeExpressions
    }
}
