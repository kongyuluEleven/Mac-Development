//
//  Data+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

// MARK: - Properties

public extension Data {
    /// 返回二进制字节码
    var bytes: [UInt8] {
        // http://stackoverflow.com/questions/38097710/swift-3-changes-for-getbytes-method
        return [UInt8](self)
    }
}

// MARK: - Methods

public extension Data {
    /// 字符串通过使用给定的编码来编码数据
    ///
    /// - Parameter encoding: 编码格式.
    /// - Returns: 字符串通过使用给定的编码来编码数据
    func string(encoding: String.Encoding) -> String? {
        return String(data: self, encoding: encoding)
    }

    /// 从给定的JSON数据返回一个基础对象
    ///
    /// - Parameter options: 用于读取JSON数据和创建Foundation对象的选项。
    ///
    ///   For possible values, see `JSONSerialization.ReadingOptions`.
    /// - Returns: 接收端JSON数据中的Foundation对象，如果出现错误则为' nil '。
    /// - Throws: 如果接收端没有表示一个有效的JSON对象，则输入' NSError '。
    func jsonObject(options: JSONSerialization.ReadingOptions = []) throws -> Any {
        return try JSONSerialization.jsonObject(with: self, options: options)
    }
}


#endif
