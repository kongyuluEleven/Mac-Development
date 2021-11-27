//
//  NSError+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation) && !os(Linux)
import Foundation

public extension Error {
    var isNsError: Bool { Self.self is NSError.Type }
}


public extension NSError {
    
    /// 构造一个NSError错误对象，由Error转换为NSError
    /// - Parameters:
    ///   - error: Error 对象
    ///   - userInfo: 附加信息
    /// - Returns: NSError对象
    static func from(error: Error, userInfo: [String: Any] = [:]) -> NSError {
        let nsError = error as NSError

        // 因为Error和NSError通常是相互连接的，我们会检查它是否最初是一个NSError，然后返回它。
        guard !error.isNsError else {
            guard !userInfo.isEmpty else {
                return nsError
            }

            return nsError.appending(userInfo: userInfo)
        }

        var userInfo = userInfo
        userInfo[NSLocalizedDescriptionKey] = error.localizedDescription

        // 这是需要的，因为' localizedDescription '经常缺少重要信息，例如，当一个NSError被封装在Swift.Error中。
        userInfo["Swift.Error"] = "\(nsError.domain).\(error)"

        // 这得到的错误。generateFrameFailed“从”错误。generateFrameFailed(Error Domain=AVFoundationErrorDomain Code=-11832[…]');
        let errorName = "\(error)".split(separator: "(").first ?? ""

        return .init(
            domain: "\(Bundle.id) - \(nsError.domain)\(errorName.isEmpty ? "" : ".")\(errorName)",
            code: nsError.code,
            userInfo: userInfo
        )
    }

    /// 返回附加了用户信息的新错误。
    func appending(userInfo newUserInfo: [String: Any]) -> Self {
        .init(
            domain: domain,
            code: code,
            userInfo: userInfo.appending(newUserInfo)
        )
    }
}


public extension NSError {

    /// 错误构造函数，用这个来处理一般的应用错误。
    /// - Parameters:
    ///   - description: 错误的描述。这显示在错误对话框的第一行。
    ///   - recoverySuggestion: 解释用户如何从错误中恢复。例如，“尝试选择一个不同的目录”。这通常显示在错误对话框的第二行。
    ///   - userInfo: 添加到错误中的元数据。可以是一个自定义键或任何NSLocalizedDescriptionKey键，
    ///   除了NSLocalizedDescriptionKey和nslocalizedrecovery建议errorkey。
    ///   - domainPostfix:  附加到“域”的字符串，以便更容易地识别错误。域是应用程序的bundle标识符。
    /// - Returns: NSError对象
    static func appError(
        _ description: String,
        recoverySuggestion: String? = nil,
        userInfo: [String: Any] = [:],
        domainPostfix: String? = nil
    ) -> Self {
        var userInfo = userInfo
        userInfo[NSLocalizedDescriptionKey] = description

        if let recoverySuggestion = recoverySuggestion {
            userInfo[NSLocalizedRecoverySuggestionErrorKey] = recoverySuggestion
        }

        return .init(
            domain: domainPostfix.map { "\(Bundle.id) - \($0)" } ?? Bundle.id,
            code: 1,
            userInfo: userInfo
        )
    }
}

#endif
