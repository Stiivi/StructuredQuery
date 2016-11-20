
public enum JoinType {
    case inner
    case leftOuter
    case rightOuter
    case fullOuter
}

public class Join {
    public let left: Relation
    public let right: Relation
    public let type: JoinType
    public let predicate: Expression?

    public init(left: Relation, right: Relation, type: JoinType = .inner,
                on predicate: Expression? = nil) {
        // TODO: Don't allow relations with same aliases to be joined
        // Joining tables with same name produces ambiguous columns
        self.left = left
        self.right = right
        self.type = type
        self.predicate = predicate
    }
}

extension Join: Relation {
    public var qualifiedName: QualifiedRelationName? {
        return nil
    }
    /// List of references to colmns of this `Select` statement.

    public var attributes: [AttributeReference] {
        return left.attributes + right.attributes
    }

    /// FIXME: Is this really correct?
    public var attributeExpressions: [Expression] {
        return left.attributeExpressions + right.attributeExpressions
    }

    public var immediateRelations: [Relation] {
        return left.immediateRelations + right.immediateRelations
    }
    public var baseRelations: [Relation] {
        return left.baseRelations + right.baseRelations
    }
}

public func ==(lhs: Join, rhs: Join) -> Bool {
    return lhs.type == rhs.type
            && lhs.left == rhs.left
            && lhs.right == rhs.right
            && lhs.predicate == rhs.predicate
}
