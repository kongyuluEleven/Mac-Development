//
//  Date+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

enum DateFormat: String {
    case yyyyMMdd = "yyyy-MM-dd"
    case yyyyMMddHH = "yyyy-MM-dd HH"
    case yyyyMMddHHmm = "yyyy-MM-dd HH:mm"
    case yyyyMMddHHmmss = "yyyy-MM-dd HH:mm:ss"
}

// MARK: - 日期字符串扩展
extension Date {
    
    /// 构造函数，根据格式化字符串初始化Date对象
    /// - Parameters:
    ///   - string: 日期字符串
    ///   - stringFormat: 格式字符串
    public init(withString string: String, _ stringFormat: String = "yyyy-MM-dd HH:mm:ss.SSS" ) {
        let formate = DateFormatter.init()
        formate.dateFormat = stringFormat
        let date = formate.date(from: string)
        self = date == nil ? Date.init() : date!
    }
    
    
    /// 转换为对应的可视化化字符串的日期字符
    /// - Parameter stringFormat: 格式化字符串
    /// - Returns: 日期字符串
    public func convertToFormatString(_ stringFormat: String = "yyyy-MM-dd HH:mm:ss.SSS" ) -> String {
        let formate = DateFormatter.init()
        formate.dateFormat = stringFormat
        let strVal = formate.string(from: self)
        return strVal
    }
    
    
    func toString(format:DateFormat = DateFormat.yyyyMMddHHmmss, joint: String = "-") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        var dFormat = format.rawValue
        if joint != "-" {
             dFormat = format.rawValue.replacingOccurrences(of: "-", with: joint)
        }
        formatter.dateFormat = dFormat
        let date = formatter.string(from: self)
        return date
    }
    
    
    /// 将日期转换为对应字符串
    /// - Parameters:
    ///   - date: 日期Date
    ///   - format: 需要转换的字符串格式
    ///   - joint: 连接符号
    /// - Returns: 格式化后的日期字符串
    static func toString(_ date:Date, format:DateFormat = DateFormat.yyyyMMddHHmmss, joint: String = "-") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale.init(identifier: "zh_CN")
        let dFormat = format.rawValue.replacingOccurrences(of: "-", with: joint)
        formatter.dateFormat = dFormat
        let date = formatter.string(from: date)
        return date
    }
}


#endif
