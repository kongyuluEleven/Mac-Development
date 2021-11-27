//
//  NSButton+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit


// MARK: - Methods

public extension NSButton {
    
    /// 设置按钮标题
    /// - Parameters:
    ///   - text: 标题
    ///   - normalColor: 正常颜色
    ///   - alterColor: 按下颜色
    ///   - fontSize: 标题字体大小
    func setTitle(_ text: String,
                  normalColor: NSColor = NSColor(red: 205/255.0, green: 213/255.0, blue: 221/255.0, alpha: 1),
                  alterColor: NSColor = .white, fontSize:Int? = 12) {
        title = text
        setTitleColor(normalColor: normalColor, alterColor: alterColor, fontSize: fontSize)
    }
    
    
    /// 设置标题颜色
    /// - Parameters:
    ///   - normalColor: 正常颜色
    ///   - alterColor: 点击颜色
    ///   - fontSize: 字体大小
    func setTitleColor(normalColor:NSColor, alterColor:NSColor, fontSize:Int?) {
        var attrTitle = NSMutableAttributedString(attributedString:self.attributedTitle)
        var len = attrTitle.length
        var range = NSMakeRange(0, len)
        attrTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: normalColor, range: range)
        if let fontSize = fontSize {
            let font = NSFont.systemFont(ofSize: CGFloat(fontSize))
            attrTitle.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        }
        
        attrTitle.fixAttachmentAttribute(in: range)
        self.attributedTitle = attrTitle
        
        let title = self.attributedAlternateTitle.length == 0 ? self.attributedTitle : self.attributedAlternateTitle
        attrTitle = NSMutableAttributedString(attributedString: title)
        len = attrTitle.length
        range = NSMakeRange(0, len)
        attrTitle.addAttribute(NSAttributedString.Key.foregroundColor, value: alterColor, range: range)
        if let fontSize = fontSize {
            let font = NSFont.systemFont(ofSize: CGFloat(fontSize))
            attrTitle.addAttribute(NSAttributedString.Key.font, value: font, range: range)
        }
        attrTitle.fixAttributes(in: range)
        self.attributedAlternateTitle = attrTitle
    }
    
    func addAction(_ action: Selector, target: AnyObject) {
        self.action = action
        self.target = target
    }
}

#endif
