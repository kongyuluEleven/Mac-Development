//
//  Comparable+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

// MARK: - 方法

public extension Comparable {
    /// 如果value在提供的范围内，则返回true。
    ///
    ///    1.isBetween(5...7) // false
    ///    7.isBetween(6...12) // true
    ///    date.isBetween(date1...date2)
    ///    "c".isBetween(a...d) // true
    ///    0.32.isBetween(0.31...0.33) // true
    ///
    /// - parameter min: 最小可比较值。
    /// - parameter max: 最大可比较值。
    ///
    /// - returns: 如果value在' min '和' max '之间，则为' true '，否则为' false '。
    func isBetween(_ range: ClosedRange<Self>) -> Bool {
        return range ~= self
    }

    /// 返回限定在提供的范围内的值。
    ///
    ///     1.clamped(to: 3...8) // 3
    ///     4.clamped(to: 3...7) // 4
    ///     "c".clamped(to: "e"..."g") // "e"
    ///     0.32.clamped(to: 0.1...0.29) // 0.29
    ///
    /// - parameter min: 将值限制为的下限。
    /// - parameter max: 将值限制为的上限。
    ///
    /// - returns: 限定在“min”和“max”之间的值。
    func clamped(to range: ClosedRange<Self>) -> Self {
        return max(range.lowerBound, min(self, range.upperBound))
    }
}
