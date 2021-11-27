//
//  UserDefaults+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

// 偏好设置相关扩展

#if canImport(Foundation) && !os(Linux)
import Foundation

// MARK: - 方法扩展

public extension UserDefaults {
    /// 使用下标从UserDefaults中获取对象
    ///
    /// - Parameter key: 键在当前用户的默认数据库中。
    subscript(key: String) -> Any? {
        get {
            return object(forKey: key)
        }
        set {
            set(newValue, forKey: key)
        }
    }

    /// 从偏好设置中获取浮点类型数据
    ///
    /// - Parameter forKey: 保存的键值对
    /// - Returns: 如果存在返回浮点类型对象，否则返回nil
    func float(forKey key: String) -> Float? {
        return object(forKey: key) as? Float
    }

    /// 从偏好设置中获取Date类型数据
    ///
    /// - Parameter forKey: 保存的键值对
    /// - Returns: 如果存在返回Date对象，否则返回nil
    func date(forKey key: String) -> Date? {
        return object(forKey: key) as? Date
    }

    /// 从UserDefaults中检索一个可编码对象。
    ///
    /// - Parameters:
    ///   - type: 符合可编码协议的类。
    ///   - key: 对象的标识符。
    ///   - decoder: 自定义JSONDecoder实例。默认为“JSONDecoder()”。
    /// - Returns: 可编码对象的键(如果存在)。
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }

    /// 允许将可编码对象存储到用户默认值。
    ///
    /// - Parameters:
    ///   - object: 要存储的可编码对象。
    ///   - key: 对象的标识符。
    ///   - encoder: 自定义JSONEncoder实例。默认为“JSONEncoder()”。
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        set(data, forKey: key)
    }
}

#endif

