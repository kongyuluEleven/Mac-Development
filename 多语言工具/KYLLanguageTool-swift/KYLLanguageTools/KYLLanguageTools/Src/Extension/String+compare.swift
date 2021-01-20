//
//  String+compare.swift
//  KYLLanguageTools
//
//  Created by kongyulu on 2021/1/20.
//

#if canImport(Foundation)
import Foundation


// MARK: - 字符串比较
public extension String {
    
    /// 格式化键 \u{08}为自动生成的
    /// - Parameter key: key 键值对
    /// - Returns: 返回格式化的字符串
    static func formatterKey(key:String) -> String {
        return key.replacingOccurrences(of: "\u{08}", with: "")
    }
    
    
    /// 查找兼容的值
    /// - Parameters:
    ///   - key: 键值对
    ///   - list: 原始Dictionary
    ///   - completion: 查找到的值
    static func findKeyValue(key:String, list:[String:String], completion:((_ value:String?, _ index:Int, _ key:String) -> String?)) {
        // 是否存在 Key 默认为原始的 Key
        var isExitKey:String? = key
        var index = 0
        while true {
            // 如果查找的 Key 已经不存在则退出死循环
            guard let fixKey = isExitKey else {
                break
            }
            // 拿着修复的 Key 获取值
            let value = list[fixKey]
            // 把当前的索引 值 当前修复的 Key 回调回去获取新的修复 Key
            isExitKey = completion(value, index, fixKey)
            index += 1;
        }
    }
    
    
    /// 查找值
    /// - Parameters:
    ///   - key: 键值对
    ///   - list: 查找的字典
    /// - Returns: 匹配的值
    static func findValue(key:String, list:[String:String]?) -> String? {
        // 如果List 不存在 则返回空
        guard let list = list else {
            return nil
        }
        // 查找出来的值
        var value:String?
        // 查找出 Key 对应的值
        String.findKeyValue(key: key, list:list) { (findValue, index, fixKey) -> String? in
            // 如果查找出来值 则复制 并跳出循环
            if let findValue = findValue {
                value = findValue
                return nil
            }
            // 如果第一次查找不到 则去掉所有的空格
            if index == 0 {
                return fixKey.trimmingCharacters(in: CharacterSet.whitespaces)
            } else if index == 1 {
                // 如果第二次查找不到 则替换\" 为\""再次查找
                return fixKey.replacingOccurrences(of: "\\\"", with: "\\\"\"")
            } else if index == 2 {
                // 如果第三次查找不到 则去掉\u{08} 再次查找
                return fixKey.replacingOccurrences(of: "\u{08}", with: "")
            }
            return nil
        }
        return value;
    }

}

#endif
