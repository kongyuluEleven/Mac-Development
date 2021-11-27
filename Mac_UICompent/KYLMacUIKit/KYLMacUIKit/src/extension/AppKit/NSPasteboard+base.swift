//
//  NSPasteboard+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - 属性

extension NSPasteboard.PasteboardType {
    /// 如果你在粘贴板上放了一个URL，那就是URL的名称。
    static let urlName = Self("public.url-name")
}

extension NSPasteboard.PasteboardType {
    /**
     获取源应用的bundle标识符的约定。

    > 这个标记的存在表明内容的来源是具有与其UTF-8字符串内容匹配的bundle标识符的应用程序。
     例如:“pasteboard.setString(“com.sindresorhus。Foo”forType:“org.nspasteboard.source”)”。当源代码不是前台应用程序时，这很有用。这意味着将显示给用户的支持应用程序仅为信息的目的。请注意，空字符串是一个有效值，如下所述。
    > - http://nspasteboard.org
    */
    static let sourceAppBundleIdentifier = Self("org.nspasteboard.source")
}


public extension NSPasteboard {
    /**
     向粘贴板添加一个标记，指示哪个应用程序将当前数据放置在粘贴板上。

     这有助于剪贴板管理器识别源应用程序。

    - Important: 所有的pasteboard操作都应该调用这个，除非你使用' nspasteboard# with '。

    Read more: http://nspasteboard.org
    */
    func setSourceApp() {
        setString(Bundle.id, forType: .sourceAppBundleIdentifier)
    }
}

public extension NSPasteboard {
    /**
     开始一个新的纸板写作会话。在给定的闭包中执行所有的写操作。

     它负责为你调用' nspasteboard# clearContents() '，并为源应用添加一个标记(' nspasteboard# setSourceApp() ')。

    ```
    NSPasteboard.general.with {
        $0.setString("Unicorn", forType: .string)
    }
    ```
    */
    func with(_ callback: (NSPasteboard) -> Void) {
        clearContents()
        callback(self)
        setSourceApp()
    }
}


public extension NSPasteboard {
    /// 从拖放的文件中获取文件的url。
    func fileURLs(types: [String] = []) -> [URL] {
        var options: [ReadingOptionKey: Any] = [
            .urlReadingFileURLsOnly: true
        ]

        if !types.isEmpty {
            options[.urlReadingContentsConformToTypes] = types
        }

        guard
            let urls = readObjects(forClasses: [NSURL.self], options: options) as? [URL]
        else {
            return []
        }

        return urls
    }
}


#endif
