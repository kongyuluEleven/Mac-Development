//
//  Sequence+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

public extension Sequence {
    /**
     通过将元素与分子映射，返回序列中元素的和。

    ```
    [1, 2, 3].sum { $0 == 1 ? 10 : $0 }
    //=> 15
    ```
    */
    func sum<T: AdditiveArithmetic>(_ numerator: (Element) throws -> T) rethrows -> T {
        var result = T.zero

        for element in self {
            result += try numerator(element)
        }

        return result
    }
}


public extension Sequence {
    /**
     通过映射值并使用返回的键作为键，使用当前序列元素作为值，将序列转换为字典。

    ```
    [1, 2, 3].toDictionary { $0 }
    //=> [1: 1, 2: 2, 3: 3]
    ```
    */
    func toDictionary<Key: Hashable>(with pickKey: (Element) -> Key) -> [Key: Element] {
        var dictionary = [Key: Element]()
        for element in self {
            dictionary[pickKey(element)] = element
        }
        return dictionary
    }

    /**
     通过映射元素并返回表示新字典元素的键/值元组，将序列转换为字典。

    ```
    [(1, "a"), (2, "b")].toDictionary { ($1, $0) }
    //=> ["a": 1, "b": 2]
    ```
    */
    func toDictionary<Key: Hashable, Value>(with pickKeyValue: (Element) -> (Key, Value)) -> [Key: Value] {
        var dictionary = [Key: Value]()
        for element in self {
            let newElement = pickKeyValue(element)
            dictionary[newElement.0] = newElement.1
        }
        return dictionary
    }

    /**
     通过映射元素并返回表示新字典元素的键/值元组，将序列转换为字典。，但是支持返回可选值。

    ```
    [(1, "a"), (nil, "b")].toDictionary { ($1, $0) }
    //=> ["a": 1, "b": nil]
    ```
    */
    func toDictionary<Key: Hashable, Value>(with pickKeyValue: (Element) -> (Key, Value?)) -> [Key: Value?] {
        var dictionary = [Key: Value?]()
        for element in self {
            let newElement = pickKeyValue(element)
            dictionary[newElement.0] = newElement.1
        }
        return dictionary
    }
}

