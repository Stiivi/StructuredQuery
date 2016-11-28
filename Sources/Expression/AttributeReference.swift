import Basic

public enum AttributeIndex: Equatable {
    case concrete(Int)
    case ambiguous
    case unknown

    public var value: Int? {
        switch self {
        case .concrete(let index): return index
        default: return nil
        }
    }

    public static func ==(lhs: AttributeIndex, rhs: AttributeIndex) -> Bool {
        switch (lhs, rhs) {
        case let (.concrete(lval), .concrete(rval)) where lval == rval: return true
        case (.ambiguous, .ambiguous): return true
        case (.unknown, .unknown): return true
        default: return false
        }
    }
}

public struct AttributeReference: Hashable {
    public let index: AttributeIndex
    public let name: String?
    public let relation: Relation

    public init(index: AttributeIndex, name: String?, relation: Relation) {
        self.index = index
        self.name = name
        self.relation = relation
    }

    public var error: ExpressionError? {
        switch index {
        case .concrete(let i):
            if name != nil {
                // We have both: index and name
                return nil
            }
            else {
                return .anonymousAttribute(i, relation.debugDescription)
            }
        case .ambiguous:
                return .ambiguousAttribute(name ?? "(unnamed)", relation.debugDescription)
        case .unknown:
                return .unknownAttribute(name ?? "(unnamed)", relation.debugDescription)
        }
    }

    public var hashValue: Int {
        // TODO: Is this good enough?
        return name.map { $0.hashValue } ?? 0
    }
}

extension AttributeReference: CustomStringConvertible {
    public var description: String {
        let key: String
        switch index {
        case .concrete(let i): key = name.map { $0 } ?? "[\(i)]" 
        case .ambiguous: key = name.map { "[ambiguous `\($0)]`"} ?? "[ambiguous]"
        case .unknown: key = name.map { "[unknown `\($0)]`"} ?? "[unknown]"
        }
        return "\(relation.debugDescription).\(key)"
    }
}

extension AttributeReference: ExpressionConvertible {
    public var toExpression: Expression {
        return .attribute(self)
    }
}

public func ==(lhs: AttributeReference, rhs: AttributeReference) -> Bool {
    return lhs.index == rhs.index
            && lhs.name == rhs.name
            && lhs.relation == rhs.relation
}

