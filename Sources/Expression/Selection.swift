import Basic

public final class Selection: Equatable {
    public let relation: Relation
    public let predicate: Expression

    public init(relation: Relation, where predicate: Expression) {
        self.relation = relation
        self.predicate = predicate
    }
}

public func ==(lhs: Selection, rhs: Selection) -> Bool {
    return lhs.relation == rhs.relation
            && lhs.predicate == rhs.predicate
}

extension Selection: Relation {
    public var qualifiedName: QualifiedRelationName? {
        return relation.qualifiedName
    }

    public var attributes: [AttributeReference] {
        return relation.attributes
    }

    public var attributeExpressions: [Expression] {
        return relation.attributeExpressions
    }

    public var immediateRelations: [Relation] {
        return relation.immediateRelations
    }
    public var baseRelations: [Relation] {
        return relation.baseRelations
    }
}
