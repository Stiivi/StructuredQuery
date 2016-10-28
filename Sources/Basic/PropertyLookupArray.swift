/// Ordered collection of elements which can be subscriptable by a custom key.
/// Only elements with unique keys are accessible. Duplicate keys are
/// considered to be amibuous.
public final class LookupList<Key, Value> : Equatable
        where Value: Equatable, Key: Hashable {
    public typealias Index = Array<Value>.Index
    //    typealias Index = Int

    // Elements of the array
    let items: [(key:Key?, value:Value)]
    let lookup: [Key:Index]
    /// Set of keys that were not unique
    public let ambiguous: Set<Key>

    /// Creates a new array from elements. Uses the `extract` function to
    /// extract a key from an enelement, that will be used to access the element
    /// through subscript.
    ///
    /// If the `extract` function returns `nil` then the element will not be
    /// indexed in the lookup table.
    public init(_ values: [Value], extract: @escaping (Value) -> Key?) {
        var mapFirst = [Key:Index]()
        var seen = Set<Key>()
        var duplicates = Set<Key>()

        self.items = values.map { (key:extract($0), value:$0) }

        items.enumerated().forEach {
            index, item in

            // Are we indexing the property?
            if let key = item.key {
                let (isNew, _) = seen.insert(key)
                if isNew {
                    mapFirst[key] = index
                }
                else {
                    duplicates.insert(key)
                }
            }
        }
        self.ambiguous = duplicates
        self.lookup = mapFirst
    }

    /// Creates an empty lookp array.
    convenience public init() {
        self.init([]) { _ in nil }
    }

    /// List of valid (not nil) keys. Might contain duplicates, if they were
    /// present in the original collection.
    public var keys: [Key] {
        return items.flatMap { $0.key }
    } 

    /// Contains value `true` if the collection has values for which the key
    /// can not be determined (is nil).
    public var hasAnonymousValues: Bool {
        return items.contains { $0.key == nil  }
    }

    /// Gets the first element in the array which has the `key`.
    public subscript(key: Key) -> Array<Value>.Element? {
        return lookup[key].map { items[$0].value }
    }
}


extension LookupList: Collection {

    // Collection protocol methods
    public var startIndex: Index { return items.startIndex }
    public var endIndex: Index { return items.endIndex }
    public func index(after: Index) -> Index {
        return items.index(after: after)
    }

    public subscript(index: Array<Value>.Index) -> Array<Value>.Element {
        return items[index].value
    }

}

public func ==<Key: Hashable, Value: Equatable>(lhs: LookupList<Key, Value>,
        rhs: LookupList<Key, Value>) -> Bool {
    return lhs.items.elementsEqual(rhs.items) {
        left, right in
        left.key == right.key && left.value == right.value
    }
}
