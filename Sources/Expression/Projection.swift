import Basic
import Schema

// Add: Executable
/// The main object representing a query.
///
public final class Projection: Equatable {
    public let relation: Relation?
    public let selectList: [Expression]

    /// Creates a `Select` object which is the main object to contain full
    /// query specification.
    ///
    /// - Precondition: The `selectList` must not be empty.
    ///
    public init(_ selectList: [ExpressionConvertible]=[], from: Relation?=nil) {
        precondition(selectList.count != 0)

        // If we have the select list, then we use it...
        let expressions = selectList.map { $0.toExpression }
        self.selectList = Array(expressions)

        relation = from
    }
}

extension Projection: Relation {
    public var qualifiedName: QualifiedRelationName? {
        return nil
    }

    /// List of references to attributes of this projection. If the underlying
    /// expression has an alias, then the reference will have equal name to the
    /// alias. If there are multiple attributes with the same alias, then all
    /// of the references with the same name will be marked as ambiguous. If
    /// the underlying expression does not have an alias, then the reference
    /// will contain only index of the expression within the list of attribute
    /// expressions.
    ///
    /// - Returns: list of attribute references
    ///
    public var attributes: [AttributeReference] {
        let duplicates = selectList.flatMap {
            $0.alias
        }.duplicates


        let refs: [AttributeReference] = self.selectList.enumerated().map {
            i, expr in
            if let name = expr.alias {
                let index: AttributeIndex
                if duplicates.contains(name) {
                    index = .ambiguous 
                } 
                else {
                    index = .concrete(i)
                }
                return AttributeReference(index: index,
                                          name: name,
                                          relation: self)
            }
            else {
                return AttributeReference(index: .concrete(i),
                                          name: nil,
                                          relation: self)
            }
        }

        return refs
    }

    public var attributeExpressions: [Expression] {
        return selectList
    }

    public var debugName: String {
        return relation.map { "π(\($0.debugName))" } ?? "π(∅)"
    }

    public var immediateRelations: [Relation] {
        return relation.map { $0.immediateRelations } ?? []
    }
    public var baseRelations: [Relation] {
        return relation.map { $0.baseRelations } ?? []
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

