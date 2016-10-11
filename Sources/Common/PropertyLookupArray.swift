/// Ordered collection of elements which can be subscriptable by a custom key.
/// Only the first element with given key is accessible. Information about
/// duplicate keys is included.
public class PropertyLookupArray<T, Key> : Collection  where Key: Hashable {
    public typealias ArrayType = Array<T>
    public typealias Index = ArrayType.Index
    //    typealias Index = Int

    typealias LookupType = [Key:Index]

    let array: ArrayType
    let lookup: LookupType

	/// List of keys that were present in multiple elements
    public let duplicateKeys: Set<Key>

	/// Creates a new array from elements. Uses the `getKey` function to
	/// extract a key from an enelement, that will be used to access the element
	/// through subscript.
	///
	/// If the `getKey` function returns `nil` then the element will not be
	/// indexed in the lookup table.
    public init(_ elements: ArrayType, getKey: @escaping (ArrayType.Element) -> Key?) {
        self.array = elements

        var lookup = LookupType()
        var dupes = Set<Key>()

        elements.enumerated().forEach {
            index, element in

			// Are we indexing the property?
            if let key = getKey(element) {
				// Is the key indexed already?
				if lookup[key] == nil {
					lookup[key] = index
				}
				else {
					// Already present
					dupes.insert(key)
				}
			}
        }

        self.lookup = lookup
        self.duplicateKeys = dupes
    }

    // Collection protocol methods
    public var startIndex: Index { return array.startIndex }
    public var endIndex: Index { return array.endIndex }
    public func index(after: Index) -> Index {
        return array.index(after: after)
    }

    public subscript(index: ArrayType.Index) -> ArrayType.Element {
        return array[index]
    }

	/// Gets the first element in the array which has the `key`.
    public subscript(key: Key) -> ArrayType.Element? {
        return lookup[key].map { array[$0] }
    }

}
