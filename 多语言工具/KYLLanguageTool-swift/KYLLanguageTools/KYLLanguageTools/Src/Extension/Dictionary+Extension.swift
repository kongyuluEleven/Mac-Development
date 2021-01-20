//
//  Dictionary+Extension.swift
//  WSUIKit
//
//  Created by kongyulu on 2021/1/6.
//


extension Dictionary {
    /// 将给定字典的元素添加到self的副本中并返回该副本。
    /// 给定字典中的相同键值覆盖self副本中的键值。
    func appending(_ dictionary: [Key: Value]) -> [Key: Value] {
        var newDictionary = self

        for (key, value) in dictionary {
            newDictionary[key] = value
        }

        return newDictionary
    }
}

/// 元类型值的散列包装器。
struct HashableType<T>: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.base == rhs.base
    }

    let base: T.Type

    init(_ base: T.Type) {
        self.base = base
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(base))
    }
}

public extension Dictionary {
    /// 字典是否为空
    var isNotEmpty: Bool {
        return !isEmpty
    }

    /// 检查字典中是否存在key。
    ///
    ///        let dict: [String: Any] = ["testKey": "testValue", "testArrayKey": [1, 2, 3, 4, 5]]
    ///        dict.has(key: "testKey") -> true
    ///        dict.has(key: "anotherKey") -> false
    ///
    /// - Parameter key: 搜索键
    /// - Returns: 如果字典中存在key，则为true。
    func has(key: Key) -> Bool {
        return index(forKey: key) != nil
    }

    mutating func get(_ key: Key, orElse value: @autoclosure () -> Value) -> Value {
        return self[key] ?? {
            let newValue = value()
            self[key] = newValue
            return newValue
        }()
    }
    
//    subscript<T>(key: T.Type) -> Value? {
//        get { self[(key)] }
//        set {
//            self[(key)] = newValue
//        }
//    }

}

// MARK: - 通用方法

public extension Dictionary {
    /// 根据按给定键路径分组的给定序列创建字典。
    ///
    /// - Parameters:
    ///   - sequence: 被分组的序列
    ///   - keypath: 分组by的键路径。
    init<S: Sequence>(grouping sequence: S, by keyPath: KeyPath<S.Element, Key>) where Value == [S.Element] {
        self.init(grouping: sequence, by: { $0[keyPath: keyPath] })
    }


    /// 从字典中删除keys参数中包含的所有键。
    ///
    ///        var dict : [String: String] = ["key1" : "value1", "key2" : "value2", "key3" : "value3"]
    ///        dict.removeAll(keys: ["key1", "key2"])
    ///        dict.keys.contains("key3") -> true
    ///        dict.keys.contains("key1") -> false
    ///        dict.keys.contains("key2") -> false
    ///
    /// - Parameter keys: 需要删除的key
    mutating func removeAll<S: Sequence>(keys: S) where S.Element == Key {
        keys.forEach { removeValue(forKey: $0) }
    }

    /// 从字典中移除随机键的值。
    @discardableResult
    mutating func removeValueForRandomKey() -> Value? {
        guard let randomKey = keys.randomElement() else { return nil }
        return removeValue(forKey: randomKey)
    }

    #if canImport(Foundation)
    /// 来自dictionary的JSON数据。
    ///
    /// - Parameter prettify: 设置true来美化数据(默认为false)。
    /// - Returns: 可选JSON数据(如果适用)。
    func jsonData(prettify: Bool = false) -> Data? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization
            .WritingOptions()
        return try? JSONSerialization.data(withJSONObject: self, options: options)
    }
    #endif

    #if canImport(Foundation)
    /// 字典的JSON字符串。
    ///
    ///        dict.jsonString() -> "{"testKey":"testValue","testArrayKey":[1,2,3,4,5]}"
    ///
    ///        dict.jsonString(prettify: true)
    ///        /*
    ///        returns the following string:
    ///
    ///        "{
    ///        "testKey" : "testValue",
    ///        "testArrayKey" : [
    ///            1,
    ///            2,
    ///            3,
    ///            4,
    ///            5
    ///        ]
    ///        }"
    ///
    ///        */
    ///
    /// - Parameter prettify: 设置true为美化字符串(默认为false)。
    /// - Returns: 可选JSON字符串。
    func jsonString(prettify: Bool = false) -> String? {
        guard JSONSerialization.isValidJSONObject(self) else { return nil }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization
            .WritingOptions()
        guard let jsonData = try? JSONSerialization.data(withJSONObject: self, options: options) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
    #endif

    /// 返回一个字典，其中包含给定闭包对序列元素的映射结果。
    /// - Parameter transform: 关闭一个映射。' transform '接受序列中的元素作为参数，并返回经过转换的相同或不同类型的值。
    /// - Returns: 一个字典，包含这个序列中转换后的元素。
    func mapKeysAndValues<K, V>(_ transform: ((key: Key, value: Value)) throws -> (K, V)) rethrows -> [K: V] {
        return [K: V](uniqueKeysWithValues: try map(transform))
    }

    /// 返回一个字典，其中包含使用该序列的每个元素调用给定转换时的非' nil '结果。
    /// - Parameter transform: 接受序列中的元素作为参数并返回可选值的闭包。
    /// - Returns: 使用序列的每个元素调用' transform '时的非' nil '结果的字典。
    /// - Complexity: *O(m + n)*，其中_m_是这个序列的长度，_n_是结果的长度。
    func compactMapKeysAndValues<K, V>(_ transform: ((key: Key, value: Value)) throws -> (K, V)?) rethrows -> [K: V] {
        return [K: V](uniqueKeysWithValues: try compactMap(transform))
    }

    /// 使用指定的键创建一个新的字典
    ///
    ///        var dict =  ["key1": 1, "key2": 2, "key3": 3, "key4": 4]
    ///        dict.pick(keys: ["key1", "key3", "key4"]) -> ["key1": 1, "key3": 3, "key4": 4]
    ///        dict.pick(keys: ["key2"]) -> ["key2": 2]
    ///
    /// - Complexity: O(K)，其中_K_是键数组的长度。
    ///
    /// - Parameter keys: 将成为结果字典中的条目的键数组。
    ///
    /// - Returns: 只包含指定键的新字典。如果键都不存在，则返回一个空字典。
    func pick(keys: [Key]) -> [Key: Value] {
        keys.reduce(into: [Key: Value]()) { result, item in
            result[item] = self[item]
        }
    }
}

// MARK: - Methods (Value: Equatable)

public extension Dictionary where Value: Equatable {
    /// 返回字典中具有给定值的所有键的数组。
    ///
    ///        let dict = ["key1": "value1", "key2": "value1", "key3": "value2"]
    ///        dict.keys(forValue: "value1") -> ["key1", "key2"]
    ///        dict.keys(forValue: "value2") -> ["key3"]
    ///        dict.keys(forValue: "value3") -> []
    ///
    /// - Parameter value: 要获取的键的值。
    /// - Returns: 包含具有给定值的键的数组。
    func keys(forValue value: Value) -> [Key] {
        return keys.filter { self[$0] == value }
    }
}

// MARK: - Methods (ExpressibleByStringLiteral)

public extension Dictionary where Key: StringProtocol {
    /// 小写字典中的所有键。
    ///
    ///        var dict = ["tEstKeY": "value"]
    ///        dict.lowercaseAllKeys()
    ///        print(dict) // prints "["testkey": "value"]"
    ///
    mutating func lowercaseAllKeys() {
        // http://stackoverflow.com/questions/33180028/extend-dictionary-where-key-is-of-type-string
        for key in keys {
            if let lowercaseKey = String(describing: key).lowercased() as? Key {
                self[lowercaseKey] = removeValue(forKey: key)
            }
        }
    }
}

// MARK: - Subscripts

public extension Dictionary {
    /// 从嵌套字典中获取或设置一个值。
    ///
    ///        var dict =  ["key": ["key1": ["key2": "value"]]]
    ///        dict[path: ["key", "key1", "key2"]] = "newValue"
    ///        dict[path: ["key", "key1", "key2"]] -> "newValue"
    ///
    /// - Note: 值获取是迭代的，而设置是递归的。
    ///
    /// - Complexity: O(N)， _N_是传入路径的长度。
    ///
    /// - Parameter path: 指向所需值的键数组。
    ///
    /// - Returns: 传入的键路径的值。如果没有找到值，则使用' nil '。
    subscript(path path: [Key]) -> Any? {
        get {
            guard !path.isEmpty else { return nil }
            var result: Any? = self
            for key in path {
                if let element = (result as? [Key: Any])?[key] {
                    result = element
                } else {
                    return nil
                }
            }
            return result
        }
        set {
            if let first = path.first {
                if path.count == 1, let new = newValue as? Value {
                    return self[first] = new
                }
                if var nested = self[first] as? [Key: Any] {
                    nested[path: Array(path.dropFirst())] = newValue
                    return self[first] = nested as? Value
                }
            }
        }
    }
}

// MARK: - Operators

public extension Dictionary {
    /// 合并两个字典的键/值。
    ///
    ///        let dict: [String: String] = ["key1": "value1"]
    ///        let dict2: [String: String] = ["key2": "value2"]
    ///        let result = dict + dict2
    ///        result["key1"] -> "value1"
    ///        result["key2"] -> "value2"
    ///
    /// - Parameters:
    ///   - lhs: dictionary
    ///   - rhs: dictionary
    /// - Returns: 一个包含键和值的字典。
    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var result = lhs
        rhs.forEach { result[$0] = $1 }
        return result
    }

    // MARK: - Operators

    /// 将第二个字典中的键和值附加到第一个字典中
    ///
    ///        var dict: [String: String] = ["key1": "value1"]
    ///        let dict2: [String: String] = ["key2": "value2"]
    ///        dict += dict2
    ///        dict["key1"] -> "value1"
    ///        dict["key2"] -> "value2"
    ///
    /// - Parameters:
    ///   - lhs: dictionary
    ///   - rhs: dictionary
    static func += (lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach { lhs[$0] = $1 }
    }

    /// 从字典中删除序列中包含的键
    ///
    ///        let dict: [String: String] = ["key1": "value1", "key2": "value2", "key3": "value3"]
    ///        let result = dict-["key1", "key2"]
    ///        result.keys.contains("key3") -> true
    ///        result.keys.contains("key1") -> false
    ///        result.keys.contains("key2") -> false
    ///
    /// - Parameters:
    ///   - lhs: dictionary
    ///   - keys: 带有要删除的键的数组。
    /// - Returns: 删除了键的新字典。
    static func - <S: Sequence>(lhs: [Key: Value], keys: S) -> [Key: Value] where S.Element == Key {
        var result = lhs
        result.removeAll(keys: keys)
        return result
    }

    /// 从字典中删除序列中包含的键
    ///
    ///        var dict: [String: String] = ["key1": "value1", "key2": "value2", "key3": "value3"]
    ///        dict-=["key1", "key2"]
    ///        dict.keys.contains("key3") -> true
    ///        dict.keys.contains("key1") -> false
    ///        dict.keys.contains("key2") -> false
    ///
    /// - Parameters:
    ///   - lhs: dictionary
    ///   - keys: 带有要删除的键的数组。
    static func -= <S: Sequence>(lhs: inout [Key: Value], keys: S) where S.Element == Key {
        lhs.removeAll(keys: keys)
    }
}


