//
//  Collection+Extension.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Dispatch)
import Dispatch
#endif


// MARK: - 属性
public extension Collection {
    /// 是否为空
    var isNotEmpty: Bool {
        return !isEmpty
    }
    
    /// 全部集合的范围
    var fullRange: Range<Index> { startIndex..<endIndex }
}


// MARK: - 方法
public extension Collection {

    /// 返回无限序列，其中包含集合中连续且唯一的随机元素。
    ///     ```
    ///     let x = [1, 2, 3].uniqueRandomElementIterator()
    ///
    ///     x.next()
    ///     //=> 2
    ///     x.next()
    ///     //=> 1
    ///
    ///     for element in x.prefix(2) {
    ///         print(element)
    ///     }
    ///     //=> 3
    ///     //=> 1
    ///     ```
    /// - Returns: 无限序列
    func uniqueRandomElementIterator() -> AnyIterator<Element> {
        var previousNumber: Int?

        return AnyIterator {
            var offset: Int
            repeat {
                offset = Int.random(in: 0..<self.count)
            } while offset == previousNumber
            previousNumber = offset

            return self[self.index(self.startIndex, offsetBy: offset)]
        }
    }
    
}


// MARK: - Methods

public extension Collection {
    #if canImport(Dispatch)
    /// 并行地为集合的每个元素执行“每个”闭包。
    ///
    ///        array.forEachInParallel { item in
    ///            print(item)
    ///        }
    ///
    /// - Parameter each: 闭包为每个元素运行。
    func forEachInParallel(_ each: (Self.Element) -> Void) {
        DispatchQueue.concurrentPerform(iterations: count) {
            each(self[index(startIndex, offsetBy: $0)])
        }
    }
    #endif

    /// Safe通过使用optional来保护数组不受限制。
    ///
    ///        let arr = [1, 2, 3, 4, 5]
    ///        arr[safe: 1] -> 2
    ///        arr[safe: 10] -> nil
    ///
    /// - Parameter index: 访问元素的元素索引。
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }

    /// 从数组中返回长度为“size”的切片数组。如果数组不能被均匀地分割，那么最后一片将是剩下的元素。
    ///
    ///     [0, 2, 4, 7].group(by: 2) -> [[0, 2], [4, 7]]
    ///     [0, 2, 4, 7, 6].group(by: 2) -> [[0, 2], [4, 7], [6]]
    ///
    /// - Parameter size: 要返回的片的大小。
    /// - Returns: grouped self.
    func group(by size: Int) -> [[Element]]? {
        // Inspired by: https://lodash.com/docs/4.17.4#chunk
        guard size > 0, !isEmpty else { return nil }
        var start = startIndex
        var slices = [[Element]]()
        while start != endIndex {
            let end = index(start, offsetBy: size, limitedBy: endIndex) ?? endIndex
            slices.append(Array(self[start..<end]))
            start = end
        }
        return slices
    }

    /// 获取满足条件的所有索引。
    ///
    ///     [1, 7, 1, 2, 4, 1, 8].indices(where: { $0 == 1 }) -> [0, 2, 5]
    ///
    /// - Parameter condition: 条件来对每个元素求值。
    /// - Returns: 指定条件计算为true的所有索引。(可选)
    func indices(where condition: (Element) throws -> Bool) rethrows -> [Index]? {
        let indices = try self.indices.filter { try condition(self[$0]) }
        return indices.isEmpty ? nil : indices
    }

    /// 用参数片的大小数组调用给定的闭包。
    ///
    ///     [0, 2, 4, 7].forEach(slice: 2) { print($0) } -> // print: [0, 2], [4, 7]
    ///     [0, 2, 4, 7, 6].forEach(slice: 2) { print($0) } -> // print: [0, 2], [4, 7], [6]
    ///
    /// - Parameters:
    ///   - slice: 数组在每次迭代中的大小。
    ///   - body: 以片大小数组作为参数的闭包。
    func forEach(slice: Int, body: ([Element]) throws -> Void) rethrows {
        var start = startIndex
        while case let end = index(start, offsetBy: slice, limitedBy: endIndex) ?? endIndex,
            start != end {
            try body(Array(self[start..<end]))
            start = end
        }
    }
}

// MARK: - Methods (Equatable)

public extension Collection where Element: Equatable {
    /// 指定项目的所有索引。
    ///
    ///        [1, 2, 2, 3, 4, 2, 5].indices(of 2) -> [1, 2, 5]
    ///        [1.2, 2.3, 4.5, 3.4, 4.5].indices(of 2.3) -> [1]
    ///        ["h", "e", "l", "l", "o"].indices(of "l") -> [2, 3]
    ///
    /// - Parameter item: item to check.
    /// - Returns: 具有给定项的所有下标的数组。
    func indices(of item: Element) -> [Index] {
        return indices.filter { self[$0] == item }
    }
}

// MARK: - Methods (BinaryInteger)

public extension Collection where Element: BinaryInteger {
    /// 数组中所有元素的平均值。
    ///
    /// - Returns: 数组元素的平均值。
    func average() -> Double {
        // http://stackoverflow.com/questions/28288148/making-my-function-calculate-average-of-array-swift
        guard !isEmpty else { return .zero }
        return Double(reduce(.zero, +)) / Double(count)
    }
}

// MARK: - Methods (FloatingPoint)

public extension Collection where Element: FloatingPoint {
    /// 数组中所有元素的平均值。
    ///
    ///        [1.2, 2.3, 4.5, 3.4, 4.5].average() = 3.18
    ///
    /// - Returns: 数组元素的平均值。
    func average() -> Element {
        guard !isEmpty else { return .zero }
        return reduce(.zero, +) / Element(count)
    }
}



public extension SetAlgebra {
    /// 如果' value '不存在，则插入它，否则删除它。
    mutating func toggleExistence(_ value: Element) {
        if contains(value) {
            remove(value)
        } else {
            insert(value)
        }
    }

    /// 如果' shouldExist '为true，则插入' value '，否则删除它。
    mutating func toggleExistence(_ value: Element, shouldExist: Bool) {
        if shouldExist {
            insert(value)
        } else {
            remove(value)
        }
    }
}

public extension RangeReplaceableCollection {
    /// Move the element at the `from` index to the `to` index.
    mutating func move(from fromIndex: Index, to toIndex: Index) {
        guard fromIndex != toIndex else {
            return
        }

        insert(remove(at: fromIndex), at: toIndex)
    }
}

public extension RangeReplaceableCollection where Element: Equatable {
    /// Move the first equal element to the `to` index.
    mutating func move(_ element: Element, to toIndex: Index) {
        guard let fromIndex = firstIndex(of: element) else {
            return
        }

        move(from: fromIndex, to: toIndex)
    }
}


public extension Collection where Index == Int, Element: Equatable {
    /// 返回一个数组，其中给定元素已移动到' to '索引。
    func moving(_ element: Element, to toIndex: Index) -> [Element] {
        var array = Array(self)
        array.move(element, to: toIndex)
        return array
    }
}

public extension Collection where Index == Int, Element: Equatable {
    /// 返回一个数组，其中给定的元素已经移动到数组的末尾。
    func movingToEnd(_ element: Element) -> [Element] {
        moving(element, to: endIndex - 1)
    }
}
