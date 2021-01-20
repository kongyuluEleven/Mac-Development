//
//  Collection.swift
//  WSUIKit
//
//  Created by Jim Du on 2020/12/30.
//


public extension Array {

    /// 数组是否不为空
    var isNotEmpty: Bool {
        return !isEmpty
    }

    
    /// 移动数组元素
    /// - Parameters:
    ///   - index: 需要移动的下标
    ///   - newIndex: 移动到的目标下标索引
    mutating func moveElement(at index: Int, to newIndex: Int) {
        insert(remove(at: index), at: newIndex)
    }

    
    /// 符合条件的元素个数
    /// - Parameter criteria: 过滤条件
    /// - Returns: 返回符合条件的元素个数
    func count(where criteria: (Element) -> Bool) -> Int {
        return filter(criteria).count
    }

    
    /// 将数组元素按key值分类，返回一个归类后的字典
    /// - Parameter keyForValue: 分类规则
    /// - Returns: 返回一个归类后的字典
    func grouped<T>(by keyForValue: (Element) -> T) -> [T: [Element]] {
        return Dictionary(grouping: self, by: keyForValue)
    }

    
    
    /// 将数组按等间距分割成一个新的数组
    ///
    ///  [1, 2, 3, 4, 5, 6].chunked(into: 2) ==> [[1, 2], [3, 4], [5, 6]]
    ///
    /// - Parameter size: 分割的间距
    /// - Returns: 返回分割后的新数组
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }

}

// MARK: - Methods

public extension Array {
    /// 在数组的开头插入一个元素。
    ///
    ///        [2, 3, 4, 5].prepend(1) -> [1, 2, 3, 4, 5]
    ///        ["e", "l", "l", "o"].prepend("h") -> ["h", "e", "l", "l", "o"]
    ///
    /// - Parameter newElement: 需要新增的元素
    mutating func prepend(_ newElement: Element) {
        insert(newElement, at: 0)
    }

    /// 在给定的索引位置安全地交换值。
    ///
    ///        [1, 2, 3, 4, 5].safeSwap(from: 3, to: 0) -> [4, 2, 3, 1, 5]
    ///        ["h", "e", "l", "l", "o"].safeSwap(from: 1, to: 0) -> ["e", "h", "l", "l", "o"]
    ///
    /// - Parameters:
    ///   - index: 第一个元素的索引。
    ///   - otherIndex: 其他元素的索引。
    mutating func safeSwap(from index: Index, to otherIndex: Index) {
        guard index != otherIndex else { return }
        guard startIndex..<endIndex ~= index else { return }
        guard startIndex..<endIndex ~= otherIndex else { return }
        swapAt(index, otherIndex)
    }

    /// 像其他基于键路径的数组那样对数组进行排序。如果另一个数组不包含某个值，则它将排在最后。
    ///
    ///        [MyStruct(x: 3), MyStruct(x: 1), MyStruct(x: 2)].sorted(like: [1, 2, 3], keyPath: \.x)
    ///            -> [MyStruct(x: 1), MyStruct(x: 2), MyStruct(x: 3)]
    ///
    /// - Parameters:
    ///   - otherArray: 按所需顺序包含元素的数组。
    ///   - keyPath: keyPath，指示数组应按其排序的属性
    /// - Returns: sorted array.
    func sorted<T: Hashable>(like otherArray: [T], keyPath: KeyPath<Element, T>) -> [Element] {
        let dict = otherArray.enumerated().reduce(into: [:]) { $0[$1.element] = $1.offset }
        return sorted {
            guard let thisIndex = dict[$0[keyPath: keyPath]] else { return false }
            guard let otherIndex = dict[$1[keyPath: keyPath]] else { return true }
            return thisIndex < otherIndex
        }
    }
}

// MARK: - Methods (Equatable)

public extension Array where Element: Equatable {
    /// 从数组中移除一个项的所有实例。
    ///
    ///        [1, 2, 2, 3, 4, 5].removeAll(2) -> [1, 3, 4, 5]
    ///        ["h", "e", "l", "l", "o"].removeAll("l") -> ["h", "e", "o"]
    ///
    /// - Parameter item: 需要删除的项
    /// - Returns: 在删除item的所有实例之后。
    @discardableResult
    mutating func removeAll(_ item: Element) -> [Element] {
        removeAll(where: { $0 == item })
        return self
    }

    /// 从数组中移除items参数中包含的所有实例。
    ///
    ///        [1, 2, 2, 3, 4, 5].removeAll([2,5]) -> [1, 3, 4]
    ///        ["h", "e", "l", "l", "o"].removeAll(["l", "h"]) -> ["e", "o"]
    ///
    /// - Parameter items: 需要删除的数组
    /// - Returns: 在删除给定数组中所有项的所有实例之后。
    @discardableResult
    mutating func removeAll(_ items: [Element]) -> [Element] {
        guard !items.isEmpty else { return self }
        removeAll(where: { items.contains($0) })
        return self
    }

    /// 从数组中移除所有重复的元素。
    ///
    ///        [1, 2, 2, 3, 4, 5].removeDuplicates() -> [1, 2, 3, 4, 5]
    ///        ["h", "e", "l", "l", "o"]. removeDuplicates() -> ["h", "e", "l", "o"]
    ///
    /// - Returns: 返回删除所有重复元素的数组。
    @discardableResult
    mutating func removeDuplicates() -> [Element] {
        self = reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
        return self
    }

    /// 返回删除所有重复元素的数组。
    ///
    ///     [1, 1, 2, 2, 3, 3, 3, 4, 5].withoutDuplicates() -> [1, 2, 3, 4, 5])
    ///     ["h", "e", "l", "l", "o"].withoutDuplicates() -> ["h", "e", "l", "o"])
    ///
    /// - Returns: 唯一元素的数组。
    ///
    func withoutDuplicates() -> [Element] {
        return reduce(into: [Element]()) {
            if !$0.contains($1) {
                $0.append($1)
            }
        }
    }

    /// 返回一个数组，使用KeyPath删除所有重复元素以进行比较。
    ///
    /// - Parameter path: 要比较的键路径，该值必须是可以比较的。
    /// - Returns: 唯一元素的数组.
    func withoutDuplicates<E: Equatable>(keyPath path: KeyPath<Element, E>) -> [Element] {
        return reduce(into: [Element]()) { result, element in
            if !result.contains(where: { $0[keyPath: path] == element[keyPath: path] }) {
                result.append(element)
            }
        }
    }

    /// 返回一个数组，使用KeyPath删除所有重复元素以进行比较。
    ///
    /// - Parameter path: 要比较的键路径，该值必须是可哈希的。
    /// - Returns: 唯一元素的数组。
    func withoutDuplicates<E: Hashable>(keyPath path: KeyPath<Element, E>) -> [Element] {
        var set = Set<E>()
        return filter { set.insert($0[keyPath: path]).inserted }
    }
}


public extension Array where Element: Equatable {
    
    /// 用一个新元素替换旧元素
    /// - Parameters:
    ///   - element: 需要被替换的旧元素
    ///   - newElement: 新元素
    /// - Returns: 返回替换后的数组
    @discardableResult
    mutating func replace(_ element: Element, with newElement: Element) -> Bool {
        guard let index = firstIndex(of: element) else { return false }
        self[index] = newElement
        return true
    }

    /// 仅当数组中不包含该元素时才把元素添加到数组中
    mutating func append(distinctElement: Element) {
        guard !contains(distinctElement) else { return }
        self.append(distinctElement)
    }

    /// 仅把数组中不包含的元素加到数组中
    mutating func append(distinctContentsOf elements: [Element]) {
        elements.forEach { append(distinctElement: $0) }
    }

    
    /// 在某个元素的前面插入一个新元素
    ///
    ///
    ///     [1, 3, 4, 5].insert(6, before:5) -> [1, 3, 4, 6, 5])
    ///     [1, 3, 4, 5].insert(2, before:1) -> [2, 1, 3, 4, 5])
    ///
    /// - Parameters:
    ///   - newElement: 需要插入的新元素
    ///   - element: 参考的元素，在这个元素前面插入
    mutating func insert(_ newElement: Element, before element: Element) {
        if let index = firstIndex(of: element) {
            insert(newElement, at: index)
        } else {
            append(newElement)
        }
    }

    
    /// 在某个元素后面插入一个新元素
    ///
    ///     [1, 3, 4, 5].insert(6, after:5) -> [1, 3, 4, 5, 6])
    ///     [1, 3, 4, 5].insert(2, after:1) -> [1, 2, 3, 4, 5])
    ///
    /// - Parameters:
    ///   - newElement: 需要插入的新元素
    ///   - element: 作为参考的元素，在此元素后面插入
    mutating func insert(_ newElement: Element, after element: Element) {
        if let index = firstIndex(of: element) {
            insert(newElement, at: index + 1)
        } else {
            append(newElement)
        }
    }

}
