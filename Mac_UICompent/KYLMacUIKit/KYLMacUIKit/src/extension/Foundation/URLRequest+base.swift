//
//  URLRequest+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - 网络请求相关扩展

public extension URLRequest {
    /// 构造函数，使用URL创建一个URLRequest对象
    ///
    /// - Parameter urlString: 初始化URL请求的URL字符串
    init?(urlString: String) {
        guard let url = URL(string: urlString) else { return nil }
        self.init(url: url)
    }

    /// cURL命令表示此URL请求。
    var curlString: String {
        guard let url = url else { return "" }

        var baseCommand = "curl \(url.absoluteString)"
        if httpMethod == "HEAD" {
            baseCommand += " --head"
        }

        var command = [baseCommand]
        if let method = httpMethod, method != "GET", method != "HEAD" {
            command.append("-X \(method)")
        }

        if let headers = allHTTPHeaderFields {
            for (key, value) in headers where key != "Cookie" {
                command.append("-H '\(key): \(value)'")
            }
        }

        if let data = httpBody,
            let body = String(data: data, encoding: .utf8) {
            command.append("-d '\(body)'")
        }

        return command.joined(separator: " \\\n\t")
    }
}

#endif
