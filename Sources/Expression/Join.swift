
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

    public init(left: Relation, right: Relation, type: JoinType = .inner) {
        // TODO: Don't allow relations with same aliases to be joined
        // Joining tables with same name produces ambiguous columns
        self.left = left
        self.right = right
        self.type = type
    }
}

extension Join: Relation {
    /// List of references to colmns of this `Select` statement.
    public var columns: [ColumnReference] {
        return left.columns + right.columns
    }
}

public func ==(lhs: Join, rhs: Join) -> Bool {
    return lhs.type == rhs.type
            && lhs.left == rhs.left
            && lhs.right == rhs.right
}
