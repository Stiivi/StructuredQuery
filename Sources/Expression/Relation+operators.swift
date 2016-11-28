// Inner
infix operator ⨝
func ⨝(lhs: Relation, rhs: Relation) -> Relation {
    return lhs.join(rhs, type: .inner)
}

// Left outer
infix operator ⟕
func ⟕(lhs: Relation, rhs: Relation) -> Relation {
    return lhs.join(rhs, type: .leftOuter)
}

// Right outer
infix operator ⟖
func ⟖(lhs: Relation, rhs: Relation) -> Relation {
    return lhs.join(rhs, type: .rightOuter)
}

// Full outer
infix operator ⟗
func ⟗(lhs: Relation, rhs: Relation) -> Relation {
    return lhs.join(rhs, type: .fullOuter)
}

