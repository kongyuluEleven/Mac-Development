//
//  NSAttributed+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

// MARK: - 属性

public extension NSAttributedString {
    
    /// 获取nsRange
    var nsRange: NSRange { NSRange(0..<length) }

    /// 获取字体
    var font: NSFont {
        attributeForWholeString(.font) as? NSFont ?? .systemFont(ofSize: NSFont.systemFontSize)
    }

    /// 如果属性适用于整个字符串，则获取该属性。
    func attributeForWholeString(_ key: Key) -> Any? {
        guard length > 0 else {
            return nil
        }

        var foundRange = NSRange()
        let result = attribute(key, at: 0, longestEffectiveRange: &foundRange, in: nsRange)

        guard foundRange.length == length else {
            return nil
        }

        return result
    }

    /// Returns a `NSMutableAttributedString` version.
    func mutable() -> NSMutableAttributedString {
        // 强制转换在这里是安全的，因为它只能是nil如果没有mutableCopy实现，但我们知道有NSMutableAttributedString。
        // swiftlint:disable:next force_cast
        mutableCopy() as! NSMutableAttributedString
    }
    
    /// 追加一组属性
    /// - Parameter attributes: 属性字典
    /// - Returns: 返回追加了属性设置的富文本
    func addingAttributes(_ attributes: [Key: Any]) -> NSAttributedString {
        let new = mutable()
        new.addAttributes(attributes, range: nsRange)
        return new
    }

    
    /// 追加设置颜色属性
    /// - Parameter color: 要设置的文字颜色
    /// - Returns: 返回追加了颜色设置的富文本
    func withColor(_ color: NSColor) -> NSAttributedString {
        addingAttributes([.foregroundColor: color])
    }

    
    /// 追加字体设置属性，
    /// - Parameter fontSize: 文字的字体
    /// - Returns: 返回追加设置了字体的富文本
    func withFontSize(_ fontSize: Double) -> NSAttributedString {
        return addingAttributes([.font: NSFont.systemFont(ofSize: CGFloat(fontSize))])
    }
}
// MARK: - 属性

public extension NSAttributedString {
    /// 粗体字符串使用系统字体。
    #if !os(Linux)
    var bolded: NSAttributedString {
        guard !string.isEmpty else { return self }

        let pointSize: CGFloat
        if let font = attribute(.font, at: 0, effectiveRange: nil) as? NSFont {
            pointSize = font.pointSize
        } else {
            #if os(tvOS) || os(watchOS)
            pointSize = Font.preferredFont(forTextStyle: .headline).pointSize
            #else
            pointSize = NSFont.systemFontSize
            #endif
        }
        return applying(attributes: [.font: NSFont.boldSystemFont(ofSize: pointSize)])
    }
    #endif

    #if !os(Linux)
    /// 下划线字符串.
    var underlined: NSAttributedString {
        return applying(attributes: [.underlineStyle: NSUnderlineStyle.single.rawValue])
    }
    #endif

    #if canImport(UIKit)
    /// 使用系统字体的斜体字符串。
    var italicized: NSAttributedString {
        guard !string.isEmpty else { return self }

        let pointSize: CGFloat
        if let font = attribute(.font, at: 0, effectiveRange: nil) as? UIFont {
            pointSize = font.pointSize
        } else {
            #if os(tvOS) || os(watchOS)
            pointSize = UIFont.preferredFont(forTextStyle: .headline).pointSize
            #else
            pointSize = UIFont.systemFontSize
            #endif
        }
        return applying(attributes: [.font: UIFont.italicSystemFont(ofSize: pointSize)])
    }
    #endif

    #if !os(Linux)
    /// Struckthrough字符串。
    var struckthrough: NSAttributedString {
        return applying(attributes: [.strikethroughStyle: NSNumber(value: NSUnderlineStyle.single.rawValue)])
    }
    #endif

    /// 字符串应用的属性的字典
    var attributes: [Key: Any] {
        guard length > 0 else { return [:] }
        return attributes(at: 0, effectiveRange: nil)
    }
}

// MARK: - 方法

public extension NSAttributedString {
    /// 应用给定的属性到用self object初始化的NSAttributedString的新实例
    ///
    /// - Parameter attributes: 字典的属性
    /// - Returns: 带有应用属性的NSAttributedString
    func applying(attributes: [Key: Any]) -> NSAttributedString {
        guard !string.isEmpty else { return self }

        let copy = NSMutableAttributedString(attributedString: self)
        copy.addAttributes(attributes, range: NSRange(0..<length))
        return copy
    }

    #if canImport(AppKit) || canImport(UIKit)
    /// 为富文本添加颜色。
    ///
    /// - Parameter color: 文字颜色
    /// - Returns: 一个带有给定颜色的富文本。
    func colored(with color: NSColor) -> NSAttributedString {
        return applying(attributes: [.foregroundColor: color])
    }
    #endif

    /// 将属性应用于匹配正则表达式的子字符串
    ///
    /// - Parameters:
    ///   - attributes: 字典的属性
    ///   - pattern: 目标的正则表达式
    ///   - options: 匹配过程中应用于表达式的正则表达式选项. 可以参考NSRegularExpression的可选项
    /// - Returns: 一个富文本对象，它的属性应用于匹配模式的子字符串
    func applying(attributes: [Key: Any],
                  toRangesMatching pattern: String,
                  options: NSRegularExpression.Options = []) -> NSAttributedString {
        guard let pattern = try? NSRegularExpression(pattern: pattern, options: options) else { return self }

        let matches = pattern.matches(in: string, options: [], range: NSRange(0..<length))
        let result = NSMutableAttributedString(attributedString: self)

        for match in matches {
            result.addAttributes(attributes, range: match.range)
        }

        return result
    }

    /// 将属性应用于给定字符串的出现
    ///
    /// - Parameters:
    ///   - attributes: 字典的属性
    ///   - target: 要应用的属性的子序列字符串
    /// - Returns: 一个应用于目标字符串的属性的富文本
    func applying<T: StringProtocol>(attributes: [Key: Any],
                                     toOccurrencesOf target: T) -> NSAttributedString {
        let pattern = "\\Q\(target)\\E"

        return applying(attributes: attributes, toRangesMatching: pattern)
    }
}

// MARK: - 操作符

public extension NSAttributedString {
    /// 两个富文本相加，相当于拼接两个字符串
    ///
    /// - Parameters:
    ///   - lhs: 添加到的富文本。
    ///   - rhs: 被添加的富文本
    static func += (lhs: inout NSAttributedString, rhs: NSAttributedString) {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        lhs = string
    }

    /// 把一个富文本添加到另一个富文本中，并返回一个新的NSAttributedString实例。
    ///
    /// - Parameters:
    ///   - lhs: 添加到的富文本。
    ///   - rhs: 被添加的富文本
    /// - Returns: New instance with added NSAttributedString.
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let string = NSMutableAttributedString(attributedString: lhs)
        string.append(rhs)
        return NSAttributedString(attributedString: string)
    }

    /// 把一个字符串添加到另一个富文本中，被添加的富文本以参数的形式传回，没有返回值
    ///
    /// - Parameters:
    ///   - lhs: 添加到的富文本。
    ///   - rhs: 被添加的字符串
    static func += (lhs: inout NSAttributedString, rhs: String) {
        lhs += NSAttributedString(string: rhs)
    }

    /// 把一个字符串添加到另一个富文本中，并返回一个新的富文本实例。
    ///
    /// - Parameters:
    ///   - lhs: 添加到的富文本。
    ///   - rhs: 被添加的字符串
    /// - Returns: 添加了NSAttributedString的新实例。
    static func + (lhs: NSAttributedString, rhs: String) -> NSAttributedString {
        return lhs + NSAttributedString(string: rhs)
    }
}

#endif
