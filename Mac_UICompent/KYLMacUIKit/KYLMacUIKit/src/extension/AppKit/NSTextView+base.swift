//
//  NSTextView+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

//MARK: - 属性
public extension NSTextView {
    
    /// 字符串长度
    var length:Int {
        return self.string.count
    }
    
    /// 字符串范围
    var allRange:NSRange {
        return NSRange(location: 0, length: length)
    }
    
    /// 获取选中的字符串
    var selectedValue:String {
        let range = self.selectedRange()
        if range.length == 0 {
            return ""
        } else {
            return (string as NSString).substring(with: range)
        }
    }
    
}


//MARK: - 方法
public extension NSTextView {
    
    /// 设置默认字体颜色
    func setDefaultAttributes() {
        var attributes = self.typingAttributes
        attributes[NSAttributedString.Key.font] = self.font
        attributes[NSAttributedString.Key.foregroundColor] = textColor
        attributes[NSAttributedString.Key.backgroundColor] = backgroundColor
        
        self.typingAttributes = attributes
    }
    
    
    /// 清空所有选中的字符串
    /// - Parameter sender: 消息发送者
    @IBAction func unSelectAll(_ sender: Any) {
        deselectAll()
    }
    
    /// 清空所有选中的字符串
    func deselectAll() {
        var range = self.selectedRange()
        if range.length == 0 {return}
        range.length = 0
        self.setSelectedRange(range)
    }
    
    
    /// 在原来内容上追加字符串
    /// - Parameter string: 需要追加的字符串
    func append(string:String) {
        let attr = NSAttributedString.init(string: string, attributes: self.typingAttributes)
        self.textStorage?.append(attr)
    }
    
    
    /// 在原来的内容上追加富文本
    /// - Parameter attributedString: 需要追加的富文本
    func append(attributedString:NSAttributedString) {
        self.textStorage?.append(attributedString)
    }
    
}

#endif

