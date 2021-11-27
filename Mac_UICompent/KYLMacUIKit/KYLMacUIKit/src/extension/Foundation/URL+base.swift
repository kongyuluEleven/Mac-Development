//
//  URL+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Cocoa)
import Cocoa

// MARK: - Properties

public extension URL {
    /// URL查询参数字典
    var queryParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
            let queryItems = components.queryItems else { return nil }

        var items: [String: String] = [:]

        for queryItem in queryItems {
            items[queryItem.name] = queryItem.value
        }

        return items
    }
}

// MARK: - Initializers

public extension URL {
    /// UIKit:使用基本URL和相对字符串初始化“ URL”对象。 如果`string`格式错误，则返回`nil`
    /// - Parameters:
    ///   - string: 用于初始化“ URL”对象的URL字符串。 必须符合RFC2396。`string`相对于`url`进行解释。.
    ///   - url: URL对象的基本URL
    init?(string: String?, relativeTo url: URL? = nil) {
        guard let string = string else { return nil }
        self.init(string: string, relativeTo: url)
    }
}

// MARK: - Methods

public extension URL {
    
    /// UIKit: 添加查询参数的URL。
    ///
    ///        let url = URL(string: "https://google.com")!
    ///        let param = ["q": "Swifter Swift"]
    ///        url.appendingQueryParameters(params) -> "https://google.com?q=Swifter%20Swift"
    ///
    /// - Parameter parameters: 参数字典。
    /// - Returns: 带有给定查询参数的URL。
    func appendingQueryParameters(_ parameters: [String: String]) -> URL {
        var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + parameters
            .map { URLQueryItem(name: $0, value: $1) }
        return urlComponents.url!
    }

    /// UIKit: 将查询参数附加到URL。
    ///
    ///        var url = URL(string: "https://google.com")!
    ///        let param = ["q": "Swifter Swift"]
    ///        url.appendQueryParameters(params)
    ///        print(url) // prints "https://google.com?q=Swifter%20Swift"
    ///
    /// - Parameter parameters: 参数字典。
    mutating func appendQueryParameters(_ parameters: [String: String]) {
        self = appendingQueryParameters(parameters)
    }

    /// UIKit: 获取查询键的值。
    ///
    ///    var url = URL(string: "https://google.com?code=12345")!
    ///    queryValue(for: "code") -> "12345"
    ///
    /// - Parameter key: 查询值的键。
    func queryValue(for key: String) -> String? {
        return URLComponents(string: absoluteString)?
            .queryItems?
            .first(where: { $0.name == key })?
            .value
    }

    /// UIKit: 通过删除所有路径组件来返回新的URL。
    ///
    ///     let url = URL(string: "https://domain.com/path/other")!
    ///     print(url.deletingAllPathComponents()) // prints "https://domain.com/"
    ///
    /// - Returns: 已删除所有路径组件的URL。
    func deletingAllPathComponents() -> URL {
        var url: URL = self
        for _ in 0..<pathComponents.count - 1 {
            url.deleteLastPathComponent()
        }
        return url
    }

    /// UIKit: 从URL中删除所有路径组件。
    ///
    ///        var url = URL(string: "https://domain.com/path/other")!
    ///        url.deleteAllPathComponents()
    ///        print(url) // prints "https://domain.com/"
    mutating func deleteAllPathComponents() {
        for _ in 0..<pathComponents.count - 1 {
            deleteLastPathComponent()
        }
    }

    /// UIKit: 生成没有协议头部的新URL。
    ///
    ///        let url = URL(string: "https://domain.com")!
    ///        print(url.droppedScheme()) // prints "domain.com"
    func droppedScheme() -> URL? {
        if let scheme = scheme {
            let droppedScheme = String(absoluteString.dropFirst(scheme.count + 3))
            return URL(string: droppedScheme)
        }

        guard host != nil else { return self }

        let droppedScheme = String(absoluteString.dropFirst(2))
        return URL(string: droppedScheme)
    }
    
    /// UIKit: 比较两个网址
    func isSameWithURL(_ url: URL) -> Bool {
        if self == url {
            return true
        }
        if self.scheme?.lowercased() != url.scheme?.lowercased() {
            return false
        }
        if let host1 = self.host, let host2 = url.host {
            let whost1 = host1.hasPrefix("www.") ? host1 : "www." + host1
            let whost2 = host2.hasPrefix("www.") ? host2 : "www." + host2
            if whost1 != whost2 {
                return false
            }
        }
        let pathdelimiter = CharacterSet(charactersIn: "/")
        if self.path.lowercased().trimmingCharacters(in: pathdelimiter) != url.path.lowercased().trimmingCharacters(in: pathdelimiter) {
            return false
        }
        if (self as NSURL).port != (url as NSURL).port {
            return false
        }
        if self.query?.lowercased() != url.query?.lowercased() {
            return false
        }
        return true
    }
}


public extension URL {
    /// 打开url的链接
    func open() {
        NSWorkspace.shared.open(self)
    }
    
    /// 初始化一个string为URL
    ///
    ///  URL("https://sindresorhus.com")
    ///
    /// - Parameter staticString: 地址字符串
    init(_ staticString: StaticString) {
        self.init(string: "\(staticString)")!
    }
}

public extension String {
    /// 打开链接地址
    /// 例如："https://sindresorhus.com".openUrl()
    func openUrl() {
        URL(string: self)?.open()
    }
}


#endif
