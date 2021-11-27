//
//  Character+Extension.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

// MARK: - 属性

public extension Character {
    /// 检查字符是否是表情符号。
    ///
    ///        Character("😀").isEmoji -> true
    ///
    var isEmoji: Bool {
        // http://stackoverflow.com/questions/30757193/find-out-if-character-in-string-is-emoji
        let scalarValue = String(self).unicodeScalars.first!.value
        switch scalarValue {
        case 0x1F600...0x1F64F, // Emoticons
             0x1F300...0x1F5FF, // Misc Symbols and Pictographs
             0x1F680...0x1F6FF, // Transport and Map
             0x1F1E6...0x1F1FF, // Regional country flags
             0x2600...0x26FF, // Misc symbols
             0x2700...0x27BF, // Dingbats
             0xE0020...0xE007F, // Tags
             0xFE00...0xFE0F, // Variation Selectors
             0x1F900...0x1F9FF, // Supplemental Symbols and Pictographs
             127_000...127_600, // Various asian characters
             65024...65039, // Variation selector
             9100...9300, // Misc items
             8400...8447: // Combining Diacritical Marks for Symbols
            return true
        default:
            return false
        }
    }

    /// character的整数(如果适用)。
    ///
    ///        Character("1").int -> 1
    ///        Character("A").int -> nil
    ///
    var int: Int? {
        return Int(String(self))
    }

    /// 从字符转换为字符串。
    ///
    ///        Character("a").string -> "a"
    ///
    var string: String {
        return String(self)
    }

    /// 以小写字母返回字符。
    ///
    ///        Character("A").lowercased -> Character("a")
    ///
    var lowercased: Character {
        return String(self).lowercased().first!
    }

    /// 返回大写字符。
    ///
    ///        Character("a").uppercased -> Character("A")
    ///
    var uppercased: Character {
        return String(self).uppercased().first!
    }
    
    /// 简单的emoji是一个标量，以emoji的形式呈现给用户
    ///
    ///        Character("😀").isEmoji -> true
    ///
    var isSimpleEmoji: Bool {
        guard let firstProperties = unicodeScalars.first?.properties else{
            return false
        }
        if #available(OSX 10.12.2, *) {
            return unicodeScalars.count == 1 &&
                ( firstProperties.isEmojiPresentation ||
                    firstProperties.generalCategory == .otherSymbol)
        } else {
            // Fallback on earlier versions
            return unicodeScalars.count == 1 &&
            (firstProperties.generalCategory == .otherSymbol)
        }
    }

    /// 检查标量是否将合并到emoji中
    var isCombinedIntoEmoji: Bool {
        return unicodeScalars.count > 1 &&
            unicodeScalars.contains { $0.properties.isJoinControl || $0.properties.isVariationSelector }
    }
}

extension CharacterSet {
    /// URL中允许不转义的字符
    /// https://tools.ietf.org/html/rfc3986#section-2.3
    static let urlUnreservedRFC3986 = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
}


// MARK: - 方法

public extension Character {
    /// 生成一个随机字符
    ///
    ///    Character.random() -> k
    ///
    /// - Returns: 返回一个随机字符。
    static func randomAlphanumeric() -> Character {
        return "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".randomElement()!
    }
}


// MARK: - 操作符

public extension Character {
    /// 重复字符多次
    ///
    ///        Character("-") * 10 -> "----------"
    ///
    /// - Parameters:
    ///   - lhs: 需要重复的字符
    ///   - rhs: 字符重复的次数
    /// - Returns: 字符重复n次的字符串。
    static func * (lhs: Character, rhs: Int) -> String {
        guard rhs > 0 else { return "" }
        return String(repeating: String(lhs), count: rhs)
    }

    /// 重复字符多次。
    ///
    ///        10 * Character("-") -> "----------"
    ///
    /// - Parameters:
    ///   - lhs: 重复字符的次数。
    ///   - rhs: 需要重复的字符。
    /// - Returns: 字符重复n次的字符串。
    static func * (lhs: Int, rhs: Character) -> String {
        guard lhs > 0 else { return "" }
        return String(repeating: String(rhs), count: lhs)
    }
}
