//
//  URL+bookmark.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

//  沙盒bookmark权限保存，访问操作

#if canImport(Cocoa)
import Cocoa
import AppKit

public extension URL {
    /// 当在沙箱应用程序中被调用时，返回用户的真实主目录。
    static let realHomeDirectory = Self(
        fileURLWithFileSystemRepresentation: getpwuid(getuid())!.pointee.pw_dir!,
        isDirectory: true,
        relativeTo: nil
    )

    /// 确保URL指向最近的目录(如果是文件或self)。
    var directoryURL: Self { hasDirectoryPath ? self : deletingLastPathComponent() }

    var tildePath: String {
        // 注意:这里不能使用' FileManager.default.homeDirectoryForCurrentUser.relativePath '或' NSHomeDirectory() '，因为它们返回的是沙箱主目录，而不是真正的主目录。
        path.replacingPrefix(Self.realHomeDirectory.path, with: "~")
    }

    var exists: Bool { FileManager.default.fileExists(atPath: path) }
}


/// 这总是请求对目录的权限。如果您给它文件URL，它将请求父目录的权限。
public enum SecurityScopedBookmarkManager {
    private static let lock = NSLock()

    // TODO: 将它抽象为一个泛型类，有一个类似于UserDefaults的字典，它的子类在这里。
    private final class BookmarksUserDefaults {

        private let userDefaultsKey = "__securityScopedBookmarks__" //Defaults.Key<[String: Data]>("__securityScopedBookmarks__", default: [:])

        private var bookmarkStore: [String: Data] {
            get {
                var isStale = false
                if let data = UserDefaults.standard.object(forKey: userDefaultsKey) as? Data,
                    let url = try? URL.init(resolvingBookmarkData: data, options: .withSecurityScope,
                                            relativeTo: nil,
                                            bookmarkDataIsStale: &isStale) {
                    _ = url.startAccessingSecurityScopedResource()
                    return [url.path:data]
                }
                return [String: Data]()
            }
            set {
                UserDefaults.standard.set(newValue, forKey: userDefaultsKey)
                UserDefaults.standard.synchronize()
            }
        }

        subscript(url: URL) -> Data? {
            // TODO: Should it really be resolving symlinks?
            get { bookmarkStore[url.resolvingSymlinksInPath().absoluteString] }
            set {
                var bookmarks = bookmarkStore
                bookmarks[url.resolvingSymlinksInPath().absoluteString] = newValue
                bookmarkStore = bookmarks
            }
        }
    }

    private final class NSOpenSavePanelDelegateHandler: NSObject, NSOpenSavePanelDelegate {
        let currentURL: URL

        init(url: URL) {
            // It's important to resolve symlinks so it doesn't use the sandbox URL.
            self.currentURL = url.resolvingSymlinksInPath()
            super.init()
        }

        /*
         我们只允许这个目录
         你可能认为我们可以使用' didChangeToDirectoryURL '和设置' sender。directoryURL = currentURL '那里，但那不工作。打开面板后，不能以编程方式更改目录。
        */
        func panel(_ sender: Any, shouldEnable url: URL) -> Bool {
            url == currentURL
        }
    }

    private static var bookmarks = BookmarksUserDefaults()

    /// 保存 bookmark.
    static func saveBookmark(for url: URL) throws {
        bookmarks[url] = try url.accessSecurityScopedResource {
            try $0.bookmarkData(options: .withSecurityScope)
        }
    }

    /// 加载bookmark
    /// 如果给定的URL没有书签或者书签不能被加载，返回' nil '。
    static func loadBookmark(for url: URL) -> URL? {
        guard let bookmarkData = bookmarks[url] else {
            return nil
        }

        var isBookmarkDataStale = false

        guard
            let newUrl = try? URL(
                resolvingBookmarkData: bookmarkData,
                options: .withSecurityScope,
                bookmarkDataIsStale: &isBookmarkDataStale
            )
        else {
            return nil
        }

        if isBookmarkDataStale {
            guard (try? saveBookmark(for: newUrl ?? url)) != nil else {
                return nil
            }
        }

        return newUrl
    }

    /// 返回' nil '如果用户没有给予许可或如果书签不能保存。
    static func promptUserForPermission(atDirectory directoryURL: URL, message: String? = nil) -> URL? {
        lock.lock()

        defer {
            lock.unlock()
        }

        let delegate = NSOpenSavePanelDelegateHandler(url: directoryURL)

        let userChosenURL: URL? = DispatchQueue.mainSafeSync {
            let openPanel = with(NSOpenPanel()) {
                $0.delegate = delegate
                $0.directoryURL = directoryURL
                $0.allowsMultipleSelection = false
                $0.canChooseDirectories = true
                $0.canChooseFiles = false
                $0.canCreateDirectories = false
                $0.title = "Permission"
                $0.message = message ?? "\(Bundle.name) needs access to the “\(directoryURL.lastPathComponent)” directory. Click “Allow” to proceed."
                $0.prompt = "Allow"
            }

            NSApp.activate(ignoringOtherApps: true)

            guard openPanel.runModal() == .OK else {
                return nil
            }

            return openPanel.url
        }

        guard let securityScopedURL = userChosenURL else {
            return nil
        }

        do {
            try saveBookmark(for: securityScopedURL)
        } catch {
            NSApp.presentError(error)
            return nil
        }

        return securityScopedURL
    }

    /// 访问给定闭包中的URL，然后清理访问。
    /// 闭包接收一个URL是否可访问的布尔值。
    static func accessURL(_ url: URL, accessHandler: () throws -> Void) rethrows {
        _ = url.startAccessingSecurityScopedResource()

        defer {
            url.stopAccessingSecurityScopedResource()
        }

        try accessHandler()
    }

    /// 接受到目录或文件的文件URL。如果它是一个文件，它将提示对其包含的目录的权限。
    /// 它为您处理清除对URL的访问。
    static func accessURLByPromptingIfNeeded(_ url: URL, accessHandler: () throws -> Void) {
        let directoryURL = url.directoryURL

        guard let securityScopedURL = loadBookmark(for: directoryURL) ?? promptUserForPermission(atDirectory: directoryURL) else {
            return
        }

        do {
            try accessURL(securityScopedURL, accessHandler: accessHandler)
        } catch {
            NSApp.presentError(error)
            return
        }
    }

    /// 接受到目录或文件的文件URL。如果它是一个文件，它将提示对其包含的目录的权限。
    /// 当您不再需要访问URL时，您必须手动调用返回的方法。
    @discardableResult
    static func accessURLByPromptingIfNeeded(_ url: URL) -> (() -> Void) {
        let directoryURL = url.directoryURL

        guard let securityScopedURL = loadBookmark(for: directoryURL) ?? promptUserForPermission(atDirectory: directoryURL) else {
            return {}
        }

        _ = securityScopedURL.startAccessingSecurityScopedResource()

        return {
            securityScopedURL.stopAccessingSecurityScopedResource()
        }
    }
}

public extension URL {
    /// 接受到目录或文件的文件URL。如果它是一个文件，它将提示对其包含的目录的权限。
    /// 它为您处理清除对URL的访问。
    func accessSandboxedURLByPromptingIfNeeded(accessHandler: () throws -> Void) {
        SecurityScopedBookmarkManager.accessURLByPromptingIfNeeded(self, accessHandler: accessHandler)
    }

    /// 接受到目录或文件的文件URL。如果它是一个文件，它将提示对其包含的目录的权限。
    /// 当您不再需要访问URL时，您必须手动调用返回的方法。
    func accessSandboxedURLByPromptingIfNeeded() -> (() -> Void) {
        SecurityScopedBookmarkManager.accessURLByPromptingIfNeeded(self)
    }
}



// MARK: - URL
public extension URL {
    func addingDictionaryAsQuery(_ dict: [String: String]) -> Self {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)!
        components.addDictionaryAsQuery(dict)
        return components.url ?? self
    }
    
    /// `URLComponents有比' URL '更好的解析和支持
    /// things like `scheme:path` (notice the missing `//`).
    var components: URLComponents? {
        URLComponents(url: self, resolvingAgainstBaseURL: true)
    }
    
    /// 从字符串创建URL。
    ///
    /// URL(humanString: "sindresorhus.com")?.absoluteString
    ///   => "http://sindresorhus.com"
    ///
    /// - Parameter humanString: 地址字符串
    init?(humanString: String) {
        let string = humanString.trimmed

        guard !string.isEmpty else {
            return nil
        }

        let url = string.replacingOccurrences(of: #"^(?!(?:\w+:)?\/\/)"#, with: "http://", options: .regularExpression)

        self.init(string: url)
    }
    
    enum PlaceholderError: LocalizedError {
        case failedToEncodePlaceholder(String)
        case invalidURLAfterSubstitution(String)

        public var errorDescription: String? {
            switch self {
            case .failedToEncodePlaceholder(let placeholder):
                return "Failed to encode placeholder “\(placeholder)”"
            case .invalidURLAfterSubstitution(let urlString):
                return "New URL was not valid after substituting placeholders. URL string is “\(urlString)”"
            }
        }
    }

    /**
     将URL中出现的' placeholder '替换为' replace '。

    - Throws: 如果无法对占位符进行编码，或者替换将创建无效URL，则会出现错误。
    */
    func replacingPlaceholder(_ placeholder: String, with replacement: String) throws -> URL {
        guard
            let encodedPlaceholder = placeholder.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)
        else {
            throw PlaceholderError.failedToEncodePlaceholder(placeholder)
        }

        let urlString = absoluteString
            .replacingOccurrences(of: encodedPlaceholder, with: replacement)

        guard let newURL = URL(string: urlString) else {
            throw PlaceholderError.invalidURLAfterSubstitution(urlString)
        }

        return newURL
    }
}

public extension URL {
    /// 规范化URL
    ///
    ///  URL("https://sindresorhus.com/?").normalized()
    /// =>  "https://sindresorhus.com"
    ///
    /// - Parameters:
    ///   - removeFragment: removeFragment description
    ///   - removeQuery: removeQuery description
    /// - Returns: 返回处理过的合规URL
    func normalized(
        removeFragment: Bool = false,
        removeQuery: Bool = false
    ) -> Self {
        let url = absoluteURL.standardized

        guard var components = url.components else {
            return self
        }

        if components.path == "/" {
            components.path = ""
        }

        // Remove port 80 if it's there as it's the default.
        if components.port == 80 {
            components.port = nil
        }

        // Lowercase host and scheme.
        components.host = components.host?.lowercased()
        components.scheme = components.scheme?.lowercased()

        // Remove empty fragment.
        // - `https://sindresorhus.com/#`
        if components.fragment?.isEmpty == true {
            components.fragment = nil
        }

        // Remove empty query.
        // - `https://sindresorhus.com/?`
        if components.query?.isEmpty == true {
            components.query = nil
        }

        if removeFragment {
            components.fragment = nil
        }

        if removeQuery {
            components.query = nil
        }

        return components.url ?? self
    }
}


public extension URL {
    /**
     访问安全范围的资源。
     访问将在给定的'访问器'的作用域结束时自动放弃。
    - 重要提示:不要在' accessor '中做任何异步操作，因为资源访问仅在' accessor '范围内同步可用。
    */
    func accessSecurityScopedResource<Value>(_ accessor: (URL) throws -> Value) rethrows -> Value {
        let didStartAccessing = startAccessingSecurityScopedResource()

        defer {
            if didStartAccessing {
                stopAccessingSecurityScopedResource()
            }
        }

        return try accessor(self)
    }

    /**
     异步访问安全范围的资源。
     当' completion '闭包被调用时，访问将自动进行。

    ```
    directoryUrl.accessSecurityScopedResourceAsync { completion in
        startConversion(urls, outputDirectory: directoryUrl) {
            completion()
        }
    }
    ```
    */
    func accessSecurityScopedResourceAsync<Value>(_ accessor: (@escaping () -> Void) throws -> Value) rethrows -> Value {
        let didStartAccessing = startAccessingSecurityScopedResource()

        return try accessor {
            if didStartAccessing {
                self.stopAccessingSecurityScopedResource()
            }
        }
    }
}


private func escapeQuery(_ query: String) -> String {
    // From RFC 3986
    let generalDelimiters = ":#[]@"
    let subDelimiters = "!$&'()*+,;="

    var allowedCharacters = CharacterSet.urlQueryAllowed
    allowedCharacters.remove(charactersIn: generalDelimiters + subDelimiters)
    return query.addingPercentEncoding(withAllowedCharacters: allowedCharacters) ?? query
}



extension URLComponents {
    mutating func addDictionaryAsQuery(_ dict: [String: String]) {
        percentEncodedQuery = dict.asQueryString
    }
}


// MARK: - Dictionary
extension Dictionary where Key: ExpressibleByStringLiteral, Value: ExpressibleByStringLiteral {
    var asQueryItems: [URLQueryItem] {
        map {
            URLQueryItem(
                name: escapeQuery($0 as! String),
                value: escapeQuery($1 as! String)
            )
        }
    }

    var asQueryString: String {
        var components = URLComponents()
        components.queryItems = asQueryItems
        return components.query!
    }
}


#endif
