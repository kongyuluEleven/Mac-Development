//
//  String+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

public extension StringProtocol where Self: RangeReplaceableCollection {
    var removingNewlines: Self {
        // TODO: Use `filter(!\.isNewline)` when key paths support negation.
        filter { !$0.isNewline }
    }
}

// MARK: - 多语言
public extension String {

    /// 将字符串翻译成当前系统设置的语言的字符串
    /// - Returns: 返回翻译后在字符串
    func localized() -> String {
        return NSLocalizedString(self, comment: self)
    }
}

// MARK: - 基础属性
public extension String {
    
    /// 得到一个富文本字符串
    var attributedString: NSAttributedString { .init(string: self) }
    
    // 转换为NSString，
    //' NSString '有一些' String '没有的有用属性。
    var nsString: NSString { self as NSString }
    
    
    /// 将特殊字符用空字符替换
    var trimmedTrailing: Self {
        replacingOccurrences(of: #"\s+$"#, with: "", options: .regularExpression)
    }


    /// 将字符串的最后几位用一个字符串替换，例如用： “...”表示，得到一个新的字符串
    ///
    ///
    ///     "Unicorn".truncating(to: 4)
    ///      //=> "Uni…"
    ///
    /// - Parameters:
    ///   - number: 最后表示为.的位数
    ///   - truncationIndicator: 表示替换的字符串
    /// - Returns: 返回用truncationIndicator替换后的新字符串
    func truncating(to number: Int, truncationIndicator: Self = "…") -> Self {
        if number <= 0 {
            return ""
        } else if count > number {
            return String(prefix(number - truncationIndicator.count)).trimmedTrailing + truncationIndicator
        } else {
            return self
        }
    }
}



// MARK: - 字符串转换
public extension String {
    
    /// 第一个字符转大写
    func firstCapital() -> String {
        var orgString = self
        let s1 = String(orgString.prefix(1))
        
        var num: UInt32 = 0
        for code in s1.unicodeScalars {
            num = code.value
        }
        
        if num >= 97 && num <= 122{
            num -= 32
        }
        
        let ch:Character = Character(UnicodeScalar(num)!)
        let s2 = String(ch)
        
        let startIndex = orgString.index(orgString.startIndex, offsetBy:0)
        let endIndex = orgString.index(orgString.startIndex, offsetBy:0)
        orgString.replaceSubrange(startIndex...endIndex, with: s2)
        return orgString
    }
    
    
    /// 将字符串第一个字符小写
    ///
    ///  “Good”.lowercaseFirstChar()  =>   good
    ///
    /// - Returns: 返回第一个字符串转换为小写的新字符串
    func lowercaseFirstChar() -> String{
        if self.count > 0 {
            let range = self.startIndex..<self.index(self.startIndex, offsetBy: 1)
            
            let firstLowerChar = self[range].lowercased()
            
            return self.replacingCharacters(in: range, with: firstLowerChar)
        }else{
            return self
        }
    }
    
    /// 将字符串的第一个字符大写
    ///
    ///   “good”.uppercaseFirstChar()  =>   Good
    ///
    /// - Returns: 返回第一个字符串转换为大写后的新字符串
    func uppercaseFirstChar() -> String{
        if self.count > 0 {
            let range = startIndex..<self.index(startIndex, offsetBy: 1)
            
            let firstUpperChar = self[range].uppercased()
            
            return self.replacingCharacters(in: range, with: firstUpperChar)
        }else{
            return self
        }
    }
    
}

