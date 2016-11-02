import Basic
import Schema

public typealias ExpressionLookupList = LookupList<String, Expression>

// Add: Executable
/// The main object representing a query.
///
public final class Projection: Equatable {
    public let relation: Relation?
    public let selectList: ExpressionLookupList

    /// Creates a `Select` object which is the main object to contain full
    /// query specification.
    ///
    /// - Precondition: The `selectList` must not be empty.
    ///
    public init(_ selectList: [ExpressionConvertible]=[], from: Relation?=nil) {
        precondition(selectList.count != 0)

        // If we have the select list, then we use it...
        let expressions = selectList.map { $0.toExpression }
        self.selectList = ExpressionLookupList(expressions) {
            $0.alias
        }

        relation = from
    }
}

extension Projection: Relation {
    /// List of references to colmns of this `Select` statement.
    public var columns: [ColumnReference] {
        let references = self.selectList.keys.map {
            ColumnReference(name: $0, relation: self)
        }

        return references
    }

}


public func ==(lhs: Projection, rhs: Projection) -> Bool {
    return lhs.selectList == rhs.selectList
        && ((lhs.relation == nil && rhs.relation == nil)
            || ( lhs.relation.map {
                lrel in rhs.relation.map {
                    rrel in lrel == rrel
                } ?? false
            } ?? false))
}

