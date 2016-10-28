import Basic
import Schema

/// Represents objects from which SELECT queries can be formed.
public protocol Selectable: TableExpressionConvertible {
    /// List of column references of the selectable object.
    ///
    /// - Note: Only columns with a name or alias are included in the list.
    ///
    var columns: [ColumnReference] { get }
    
    /// Creates a `Select` object.
    ///
    /// - Parameter selectList: list of expressions or expression-convertible
    ///                         objects. If `nil` is provided (usually
    ///                         default), then all columns from the selectable
    ///                         are included.
    func select(_ selectList: [ExpressionConvertible]?) -> Select

    /// Creates an alias for the receiver.
    func alias(as name: String) -> Alias

    /// Returns a column expression for given column name.
    ///
    /// Default implementation returns first column with given name if multiple
    /// columns with the same name are present.
    ///
    /// If the selection does not have a column with given name, then an error
    /// expression is returned.
    // TODO: We need an Error reference here
    subscript(name: String) -> Expression { get }

    /// List of errors associated with the receiver.
    ///
    /// The errors are not dialect specific.
    var errors: [Error] { get }
}

extension Selectable {
    public func select(_ selectList: [ExpressionConvertible]?=nil) -> Select {
        let actualList: [ExpressionConvertible] = selectList ?? columns
        return Select(actualList, from: self)
    }
    public func alias(as name: String) -> Alias {
        return Alias(self, as:name)
    }

    public subscript(name: String) -> Expression {
        let ref = columns.first { $0.name == name } 

        return ref.map { .columnReference($0) } ?? .error(.unknownColumn(name))
    }

    public var errors: [Error] {
        return []
    }
}

extension Table: Selectable {
    /// List of references to colmns of this `Select` statement.
    public var columns: [ColumnReference] {
        let tableExpression = toTableExpression
        let references = self.columnDefinitions.map {
            ColumnReference(name: $0.name, tableExpression: tableExpression)
        }

        return references
    }

    public func select(_ selectList: [ExpressionConvertible]?=nil) -> Select {
        let actualList: [ExpressionConvertible]

        actualList = selectList ?? columns

        return Select(actualList, from: self)
    }

}
