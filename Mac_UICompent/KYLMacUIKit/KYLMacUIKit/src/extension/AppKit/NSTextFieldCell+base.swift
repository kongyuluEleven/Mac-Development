//
//  NSTextFieldCell+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - 属性

public extension NSTextFieldCell {
    
}

// MARK: - Methods

public extension NSTextFieldCell {
    /// 用text初始化一个NSTextField
    convenience init(text: String?) {
        self.init()
        self.stringValue = text ?? ""
    }
    
    /// 当前是否处于编辑状态
    /// - Returns: 返回当前是否处于编辑状态
    func isEditing() -> Bool {
        if let isEdit = (self.controlView as? NSTextField)?.isEditing() {
            return isEdit
        }
        return false
    }
}

#endif
