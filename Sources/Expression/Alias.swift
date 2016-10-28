import Schema

/// Assignment of a name to a selectable.
public final class Alias: Equatable {
    /// Selectable that is aliased with a name
    public let aliased: Selectable
    /// Name assigned to the selectable
    public let name: String

    /// Creates an alias `name` for `selectable`.
    public init(_ selectable: Selectable, as name: String) {
        self.aliased = selectable
        self.name = name
    }
}

public func ==(lhs: Alias, rhs: Alias) -> Bool {
    return lhs.name == rhs.name 
            && lhs.toTableExpression == rhs.toTableExpression
}

extension Alias: Selectable {
    public var toTableExpression: TableExpression {
        return .alias(self)
    }

    /// List of references to colmns of this `Select` statement.
    public var columns: [ColumnReference] {
        let tableExpression = toTableExpression
        let references = self.aliased.columns.map {
            ColumnReference(name: $0.name, tableExpression: tableExpression)
        }

        return references
    }
}
