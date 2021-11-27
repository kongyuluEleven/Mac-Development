//
//  NSDictionary+UserTheme.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
#endif

extension NSDictionary {

    // MARK: `NSRegularExpression` Initialization

    /// 用户主题变量的正则表达式($var)
    @objc static var varsRegExpr: NSRegularExpression? {
        do {
            return try NSRegularExpression(pattern: "(\\$[a-zA-Z0-9_\\-\\.]+)+", options: .caseInsensitive)
        } catch let error {
            print(error)
            return nil
        }
    }

    /// 用于用户主题颜色的正则表达式
    @objc static var colorRegExpr: NSRegularExpression? {
        do {
            return try NSRegularExpression(pattern: "(?:rgba?)?[\\s]?[\\(]?[\\s+]?(\\d+)[(\\s)|(,)]+[\\s+]?(\\d+)[(\\s)|(,)]+[\\s+]?(\\d+)[(\\s)|(,)]+[\\s+]?([0-1]?(?:\\.\\d+)?)", options: .caseInsensitive)
        } catch let error {
            print(error)
            return nil
        }
    }

    /// 用于用户主题渐变的正则表达式
    @objc static var linearGradRegExpr: NSRegularExpression? {
        do {
            return try NSRegularExpression(pattern: "linear-gradient\\(\\s*((?:rgba?)?[\\s]?[\\(]?[\\s+]?(\\d+)[(\\s)|(,)]+[\\s+]?(\\d+)[(\\s)|(,)]+[\\s+]?(\\d+)[(\\s)|(,)]*[\\s+]?([0-1]?(?:\\.\\d+)?)\\))\\s*,\\s*((?:rgba?)?[\\s]?[\\(]?[\\s+]?(\\d+)[(\\s)|(,)]+[\\s+]?(\\d+)[(\\s)|(,)]+[\\s+]?(\\d+)[(\\s)|(,)]*[\\s+]?([0-1]?(?:\\.\\d+)?)\\))\\s*\\)", options: .caseInsensitive)
        } catch let error {
            print(error)
            return nil
        }
    }

    /// 用于用户主题模式图像的正则表达式(NSColor)
    @objc static var patternRegExpr: NSRegularExpression? {
        do {
            return try NSRegularExpression(pattern: "pattern\\(((named):[\\s]*([\\w-\\. ]+)|(file):[\\s]*([\\w-\\. \\/]+))\\)", options: .caseInsensitive)
        } catch let error {
            print(error)
            return nil
        }
    }

    /// 用于用户主题图像的正则表达式
    @objc static var imageRegExpr: NSRegularExpression? {
        do {
            return try NSRegularExpression(pattern: "image\\(((named):[\\s]*([\\w-\\. ]+)|(file):[\\s]*([\\w-\\. \\/]+))\\)", options: .caseInsensitive)
        } catch let error {
            print(error)
            return nil
        }
    }

    // MARK: Evaluation

    /// 为指定的键计算对象作为主题资产(' NSColor '， ' NSGradient '， ' NSImage '，…)。
    @objc func evaluatedObject(key: String) -> AnyObject? {
        // Resolve any variables
        let stringValue = evaluatedString(key: key)

        // 评估为主题资源(NSColor, NSGradient, NSImage，…)
        return evaluatedObjectAsThemeAsset(value: stringValue as AnyObject)
    }

    // MARK: Internal evaluation functions

    /// 将指定的键计算为字符串的对象。
    private func evaluatedString(key: String) -> String? {
        guard let stringValue = self[key] as? String else {
            return nil
        }

        // Resolve any variables
        var evaluatedStringValue = stringValue
        var rangeOffset = 0
        NSDictionary.varsRegExpr?.enumerateMatches(in: stringValue,
                                                   options: NSRegularExpression.MatchingOptions(rawValue: UInt(0)),
                                                   range: NSRange(location: 0, length: stringValue.count),
                                                   using: { (match, _, _) in
            if let matchRange = match?.range(at: 1) {
                var range = matchRange
                range.location += rangeOffset

                // Extract variable
                let start = range.location + 1
                let end = start + range.length - 2
                guard start < evaluatedStringValue.count && end < evaluatedStringValue.count else { return }
                let variable = evaluatedStringValue[start..<end]

                // Evaluated value
                if let variableValue = evaluatedString(key: variable) {
                    evaluatedStringValue = evaluatedStringValue.replacingCharacters(inNSRange: range, with: variableValue)

                    // Move offset forward
                    rangeOffset = variableValue.count - range.length
                } else {
                    // Move offset forward
                    rangeOffset = range.length
                }
            }
        })

        return evaluatedStringValue
    }

    /// Evaluate object as theme asset (`NSColor`, `NSGradient`, `NSImage`, ...).
    private func evaluatedObjectAsThemeAsset(value: AnyObject) -> AnyObject? {
        guard let stringValue = value as? String else {
            // value is already evaluated as a non-string object
            return value
        }

        var evaluatedObject: AnyObject? = value

        // linear-gradient(color1, color2)
        if let match = NSDictionary.linearGradRegExpr?.firstMatch(in: stringValue, options: NSRegularExpression.MatchingOptions(rawValue: UInt(0)), range: NSRange(location: 0, length: stringValue.count)),
            match.numberOfRanges == 11 {

            // Starting color
            let red1 = (Float(stringValue.substring(withNSRange: match.range(at: 2))) ?? 255) / 255
            let green1 = (Float(stringValue.substring(withNSRange: match.range(at: 3))) ?? 255) / 255
            let blue1 = (Float(stringValue.substring(withNSRange: match.range(at: 4))) ?? 255) / 255
            let alpha1 = Float(stringValue.substring(withNSRange: match.range(at: 5))) ?? 1.0
            let color1 = NSColor(red: CGFloat(red1), green: CGFloat(green1), blue: CGFloat(blue1), alpha: CGFloat(alpha1))

            // Ending color
            let red2 = (Float(stringValue.substring(withNSRange: match.range(at: 7))) ?? 255) / 255
            let green2 = (Float(stringValue.substring(withNSRange: match.range(at: 8))) ?? 255) / 255
            let blue2 = (Float(stringValue.substring(withNSRange: match.range(at: 9))) ?? 255) / 255
            let alpha2 = Float(stringValue.substring(withNSRange: match.range(at: 10))) ?? 1.0
            let color2 = NSColor(red: CGFloat(red2), green: CGFloat(green2), blue: CGFloat(blue2), alpha: CGFloat(alpha2))

            // Gradient
            evaluatedObject = NSGradient(starting: color1, ending: color2)
        }

        // rgb/rgba color
        if evaluatedObject is String,
            let match = NSDictionary.colorRegExpr?.firstMatch(in: stringValue, options: NSRegularExpression.MatchingOptions(rawValue: UInt(0)), range: NSRange(location: 0, length: stringValue.count)),
            match.numberOfRanges == 5 {

            let red = (Float(stringValue.substring(withNSRange: match.range(at: 1))) ?? 255) / 255
            let green = (Float(stringValue.substring(withNSRange: match.range(at: 2))) ?? 255) / 255
            let blue = (Float(stringValue.substring(withNSRange: match.range(at: 3))) ?? 255) / 255
            let alpha = Float(stringValue.substring(withNSRange: match.range(at: 4))) ?? 1.0

            // Color
            evaluatedObject = NSColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: CGFloat(alpha))
        }

        // pattern
        if evaluatedObject is String,
            let match = NSDictionary.patternRegExpr?.firstMatch(in: stringValue, options: NSRegularExpression.MatchingOptions(rawValue: UInt(0)), range: NSRange(location: 0, length: stringValue.count)),
            match.numberOfRanges == 6 {

            let isNamedType = stringValue.substring(withNSRange: match.range(at: 2)) == "named"
            let imageName = stringValue.substring(withNSRange: match.range(at: 3))
            let isFileType = stringValue.substring(withNSRange: match.range(at: 4)) == "file"
            let imageFileName = stringValue.substring(withNSRange: match.range(at: 5))

            // Pattern image
            var pattern: NSImage
            if isNamedType {
                pattern = NSImage(named: NSImage.Name(imageName)) ?? NSImage(size: NSSize.zero)
            } else if isFileType, let imageURL = KYLThemeManager.shared.userThemesFolderURL?.appendingPathComponent(imageFileName) {
                pattern = NSImage(contentsOf: imageURL) ?? NSImage(size: NSSize.zero)
            } else {
                pattern = NSImage(size: NSSize.zero)
            }
            evaluatedObject = NSColor(patternImage: pattern)
        }

        // image
        if evaluatedObject is String,
            let match = NSDictionary.imageRegExpr?.firstMatch(in: stringValue, options: NSRegularExpression.MatchingOptions(rawValue: UInt(0)), range: NSRange(location: 0, length: stringValue.count)),
            match.numberOfRanges == 6 {

            let isNamedType = stringValue.substring(withNSRange: match.range(at: 2)) == "named"
            let imageName = stringValue.substring(withNSRange: match.range(at: 3))
            let isFileType = stringValue.substring(withNSRange: match.range(at: 4)) == "file"
            let imageFileName = stringValue.substring(withNSRange: match.range(at: 5))

            // Image
            if isNamedType {
                evaluatedObject = NSImage(named: NSImage.Name(imageName)) ?? NSImage(size: NSSize.zero)
            } else if isFileType, let imageURL = KYLThemeManager.shared.userThemesFolderURL?.appendingPathComponent(imageFileName) {
                evaluatedObject = NSImage(contentsOf: imageURL) ?? NSImage(size: NSSize.zero)
            } else {
                evaluatedObject = NSImage(size: NSSize.zero)
            }
        }

        return evaluatedObject
    }

}

fileprivate extension String {

    /// 使用下标与Int得到字符作为字符
    subscript (i: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: i)]
    }

    /// 使用下标与Int得到字符作为字符串
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }

    /// 用来获得子字符串Range<Int>而不是Range<Index>
    subscript (r: Range<Int>) -> String {
        let start = self.index(self.startIndex, offsetBy: r.lowerBound)
        let end = self.index(self.startIndex, offsetBy: r.upperBound)

        return String(self[start...end])
    }

    /// 用来获取带有NSRange的子字符串
    func substring(withNSRange: NSRange) -> String {
        guard withNSRange.location < self.count else { return "" }
        let start = self.index(self.startIndex, offsetBy: withNSRange.location)
        let end = self.index(start, offsetBy: withNSRange.length)
        let range = Range<String.Index>(uncheckedBounds: (lower: start, upper: end))
        return String(self[range])
    }

    /// 用NSRange替换字符
    func wsReplacingCharacters(inNSRange: NSRange, with: String) -> String {
        replacingCharacters(inNSRange: inNSRange, with: with)
    }
    
    /// Convenience function to replace characters with NSRange.
    func replacingCharacters(inNSRange: NSRange, with: String) -> String {
        guard inNSRange.location < self.count else { return "" }
        let start = self.index(self.startIndex, offsetBy: inNSRange.location)
        let end = self.index(start, offsetBy: inNSRange.length)
        let range = Range<String.Index>(uncheckedBounds: (lower: start, upper: end))
        return self.replacingCharacters(in: range, with: with)
    }

}

#endif
