import Basic
import Schema

/// Relation name with optional qualifier
///
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


/// Type that can be represented as a relation
public protocol RelationRepresentable {
    var relation: Relation { get }
}

public enum JoinType {
    case inner
    case leftOuter
    case rightOuter
    case fullOuter
}

// TODO: Array literal convertible
/// Describes a relation
///
public indirect enum Relation: Equatable {
    /// No relation, used for extended projection (expressions)
    case none

    /// Physical relation
    case table(Table)

    /// Projection of attributes or extended attributes
    case projection([Expression], Relation)

    /// Selection from a relation by a predicate
    case selection(Expression, Relation)
    
    /// Rename
    case rename(String, Relation)

    /// Join
    // TODO: Find a better name. We prefer to keep `join` for the function name
    case ajoin(JoinType, Relation, Relation, Expression?)

    case error(Relation, ExpressionError)

    // TODO: union etc.
    // case union(Relation)
    // case minus(Relation)

    /// Name of the relation
    public var qualifiedName: QualifiedRelationName? {
        switch self {
        case .table(let table):
            return QualifiedRelationName(name: table.name, schema: table.schema)
        case .rename(let name, _):
            return QualifiedRelationName(name: name)
        default:
            return nil
        } 
    }

    /// List of references to attributes of this relation.
    /// 
    /// If the underlying expression has an alias, then the reference will have
    /// equal name to the alias. If there are multiple attributes with the same
    /// alias, then all of the references with the same name will be marked as
    /// ambiguous. If the underlying expression does not have an alias, then
    /// the reference will contain only index of the expression within the list
    /// of attribute expressions.
    ///
    /// - Note: If you want to get a list of attributes to be used in
    /// transformations and other expressions for derived relations see
    /// `attributes`
    ///
    /// - Returns: list of attribute references
    ///
    public var attributeReferences: [AttributeReference] {
        switch self {
        case .none: return []
        case .table(let table):
            return table.columnDefinitions.enumerated().map {
                i, col in
                AttributeReference(index: .concrete(i),
                                   name: col.name,
                                   relation: self)
            }
        case .projection(let selectList, _):
            // Gather duplicate attribute names
            let duplicates = selectList.flatMap{ $0.alias }.duplicates 

            // For every attribute produce a reference that might be:
            // - regular reference: if attribute has a name and has no
            //   duplicate
            // - "ambiguous" reference: if attribute has a name but has a
            //   duplicate
            // - anonymous reference: if attribute has no name
            let refs: [AttributeReference] = selectList.enumerated().map {
                i, expr in
                if let name = expr.alias {

                    let index: AttributeIndex

                    if duplicates.contains(name) {
                        index = .ambiguous 
                    } 
                    else {
                        // We have a name and there is no duplicate.
                        // We want all attributes to be like this.
                        index = .concrete(i)
                    }
                    return AttributeReference(index: index,
                                              name: name,
                                              relation: self)
                }
                else {
                    // Anonymous attribute reference
                    return AttributeReference(index: .concrete(i),
                                              name: nil,
                                              relation: self)
                }
            }

            return refs
        case .selection(_, let relation):
                return relation.attributeReferences
        case .rename(_, let relation):
            // Own the renamed relation's attributes
			let attributes = relation.attributeReferences.map {
				attr in
				return AttributeReference(index: attr.index,
										  name: attr.name,
										  relation: self)
			}
			return attributes
        case .ajoin(_, let left, let right, _):
                return left.attributeReferences + right.attributeReferences
        case .error: return []
        
        } 
    }

    /// List of expressions that represent attributes of this relation.
    ///
    /// These expressions can be used for transformations to derive a relation.
    /// In SQL statements these expressions are usually rendered as column
    /// names.
    public var attributes: [Expression] {
        return attributeReferences.map { .attribute($0) }
    }

    /// List of expressions projected from a physical relation or from the
    /// underlying relations.
    ///
    /// These are expressions that describe how an attribute is being computed.
    /// The list is for example used by a SQL compiler to generate the select
    /// list.
    public var projectedExpressions: [Expression] {
        switch self {
        case .none: return []
        case .table: return attributes
        case .projection(let projectList, _): return projectList
        case .selection(_, let relation): return relation.projectedExpressions
        case .rename(_, let relation): return relation.projectedExpressions
        case .ajoin(_, let left, let right, _):
                return left.projectedExpressions + right.projectedExpressions
        case .error: return []
        } 
    }
    
    /// Underlying relations
    /// Immediate relations that the receiver is derived from
    public var immediateRelations: [Relation] {
        switch self {
        case .none: return []
        case .table: return [self]
        case .projection(_, let relation): return relation.immediateRelations
        case .selection(_, let relation): return relation.immediateRelations
        case .rename: return [self]
        case .ajoin(_, let left, let right, _):
                return left.immediateRelations + right.immediateRelations
        case .error: return []
        } 
    }
    /// Ultimate relations the receiver and it's childred is derived from. If
    /// the relation is not derived, such as table, then `baseRelations` is
    /// empty list.
    public var baseRelations: [Relation] {
        switch self {
        case .none: return []
        case .table: return [self]
        case .projection(_, let relation): return relation.baseRelations
        case .selection(_, let relation): return relation.baseRelations
        case .rename(_, let relation): return relation.baseRelations
        case .ajoin(_, let left, let right, _): return left.baseRelations + right.baseRelations
        case .error: return []
        } 
    }

    /// Creates a `Projection` object.
    ///
    /// - Parameter selectList: list of expressions or expression-convertible
    ///                         objects. If `nil` is provided (usually
    ///                         default), then all columns from the selectable
    ///                         are included.
    public func project(_ selectList: [ExpressionConvertible]?=nil) -> Relation {
        // FIXME: Check for existence of referenced relations
        let convertibles = selectList ?? self.attributes
        let expressions = convertibles.map { $0.toExpression }
        return .projection(Array(expressions), self) 
    }

    /// Creates an alias for the receiver.
    public func alias(as name: String) -> Relation {
        return .rename(name, self)
    }

    public func select(where predicate: Expression) -> Relation {
        // FIXME: Check for existence of referenced relations
        return .selection(predicate, self)
    }

    public func join(_ right: Relation, type: JoinType = .inner,
                     on predicate: Expression? = nil) -> Relation {
        return .ajoin(type, self, right, predicate)
    }

    /// Returns a column expression for given column name.
    ///
    /// Default implementation returns first column with given name if multiple
    /// columns with the same name are present.
    ///
    /// If the selection does not have a column with given name, then an error
    /// expression is returned.
    public subscript(name: String) -> Expression { 
        let ref = attributeReferences.first { $0.name == name }
                        ?? AttributeReference(index: .unknown, name: name, relation: self)
        return .attribute(ref)
    }

    /// Name of the relation used for debugging purposes or error reporting
    var debugDescription: String {
        return self.qualifiedName.map { $0.description } ?? "(anonymous)"
    }

    var error: ExpressionError? {
        switch self {
        case .error(_, let val): return val
        default: return nil
        }
    }
}

extension Relation: RelationRepresentable{
    public var relation: Relation {
        return self
    }
}


// Equality
//
public func ==(lhs: Relation, rhs: Relation) -> Bool {
    switch (lhs, rhs) {
    case (.none, .none): return true
    case let (.table(lval), .table(rval)) where lval == rval: return true
    case let (.projection(lrel, lexp), .projection(rrel, rexp))
            where lrel == rrel && lexp == rexp: return true
    case let (.selection(lval), .selection(rval)) where lval == rval: return true
    case let (.rename(lval), .rename(rval)) where lval == rval: return true
    case let (.ajoin(lleft, lright, ltype, lexpr), .ajoin(rleft, rright, rtype, rexpr))
            where lleft == rleft && lright == rright && ltype == rtype
                    && lexpr == rexpr: return true
    case let (.error(lrel, lerr), .error(rrel, rerr))
            where lrel == rrel && lerr == rerr: return true
    default: return false
    }
}


