//
//  CGPoint+Extension.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(CoreGraphics)
import CoreGraphics

public func min(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
    return CGPoint(x: Swift.min(lhs.x, rhs.x), y: Swift.min(lhs.y, rhs.y))
}

public func max(_ lhs: CGPoint, _ rhs: CGPoint) -> CGPoint {
    return CGPoint(x: Swift.max(lhs.x, rhs.x), y: Swift.max(lhs.y, rhs.y))
}

// MARK: - CGPoint
public extension CGPoint {

    var isInfinite: Bool {
        return x.isInfinite || y.isInfinite
    }

    var isNaN: Bool {
        return x.isNaN || y.isNaN
    }

    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGPoint {
        return CGPoint(x: x.rounded(rule), y: y.rounded(rule))
    }
    
    /// 两个CGPoint之间的距离。
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let point2 = CGPoint(x: 30, y: 30)
    ///     let distance = CGPoint.distance(from: point2, to: point1)
    ///     // distance = 28.28
    ///
    /// - Parameters:
    ///   - point1: 第一个CGPoint
    ///   - point2: 第二个CGPoint.
    /// - Returns: 两个给定CGPoint之间的距离
    static func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        // http://stackoverflow.com/questions/6416101/calculate-the-distance-between-two-cgpoints
        return sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2))
    }

    /// 与另一个CGPoint的距离。
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let point2 = CGPoint(x: 30, y: 30)
    ///     let distance = point1.distance(from: point2)
    ///     // distance = 28.28
    ///
    /// - Parameter point:CGPoint，用于获取距离
    /// - Returns: 与指定CGPoint之间的距离
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(x - point.x, y - point.y)
    }
    
    /// 与另一个CGRect的距离。
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let point2 = CGPoint(x: 30, y: 30)
    ///     let distance = point1.distance(to: NSMakeRect(point2.x, point2.y, 20, 20))
    ///     // distance = 28.28
    /// - Parameter rect: 用于获取距离
    /// - Returns: 与指定CGRect之间的最短的距离
    func distance(to rect: CGRect) -> CGFloat {
        let xDelta = (x < rect.minX) ? (rect.minX - x) : ((x > rect.maxX) ? (x - rect.maxX) : 0)
        let yDelta = (y < rect.minY) ? (rect.minY - y) : ((y > rect.maxY) ? (y - rect.maxY) : 0)
        return hypot(xDelta, yDelta)
    }

    func isEqual(_ point: CGPoint, tolerance: CGFloat) -> Bool {
        return abs(x - point.x) <= tolerance && abs(y - point.y) <= tolerance
    }

    
    /// （当前Point） x增量 + y增量
    /// - Parameter xDelta: x增量
    /// - Parameter yDelta: y增量
    /// - Returns: x轴增加和y轴增加，后返回新Point
    func add(x xDelta: CGFloat = 0, y yDelta: CGFloat = 0) -> CGPoint {
        return CGPoint(x: x + xDelta, y: y + yDelta)
    }
    
    /// 返回一个新的CGPoint
    /// - Parameter x: CGPoint.x
    /// - Parameter y: CGPoint.x
    func with(x: CGFloat? = nil, y: CGFloat? = nil) -> CGPoint {
        return CGPoint(x: x ?? self.x, y: y ?? self.y)
    }

    mutating func set(x: CGFloat? = nil, y: CGFloat? = nil) {
        self = self.with(x: x, y: y)
    }
}


// MARK: - Operators

public extension CGPoint {
    ///  添加两个CGPoint
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let point2 = CGPoint(x: 30, y: 30)
    ///     let point = point1 + point2
    ///     // point = CGPoint(x: 40, y: 40)
    ///
    /// - Parameters:
    ///   - lhs: 要添加的CGPoint。
    ///   - rhs:  要添加的CGPoint
    /// - Returns: 两个给定CGPoint相加的结果
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    /// 向（当前Point）添加一个CGPoint。
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let point2 = CGPoint(x: 30, y: 30)
    ///     point1 += point2
    ///     // point1 = CGPoint(x: 40, y: 40)
    ///
    /// - Parameters:
    ///   - lhs: self
    ///   - rhs: 要添加的CGPoint
    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }

    /// 减去两个CGPoint。
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let point2 = CGPoint(x: 30, y: 30)
    ///     let point = point1 - point2
    ///     // point = CGPoint(x: -20, y: -20)
    ///
    /// - Parameters:
    ///   - lhs: 要减去的CGPoint
    ///   - rhs: 要减去的CGPoint
    /// - Returns: 两个给定CGPoint相减的结果。
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    /// 从（当前Point）减去CGPoint。
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let point2 = CGPoint(x: 30, y: 30)
    ///     point1 -= point2
    ///     // point1 = CGPoint(x: -20, y: -20)
    ///
    /// - Parameters:
    ///   - lhs: self
    ///   - rhs: 要减去的CGPoint
    static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }

    /// 用标量乘以CGPoint
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let scalar = point1 * 5
    ///     // scalar = CGPoint(x: 50, y: 50)
    ///
    /// - Parameters:
    ///   - point: CGPoint相乘。
    ///   - scalar: 标量值
    /// - Returns: 给定CGPoint与标量相乘的结果
    static func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * scalar, y: point.y * scalar)
    }

    /// 将（当前point）与标量相乘
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     point *= 5
    ///     // point1 = CGPoint(x: 50, y: 50)
    ///
    /// - Parameters:
    ///   - point: self.
    ///   - scalar: 标量值
    /// - Returns: 给定CGPoint与标量相乘的结果。
    static func *= (point: inout CGPoint, scalar: CGFloat) {
        point.x *= scalar
        point.y *= scalar
    }

    /// 用标量乘以CGPoint
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let scalar = 5 * point1
    ///     // scalar = CGPoint(x: 50, y: 50)
    ///
    /// - Parameters:
    ///   - scalar: scalar 值.
    ///   - point: CGPoint相乘
    /// - Returns: 给定CGPoint与标量相乘的结果
    static func * (scalar: CGFloat, point: CGPoint) -> CGPoint {
        return CGPoint(x: point.x * scalar, y: point.y * scalar)
    }
    

    
    /// 除法运算重载
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let scalar =  point1/2
    ///     // scalar = CGPoint(x: 5, y: 5)
    ///
    /// - Parameters:
    ///   - point: 需要除运算的CGPoint
    ///   - divisor: 被除数
    /// - Returns: 返回除法运算计算后的CGPoint
    static func / (point: CGPoint, divisor: CGFloat) -> CGPoint {
        return CGPoint(x: point.x / divisor, y: point.y / divisor)
    }

}

#endif
