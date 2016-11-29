public protocol Concatenable {
    func concatenate(_ other: Self) -> Self
}

// TODO: This should be replaced by an Array/Collection extension
public func concatenate<S: Collection, T: Concatenable>(_ sequence: S, separator: T) -> T
    where T == S.Iterator.Element, S.SubSequence.Iterator.Element == T, S.Index == Int
{
    precondition(!sequence.isEmpty)

    let head: T = sequence.first!
    let tail = sequence.suffix(from: 1)
    
    let finalResult = tail.reduce(head) {
        result, element in 
        return result.concatenate(separator).concatenate(element)
    }

    return finalResult
}

extension Collection where Iterator.Element: Hashable {
    var uniqueFlags: [Iterator.Element:Bool] {
        var unique: [Iterator.Element:Bool]
        unique = self.reduce([:]) {
            accumulator, item in
            var result = accumulator
            if result.index(forKey: item) == nil {
                // Seen for the first time
                result.updateValue(true, forKey: item)
            }
            else {
                // Not unique, already seen
                result[item] = false
            }
            return result
        }

        return unique
    }

    /// Returns elements that are duplicated in the array
    public var duplicates: Set<Iterator.Element> {
        let dupes: Set<Iterator.Element> = Set(uniqueFlags.flatMap {
                key, isUnique in
                if isUnique { return nil }
                else { return key }
            })
        return dupes
    }

    /// Returns elements
	// TODO: Make this lazy
    public var distinct: [Iterator.Element] {
        var seen = Set<Self.Iterator.Element>()
        return filter {
            elem in
            seen.insert(elem).inserted
        }
    }

}

/*
extension Collection where Iterator.Element == Concatenable {
    public func concatenated(separator: Iterator.Element) -> Iterator.Element
    {
        precondition(!isEmpty)

        let head: Iterator.Element = first!
        let finalResult: Iterator.Element
        
        finalResult = reduce(head) {
            result, element in result.concatenate(separator)
        }

        return finalResult
    }
}
*/
