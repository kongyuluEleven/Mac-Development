//
//  NSView+skin.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public extension NSView {

    /// 返回匹配指定类的第一个子视图。
    @objc func deepSubview(withClassName className: String) -> NSView? {

        // 搜索级别以下(查看子视图)
        for subview: NSView in self.subviews where subview.className == className {
            return subview
        }

        // 搜索更深
        for subview: NSView in self.subviews {
            if let foundView = subview.deepSubview(withClassName: className) {
                return foundView
            }
        }

        return nil
    }

}

#endif
