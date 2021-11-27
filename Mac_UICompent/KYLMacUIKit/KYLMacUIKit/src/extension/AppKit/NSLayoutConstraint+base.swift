//
//  NSLayoutConstraint+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

extension NSLayoutConstraint.Priority: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    // MARK: - Initializers

    /// 用float字面量初始化' NSLayoutConstraint.Priority '
    ///
    ///     constraint.priority = 0.5
    ///
    /// - Parameter value: 约束的优先级值
    public init(floatLiteral value: Float) {
        self.init(rawValue: value)
    }

    /// 用整数初始化' NSLayoutConstraint.Priority '
    ///
    ///     constraint.priority = 5
    ///
    /// - Parameter value: 约束的优先级值
    public init(integerLiteral value: Int) {
        self.init(rawValue: Float(value))
    }
}

#endif
