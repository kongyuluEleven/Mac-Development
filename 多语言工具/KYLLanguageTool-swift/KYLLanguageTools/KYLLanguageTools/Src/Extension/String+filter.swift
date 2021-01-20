//
//  String+filter.swift
//  WSUIKit
//
//  Created by kongyulu on 2021/1/20.
//

#if canImport(Foundation)
import Foundation
#endif

// MARK: - 字符串过滤
public extension String {
    
    /// 邮箱过长时用户名中间打点省略
    ///
    /// - Parameter maxLength: 可以接受的用户名长度
    /// - Returns: 打点后的邮箱（需要时）
    func displayEmail(acceptableNameLength maxLength: Int) -> String {
        let emailSubs = components(separatedBy: "@")
        guard let firstHalf  = emailSubs.first else { return self }
        guard let secondHalf = emailSubs.last else { return self }
        
        let name = firstHalf
        guard name.count  > maxLength else { return self }
        
        let namePrefix = name.prefix(4)
        let nameSuffix = name.suffix(4)
        let diaPlayEmail = namePrefix + "..." + nameSuffix + "@" + secondHalf
        return diaPlayEmail
    }
    
    
    /// 判断字符串是否包含中文字符或日文字符
    /// - Returns: 含有中文或日文则返回true
    func isChineseAndJapanese() -> Bool {
        
        for (_, value) in enumerated() {
            if ("\u{4E00}" <= value  && value <= "\u{9FA5}") {
                return true
            }
            
            if ("\u{3040}" <= value  && value <= "\u{309f}") || ("\u{30a0}" <= value  && value <= "\u{30ff}") || ("\u{31f0}" <= value  && value <= "\u{31ff}") {
                return true
            }
        }
        return false
    }
    
    /// 校验是否是合法的邮件地址
    var isValidEmailAddress: Bool {
        let char = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", char)
        return emailPredicate.evaluate(with: self)
    }
    
    /// 判断是否包含中文字符
    ///
    /// - Returns:  true 代表包含 false 代表不包含
    func containChineseChar() -> Bool {
        /* 中文的正则表达式 */
        let regularParameter = "[\\u4e00-\\u9fa5]"
        guard let regular = try? NSRegularExpression(pattern: regularParameter, options: NSRegularExpression.Options.caseInsensitive) else {
            return false
        }
        let res = regular.matches(in: self, options: NSRegularExpression.MatchingOptions.anchored, range: NSRange.init(location: 0, length: self.count))
        return res.count > 0
    }
}


// MARK: - 字符串查找
public extension String {
    /// * 比较特殊字符翻译和原来的是否相等
    ///
    /// - Parameters:
    ///   - left: 左侧原来母语
    ///   - right: 右侧翻译的
    /// - Returns: 如果 YES 代表相等 如果 NO 代表不相等
    static func compareSpecial(special:String, left:String, right:String) -> Bool {
        return findSpecialCount(special: special, source: left) == findSpecialCount(special: special, source: right)
    }
    
    /// 查找字符串中占位符的总数
    ///
    /// - Parameters:
    ///   - special: 占位符
    ///   - source: 查找的字符串
    /// - Returns: 所占的总数
    static func findSpecialCount(special:String, source:String) -> Int {
        var count = 0
        // 如果已经不存在占位符就返回
        guard let range = source.range(of: special) else {
            return count
        }
        //如果查找出来则计数+1
        count += 1
        // 切除占位符之后的字符串
        let cutSource = source.substring(from: source.index(range.upperBound, offsetBy: 0))
        // 计数加上剩余占位符的总数
        count += findSpecialCount(special: special, source: cutSource)
        return count
    }
}
