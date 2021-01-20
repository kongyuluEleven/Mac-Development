//
//  CGFloat+Extension.swift
//  WSUIKit
//
//  Created by kongyulu on 2021/1/6.
//

#if canImport(CoreGraphics)
import CoreGraphics

#if canImport(Foundation)
import Foundation
#endif

// MARK: - Properties

public extension CGFloat {
    /// 绝对值
    var abs: CGFloat {
        return Swift.abs(self)
    }

    #if canImport(Foundation)
    /// Ceil of CGFloat value.
    var ceil: CGFloat {
        return Foundation.ceil(self)
    }
    #endif

    /// Radian value of degree input.
    var degreesToRadians: CGFloat {
        return .pi * self / 180.0
    }

    #if canImport(Foundation)
    ///  Floor of CGFloat value.
    var floor: CGFloat {
        return Foundation.floor(self)
    }
    #endif

    ///  是否是正数
    var isPositive: Bool {
        return self > 0
    }

    /// 是否是负数
    var isNegative: Bool {
        return self < 0
    }

    /// 整型值
    var int: Int {
        return Int(self)
    }

    /// 浮点值
    var float: Float {
        return Float(self)
    }

    /// Double双精度值
    var double: Double {
        return Double(self)
    }

    /// 转换为度数
    var radiansToDegrees: CGFloat {
        return self * 180 / CGFloat.pi
    }
    
}


extension Double {
    var cgFloat: CGFloat { CGFloat(self) }
}


#endif
