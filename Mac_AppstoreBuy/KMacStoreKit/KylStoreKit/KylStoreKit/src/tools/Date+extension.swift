//
//  Date+extension.swift
//  KylStoreKit
//
//  Created by kongyulu on 2021/11/26.
//

import Cocoa

public extension Date {
    /// Date转换为字符串
    /// - Parameters:
    ///   - dateFormat: 时间格式，默认："yyyy-MM-dd HH:mm:ss"
    /// - Returns: 时间字符串
    func toString(dateFormat: String="yyyy-MM-dd HH:mm:ss") -> String {
        let timeZone = TimeZone.init(identifier: "Asia/Beijing")
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.locale = Locale.init(identifier: "zh_CN")
        formatter.dateFormat = dateFormat
        let date = formatter.string(from: self)
        return date
    }
}
