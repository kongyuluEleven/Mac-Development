//
//  NSRegularExpression+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

public extension NSRegularExpression {
    /// 枚举允许块处理每个正则表达式匹配的字符串。
    ///
    /// - Parameters:
    ///   - string: 字符串.
    ///   - options: 匹配的可选项， 具体可以查看NSRegularExpression.MatchingOptions
    ///   - range: 要测试的字符串的范围。
    ///   - block: 该块枚举字符串中正则表达式的匹配项。
    ///     该块接受三个参数并返回' Void ':
    ///   - result:
    ///     指定匹配的' NSTextCheckingResult '。该结果通过其' range '属性给出了整体匹配的范围，并通过其' range(at:) '方法给出了每个单个捕获组的范围。范围{NSNotFound, 0}如果其中一个捕获组不参与这个特定的匹配。
    ///   - flags:
    ///     匹配进度的当前状态. 具体可以参考NSRegularExpression.MatchingFlags
    ///   - stop:
    ///     对布尔值的引用。该块可以将该值设置为true，以停止对数组的进一步处理。
    ///     stop参数是一个唯一的参数。你应该只在块内将这个布尔值设置为true。
    #if os(Linux)
    func enumerateMatches(in string: String,
                          options: MatchingOptions = [],
                          range: Range<String.Index>,
                          using block: @escaping (
                              _ result: NSTextCheckingResult?,
                              _ flags: MatchingFlags,
                              _ stop: inout Bool) -> Void) {
        enumerateMatches(in: string,
                         options: options,
                         range: NSRange(range, in: string)) { result, flags, stop in
                var shouldStop = false
                block(result, flags, &shouldStop)
                if shouldStop {
                    stop.pointee = true
                }
        }
    }
    #else
    func enumerateMatches(in string: String,
                          options: MatchingOptions = [],
                          range: Range<String.Index>,
                          using block: (_ result: NSTextCheckingResult?, _ flags: MatchingFlags, _ stop: inout Bool)
                              -> Void) {
        enumerateMatches(in: string,
                         options: options,
                         range: NSRange(range, in: string)) { result, flags, stop in
                var shouldStop = false
                block(result, flags, &shouldStop)
                if shouldStop {
                    stop.pointee = true
                }
        }
    }
    #endif

    /// 返回一个数组，其中包含字符串中正则表达式的所有匹配项。
    ///
    /// - Parameters:
    ///   - string: 要搜索的字符串
    ///   - options: 要匹配的可选项. 具体参考NSRegularExpression.MatchingOptions
    ///   - range: 要搜索字符串的范围.
    /// - Returns: 一个' NSTextCheckingResult '对象数组。每个结果通过其' range '属性给出整体匹配的范围，并通过其' range(at:) '方法给出每个单个捕获组的范围。范围{NSNotFound, 0}如果其中一个捕获组不参与这个特定的匹配。
    func matches(in string: String,
                 options: MatchingOptions = [],
                 range: Range<String.Index>) -> [NSTextCheckingResult] {
        return matches(in: string,
                       options: options,
                       range: NSRange(range, in: string))
    }

    /// 在指定的字符串范围内返回正则表达式的匹配数。
    ///
    /// - Parameters:
    ///   - string: 要搜索的字符串
    ///   - options: 要匹配的可选项. 具体参考NSRegularExpression.MatchingOptions
    ///   - range: 要搜索字符串的范围.
    /// - Returns: 正则表达式的匹配次数。
    func numberOfMatches(in string: String,
                         options: MatchingOptions = [],
                         range: Range<String.Index>) -> Int {
        return numberOfMatches(in: string,
                               options: options,
                               range: NSRange(range, in: string))
    }

    /// 返回指定字符串范围内正则表达式的第一个匹配项。
    ///
    /// - Parameters:
    ///   - string: 要搜索的字符串
    ///   - options: 要匹配的可选项. 具体参考NSRegularExpression.MatchingOptions
    ///   - range: 要搜索字符串的范围.
    /// - Returns: 一个“NSTextCheckingResult”对象。该结果通过其' range '属性给出了整体匹配的范围，并通过其' range(at:) '方法给出了每个单个捕获组的范围。范围{NSNotFound, 0}如果其中一个捕获组不参与这个特定的匹配。
    func firstMatch(in string: String,
                    options: MatchingOptions = [],
                    range: Range<String.Index>) -> NSTextCheckingResult? {
        return firstMatch(in: string,
                          options: options,
                          range: NSRange(range, in: string))
    }

    /// 返回指定字符串范围内正则表达式的第一个匹配项的范围。
    ///
    /// - Parameters:
    ///   - string: 要搜索的字符串
    ///   - options: 要匹配的可选项. 具体参考NSRegularExpression.MatchingOptions
    ///   - range: 要搜索字符串的范围.
    /// - Returns: 第一个匹配的范围。如果没有找到匹配，返回' nil '。
    func rangeOfFirstMatch(in string: String,
                           options: MatchingOptions = [],
                           range: Range<String.Index>) -> Range<String.Index>? {
        return Range(rangeOfFirstMatch(in: string,
                                       options: options,
                                       range: NSRange(range, in: string)),
                     in: string)
    }

    /// 返回一个新的字符串，其中包含被模板字符串替换的匹配的正则表达式。
    ///
    /// - Parameters:
    ///   - string: 要搜索的字符串
    ///   - options: 要匹配的可选项. 具体参考NSRegularExpression.MatchingOptions
    ///   - range: 要搜索字符串的范围.
    ///   - templ: 替换匹配实例时使用的替换模板。
    /// - Returns: 一个正则表达式被模板字符串替换的字符串。
    func stringByReplacingMatches(in string: String,
                                  options: MatchingOptions = [],
                                  range: Range<String.Index>,
                                  withTemplate templ: String) -> String {
        return stringByReplacingMatches(in: string,
                                        options: options,
                                        range: NSRange(range, in: string),
                                        withTemplate: templ)
    }

    /// 使用模板字符串替换可变字符串中的正则表达式匹配项。
    ///
    /// - Parameters:
    ///   - string: 用于搜索和替换其中值的可变字符串。
    ///   - options: 要匹配的可选项. 具体参考NSRegularExpression.MatchingOptions
    ///   - range: 要搜索的字符串范围。
    ///   - templ: 替换匹配实例时使用的替换模板。
    /// - Returns: 匹配的数量。
    @discardableResult
    func replaceMatches(in string: inout String,
                        options: MatchingOptions = [],
                        range: Range<String.Index>,
                        withTemplate templ: String) -> Int {
        let mutableString = NSMutableString(string: string)
        let matches = replaceMatches(in: mutableString,
                                     options: options,
                                     range: NSRange(range, in: string),
                                     withTemplate: templ)
        string = mutableString.copy() as! String // swiftlint:disable:this force_cast
        return matches
    }
}

#endif

