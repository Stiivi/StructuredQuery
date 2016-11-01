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
