//
//  String+sub.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

public extension String {

    /// 从字符串转化为浮点值
    ///
    /// - Parameter locale: Locale（默认为Locale.current）
    /// - Returns: 给定字符串中的可选Float值
    func float(locale: Locale = .current) -> Float? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.allowsFloats = true
        return formatter.number(from: self)?.floatValue
    }

    /// 字符串转化为双精度值
    ///
    /// - Parameter Locale（默认为Locale.current）
    /// - Returns: 可选给定字符串中的Double值
    func double(locale: Locale = .current) -> Double? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.allowsFloats = true
        return formatter.number(from: self)?.doubleValue
    }
 
    /// 来自字符串的CGFloat值
    ///
    /// - Parameter Locale（默认为Locale.current）
    /// - Returns: 给定字符串中的可选CGFloat值
    func cgFloat(locale: Locale = .current) -> CGFloat? {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.allowsFloats = true
        return formatter.number(from: self) as? CGFloat
    }

    /// 由换行符分隔的字符串数组
    ///
    ///        "Hello\ntest".lines() -> ["Hello", "test"]
    ///
    /// - Returns: 用新行分隔的字符串
    func lines() -> [String] {
        var result = [String]()
        enumerateLines { line, _ in
            result.append(line)
        }
        return result
    }
 
    /// 返回本地化的字符串，并为翻译提供可选的注释
    ///
    ///        "Hello world".localized -> Hallo Welt
    ///
    func localized(comment: String = "") -> String {
        return NSLocalizedString(self, comment: comment)
    }

    /// 包含字符串中所有字符的Unicode数组
    ///
    ///        "SwifterSwift".unicodeArray() -> [83, 119, 105, 102, 116, 101, 114, 83, 119, 105, 102, 116]
    ///
    /// - Returns: 字符串中所有字符的unicode
    func unicodeArray() -> [Int] {
        return unicodeScalars.map { Int($0.value) }
    }


    /// 字符串中所有单词的数组
    ///
    ///        "Swift is amazing".words() -> ["Swift", "is", "amazing"]
    ///
    /// - Returns: 字符串中包含的单词
    func words() -> [String] {
        // https://stackoverflow.com/questions/42822838
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let comps = components(separatedBy: chararacterSet)
        return comps.filter { !$0.isEmpty }
    }
 

    /// 字符串中的字数
    ///
    ///        "Swift is amazing".wordsCount() -> 3
    ///
    /// - Returns: 字符串中包含的单词数
    func wordCount() -> Int {
        // https://stackoverflow.com/questions/42822838
        let chararacterSet = CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)
        let comps = components(separatedBy: chararacterSet)
        let words = comps.filter { !$0.isEmpty }
        return words.count
    }
 

    /// 将字符串转换为子字符串
    ///
    ///        "Swift is amazing".toSlug() -> "swift-is-amazing"
    ///
    /// - Returns: 子格式的字符串
    func toSlug() -> String {
        let lowercased = self.lowercased()
        let latinized = lowercased.folding(options: .diacriticInsensitive, locale: Locale.current)
        let withDashes = latinized.replacingOccurrences(of: " ", with: "-")

        let alphanumerics = NSCharacterSet.alphanumerics
        var filtered = withDashes.filter {
            guard String($0) != "-" else { return true }
            guard String($0) != "&" else { return true }
            return String($0).rangeOfCharacter(from: alphanumerics) != nil
        }

        while filtered.lastCharacterAsString == "-" {
            filtered = String(filtered.dropLast())
        }

        while filtered.firstCharacterAsString == "-" {
            filtered = String(filtered.dropFirst())
        }

        return filtered.replacingOccurrences(of: "--", with: "-")
    }
 
    /// 将字符串格式转换为（驼峰名命方式）字符串
    ///
    ///        var str = "sOme vaRiabLe Name"
    ///        str.camelize()
    ///        print(str) // prints "someVariableName"
    ///
    @discardableResult
    mutating func camelize() -> String {
        let source = lowercased()
        let first = source[..<source.index(after: source.startIndex)]
        if source.contains(" ") {
            let connected = source.capitalized.replacingOccurrences(of: " ", with: "")
            let camel = connected.replacingOccurrences(of: "\n", with: "")
            let rest = String(camel.dropFirst())
            self = first + rest
            return self
        }
        let rest = String(source.dropFirst())

        self = first + rest
        return self
    }

    /// 字符串的第一个字符大写（如果适用），同时保留原始字符串
    ///
    ///        "hello world".firstCharacterUppercased() -> "Hello world"
    ///        "".firstCharacterUppercased() -> ""
    ///
    mutating func firstCharacterUppercased() {
        guard let first = first else { return }
        self = String(first).uppercased() + dropFirst()
    }

    /// 检查字符串是否仅包含唯一字符
    ///
    func hasUniqueCharacters() -> Bool {
        guard count > 0 else { return false }
        var uniqueChars = Set<String>()
        for char in self {
            if uniqueChars.contains(String(char)) { return false }
            uniqueChars.insert(String(char))
        }
        return true
    }


    /// 检查字符串是否包含一个或多个子字符串实例
    ///
    ///        "Hello World!".contain("O") -> false
    ///        "Hello World!".contain("o", caseSensitive: false) -> true
    ///
    /// - Parameters:
    ///   - string: 要搜索的子字符串
    ///   - caseSensitive: 对于区分大小写的搜索设置为true
    /// - Returns: 如果string包含一个或多个substring实例，则返回true
    func contains(_ string: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return range(of: string, options: .caseInsensitive) != nil
        }
        return range(of: string) != nil
    }
 


    /// 字符串中子字符串的计数
    ///
    ///        "Hello World!".count(of: "o") -> 2
    ///        "Hello World!".count(of: "L", caseSensitive: false) -> 3
    ///
    /// - Parameters:
    ///   - string: 要搜索的子字符串
    ///   - caseSensitive: 对于区分大小写的搜索设置为true
    /// - Returns: 字符串中子字符串的出现计数
    func count(of string: String, caseSensitive: Bool = true) -> Int {
        if !caseSensitive {
            return lowercased().components(separatedBy: string.lowercased()).count - 1
        }
        return components(separatedBy: string).count - 1
    }
 

    /// 检查字符串是否以子字符串结尾
    ///
    ///        "Hello World!".ends(with: "!") -> true
    ///        "Hello World!".ends(with: "WoRld!", caseSensitive: false) -> true
    ///
    /// - Parameters:
    ///   - suffix: 用于搜索字符串是否以s结尾的子字符串
    ///   - caseSensitive: 对于区分大小写的搜索设置为true
    /// - Returns: 如果字符串以子字符串结尾，则返回true
    func ends(with suffix: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return lowercased().hasSuffix(suffix.lowercased())
        }
        return hasSuffix(suffix)
    }

    /// 给定长度的随机字符串
    ///
    ///        String.random(ofLength: 18) -> "u7MMZYvGo9obcOcPj8"
    ///
    /// - Parameter length: 字符串中的字符数
    /// - Returns: 给定长度的随机字符串
    static func random(ofLength length: Int) -> String {
        guard length > 0 else { return "" }
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString = ""
        for _ in 1...length {
            randomString.append(base.randomElement()!)
        }
        return randomString
    }

    /// 反向字符串
    @discardableResult
    mutating func reverse() -> String {
        let chars: [Character] = reversed()
        self = String(chars)
        return self
    }

    /// 使用索引安全下标字符串
    ///
    ///        "Hello World!"[safe: 3] -> "l"
    ///        "Hello World!"[safe: 20] -> nil
    ///
    /// - Parameter index: index.
    subscript(safe index: Int) -> Character? {
        guard index >= 0, index < count else { return nil }
        return self[self.index(startIndex, offsetBy: index)]
    }

    /// 在给定范围内安全下标字符串
    ///        "Hello World!"[safe: 6..<11] -> "World"
    ///        "Hello World!"[safe: 21..<110] -> nil
    ///
    ///        "Hello World!"[safe: 6...11] -> "World!"
    ///        "Hello World!"[safe: 21...110] -> nil
    ///
    /// - Parameter range: 范围表达式
    subscript<R>(safe range: R) -> String? where R: RangeExpression, R.Bound == Int {
        let range = range.relative(to: Int.min..<Int.max)
        guard range.lowerBound >= 0,
            let lowerIndex = index(startIndex, offsetBy: range.lowerBound, limitedBy: endIndex),
            let upperIndex = index(startIndex, offsetBy: range.upperBound, limitedBy: endIndex) else {
            return nil
        }

        return String(self[lowerIndex..<upperIndex])
    }

    
    /// 从具有起始长度的起始索引处切下的字符串
    ///
    ///        "Hello World".slicing(from: 6, length: 5) -> "World"
    ///
    /// - Parameters:
    ///   - index: 切片应从其开始的字符串索引
    ///   - length: 给定索引后要切片的字符数
    /// - Returns: 长度为字符数的切片子字符串)(example: "Hello World".slicing(from: 6, length: 5) -> "World")
    func slicing(from index: Int, length: Int) -> String? {
        guard length >= 0, index >= 0, index < count else { return nil }
        guard index.advanced(by: length) <= count else {
            return self[safe: index..<count]
        }
        guard length > 0 else { return "" }
        return self[safe: index..<index.advanced(by: length)]
    }

    /// 从起始索引中切片给定的字符串，并加上长度
    ///
    ///        var str = "Hello World"
    ///        str.slice(from: 6, length: 5)
    ///        print(str) // prints "World"
    ///
    /// - Parameters:
    ///   - index: 切片应从其开始的字符串索引
    ///   - length: 给定索引后要切片的字符数
    @discardableResult
    mutating func slice(from index: Int, length: Int) -> String {
        if let str = slicing(from: index, length: length) {
            self = String(str)
        }
        return self
    }

    /// 将给定的字符串从开始索引切到结束索引.
    ///
    ///        var str = "Hello World"
    ///        str.slice(from: 6, to: 11)
    ///        print(str) // prints "World"
    ///
    /// - Parameters:
    ///   - start: 切片应从其开始的字符串索引
    ///   - end: 切片应在其处结束的字符串索引
    @discardableResult
    mutating func slice(from start: Int, to end: Int) -> String {
        guard end >= start else { return self }
        if let str = self[safe: start..<end] {
            self = str
        }
        return self
    }

    /// 从起始索引中切片给定的字符串
    ///
    ///        var str = "Hello World"
    ///        str.slice(at: 6)
    ///        print(str) // prints "World"
    ///
    /// - Parameter index: 切片应从其开始的字符串索引
    @discardableResult
    mutating func slice(at index: Int) -> String {
        guard index < count else { return self }
        if let str = self[safe: index..<count] {
            self = str
        }
        return self
    }

    /// 检查字符串是否以子字符串开头
    ///
    ///        "hello World".starts(with: "h") -> true
    ///        "hello World".starts(with: "H", caseSensitive: false) -> true
    ///
    /// - Parameters:
    ///   - suffix: 用于搜索字符串是否以其开头的子字符串
    ///   - caseSensitive: 对于区分大小写的搜索设置为true
    /// - Returns: 如果字符串以子字符串开头，则为true
    func starts(with prefix: String, caseSensitive: Bool = true) -> Bool {
        if !caseSensitive {
            return lowercased().hasPrefix(prefix.lowercased())
        }
        return hasPrefix(prefix)
    }


    /// 日期对象，采用日期格式的字符串
    ///
    ///        "2017-01-15".date(withFormat: "yyyy-MM-dd") -> Date set to Jan 15, 2017
    ///        "not date string".date(withFormat: "yyyy-MM-dd") -> nil
    ///
    /// - Parameter format: 日期格式
    /// - Returns: 字符串中的Date对象
    func date(withFormat format: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.date(from: self)
    }
 


    /// 删除字符串开头和结尾的空格和换行符
    ///
    ///        var str = "  \n Hello World \n\n\n"
    ///        str.trim()
    ///        print(str) // prints "Hello World"
    ///
    @discardableResult
    mutating func trim() -> String {
        self = trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return self
    }
 

    /// 截断字符串（将其剪切为给定的字符数）
    ///
    ///        var str = "This is a very long sentence"
    ///        str.truncate(toLength: 14)
    ///        print(str) // prints "This is a very..."
    ///
    /// - Parameters:
    ///   - toLength: 剪切前的最大字符数
    ///   - trailing: 要在截断的字符串末尾添加的字符串（默认为“ ...”）
    @discardableResult
    mutating func truncate(toLength length: Int, trailing: String? = "...") -> String {
        guard length > 0 else { return self }
        if count > length {
            self = self[startIndex..<index(startIndex, offsetBy: length)] + (trailing ?? "")
        }
        return self
    }

    /// 截断的字符串（限制为给定的字符数）
    ///
    ///        "This is a very long sentence".truncated(toLength: 14) -> "This is a very..."
    ///        "Short sentence".truncated(toLength: 14) -> "Short sentence"
    ///
    /// - Parameters:
    ///   - toLength: 剪切前的最大字符数
    ///   - trailing:要在截断的字符串末尾添加的字符串
    /// - Returns: 截断的字符串（这是一个extr ...）
    func truncated(toLength length: Int, trailing: String? = "...") -> String {
        guard 0..<count ~= length else { return self }
        return self[startIndex..<index(startIndex, offsetBy: length)] + (trailing ?? "")
    }

    /// 将URL字符串转换为可读字符串
    ///
    ///        var str = "it's%20easy%20to%20decode%20strings"
    ///        str.urlDecode()
    ///        print(str) // prints "it's easy to decode strings"
    ///
    @discardableResult
    mutating func urlDecode() -> String {
        if let decoded = removingPercentEncoding {
            self = decoded
        }
        return self
    }
 
    /// 转义字符串
    ///
    ///        var str = "it's easy to encode strings"
    ///        str.urlEncode()
    ///        print(str) // prints "it's%20easy%20to%20encode%20strings"
    ///
    @discardableResult
    mutating func urlEncode() -> String {
        if let encoded = addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) {
            self = encoded
        }
        return self
    }
 
    ///验证字符串是否与正则表达式模式匹配
    ///
    /// - Parameter pattern: Pattern to verify.
    /// - Returns: `true` if string matches the pattern.
    func matches(pattern: String) -> Bool {
        return range(of: pattern, options: .regularExpression, range: nil, locale: nil) != nil
    }
 
    /// 验证字符串是否与正则表达式匹配
    ///
    /// - Parameter regex: Regex to verify.
    /// - Parameter options: The matching options to use.
    /// - Returns: `true` if string matches the regex.
    func matches(regex: NSRegularExpression, options: NSRegularExpression.MatchingOptions = []) -> Bool {
        let range = NSRange(startIndex..<endIndex, in: self)
        return regex.firstMatch(in: self, options: options, range: range) != nil
    }
 
    /// 重载Swift的“包含”运算符以匹配正则表达式模式
    ///
    /// - Parameter lhs: String to check on regex pattern.
    /// - Parameter rhs: Regex pattern to match against.
    /// - Returns: true if string matches the pattern.
    static func ~= (lhs: String, rhs: String) -> Bool {
        return lhs.range(of: rhs, options: .regularExpression) != nil
    }
 

    /// 重载Swift的“包含”运算符以匹配正则表达式
    ///
    /// - Parameter lhs: String to check on regex.
    /// - Parameter rhs: Regex to match against.
    /// - Returns: `true` if there is at least one match for the regex in the string.
    static func ~= (lhs: String, rhs: NSRegularExpression) -> Bool {
        let range = NSRange(lhs.startIndex..<lhs.endIndex, in: lhs)
        return rhs.firstMatch(in: lhs, range: range) != nil
    }
 

    /// 返回一个新字符串，在该字符串中，在接收者指定范围内出现的所有正则表达式均被模板替换
    /// - Parameter regex: 要替换的正则表达式
    /// - Parameter template: 用于替换正则表达式的模板
    /// - Parameter options: 要使用的匹配选项
    /// - Parameter searchRange: 接收器中要搜索的范围
    /// - Returns: 一个新字符串，其中，接收者的searchRange中所有出现的regex均被模板替换
    func replacingOccurrences(
        of regex: NSRegularExpression,
        with template: String,
        options: NSRegularExpression.MatchingOptions = [],
        range searchRange: Range<String.Index>? = nil) -> String {
        let range = NSRange(searchRange ?? startIndex..<endIndex, in: self)
        return regex.stringByReplacingMatches(in: self, options: options, range: range, withTemplate: template)
    }
 

    /// 填充字符串以使长度参数的大小与开头的另一个字符串匹配
    ///
    ///   "hue".padStart(10) -> "       hue"
    ///   "hue".padStart(10, with: "br") -> "brbrbrbhue"
    ///
    /// - Parameter length: 要填充的目标长度
    /// - Parameter string: 填充字符串。默认值为“ ”
    @discardableResult
    mutating func padStart(_ length: Int, with string: String = " ") -> String {
        self = paddingStart(length, with: string)
        return self
    }

    /// 通过填充以使长度参数大小与开头的另一个字符串匹配来返回字符串
    ///
    ///   "hue".paddingStart(10) -> "       hue"
    ///   "hue".paddingStart(10, with: "br") -> "brbrbrbhue"
    ///
    /// - Parameter length: 要填充的目标长度
    /// - Parameter string:填充字符串。默认值为“ ”
    /// - Returns:在开始处带有填充的字符串。
    func paddingStart(_ length: Int, with string: String = " ") -> String {
        guard count < length else { return self }

        let padLength = length - count
        if padLength < string.count {
            return string[string.startIndex..<string.index(string.startIndex, offsetBy: padLength)] + self
        } else {
            var padding = string
            while padding.count < padLength {
                padding.append(string)
            }
            return padding[padding.startIndex..<padding.index(padding.startIndex, offsetBy: padLength)] + self
        }
    }

    /// 填充字符串以使长度参数的大小与开头的另一个字符串匹配
    ///
    ///   "hue".padEnd(10) -> "hue       "
    ///   "hue".padEnd(10, with: "br") -> "huebrbrbrb"
    ///
    /// - Parameter length: 要填充的目标长度。
    /// - Parameter string: 填充字符串。默认值为“”。
    @discardableResult
    mutating func padEnd(_ length: Int, with string: String = " ") -> String {
        self = paddingEnd(length, with: string)
        return self
    }

    /// 通过填充以将长度参数大小与最后一个字符串匹配来返回字符串。
    ///
    ///   "hue".paddingEnd(10) -> "hue       "
    ///   "hue".paddingEnd(10, with: "br") -> "huebrbrbrb"
    ///
    /// - Parameter length: 要填充的目标长度
    /// - Parameter string: 填充字符串。默认值为“ ”
    /// - Returns: 末尾带有填充符的字符串
    func paddingEnd(_ length: Int, with string: String = " ") -> String {
        guard count < length else { return self }

        let padLength = length - count
        if padLength < string.count {
            return self + string[string.startIndex..<string.index(string.startIndex, offsetBy: padLength)]
        } else {
            var padding = string
            while padding.count < padLength {
                padding.append(string)
            }
            return self + padding[padding.startIndex..<padding.index(padding.startIndex, offsetBy: padLength)]
        }
    }
    
    /// 从字符串中删除给定的前缀
    ///
    ///   "Hello, World!".removingPrefix("Hello, ") -> "World!"
    ///
    /// - Parameter prefix: 要从字符串中删除的前缀
    /// - Returns: 删除前缀后的字符串
    func removingPrefix(_ prefix: String) -> String {
        guard hasPrefix(prefix) else { return self }
        return String(dropFirst(prefix.count))
    }

    /// 从字符串中删除给定的后缀
    ///
    ///   "Hello, World!".removingSuffix(", World!") -> "Hello"
    ///
    /// - Parameter suffix: 从字符串中删除的后缀
    /// - Returns: 后缀删除后的字符串
    func removingSuffix(_ suffix: String) -> String {
        guard hasSuffix(suffix) else { return self }
        return String(dropLast(suffix.count))
    }

    /// 为字符串添加前缀
    ///
    ///     "www.apple.com".withPrefix("https://") -> "https://www.apple.com"
    ///
    /// - Parameter prefix: 添加到字符串的前缀.
    /// - Returns: 前缀为前缀的字符串
    func withPrefix(_ prefix: String) -> String {
        // https://www.hackingwithswift.com/articles/141/8-useful-swift-extensions
        guard !hasPrefix(prefix) else { return self }
        return prefix + self
    }
    

    ///为字符串添加前缀
    ///
    ///"foo bar".replacingPrefix("foo", with: "unicorn")
    ///=> "unicorn bar"
    ///
    /// - Parameter prefix:添加到字符串的前缀.
    /// - Returns: 前缀为前缀的字符串
    func replacingPrefix(_ prefix: Self, with replacement: Self) -> Self {
        guard hasPrefix(prefix) else {
            return self
        }

        return replacement + dropFirst(prefix.count)
    }

}


public extension String {

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
