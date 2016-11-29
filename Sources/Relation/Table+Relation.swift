import Schema

extension Table: RelationRepresentable {
    public var relation: Relation {
        return .table(self)
    }
}
