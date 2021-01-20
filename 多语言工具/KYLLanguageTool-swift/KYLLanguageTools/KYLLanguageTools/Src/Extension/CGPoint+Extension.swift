//
//  CGPoint+Extension.swift
//  WSUIKit
//
//  Created by zhujian on 05/01/2021.
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
    
    /// Distance between two CGPoints.
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let point2 = CGPoint(x: 30, y: 30)
    ///     let distance = CGPoint.distance(from: point2, to: point1)
    ///     // distance = 28.28
    ///
    /// - Parameters:
    ///   - point1: first CGPoint.
    ///   - point2: second CGPoint.
    /// - Returns: distance between the two given CGPoints.
    static func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        // http://stackoverflow.com/questions/6416101/calculate-the-distance-between-two-cgpoints
        return sqrt(pow(point2.x - point1.x, 2) + pow(point2.y - point1.y, 2))
    }

    /// Distance from another CGPoint.
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let point2 = CGPoint(x: 30, y: 30)
    ///     let distance = point1.distance(from: point2)
    ///     // distance = 28.28
    ///
    /// - Parameter point: CGPoint to get distance from.
    /// - Returns: Distance between self and given CGPoint.
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(x - point.x, y - point.y)
    }

    func distance(to rect: CGRect) -> CGFloat {
        let xDelta = (x < rect.minX) ? (rect.minX - x) : ((x > rect.maxX) ? (x - rect.maxX) : 0)
        let yDelta = (y < rect.minY) ? (rect.minY - y) : ((y > rect.maxY) ? (y - rect.maxY) : 0)
        return hypot(xDelta, yDelta)
    }

    func isEqual(_ point: CGPoint, tolerance: CGFloat) -> Bool {
        return abs(x - point.x) <= tolerance && abs(y - point.y) <= tolerance
    }


    func add(x xDelta: CGFloat = 0, y yDelta: CGFloat = 0) -> CGPoint {
        return CGPoint(x: x + xDelta, y: y + yDelta)
    }

    func with(x: CGFloat? = nil, y: CGFloat? = nil) -> CGPoint {
        return CGPoint(x: x ?? self.x, y: y ?? self.y)
    }

    mutating func set(x: CGFloat? = nil, y: CGFloat? = nil) {
        self = self.with(x: x, y: y)
    }
}


// MARK: - Operators

public extension CGPoint {
    ///  Add two CGPoints.
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let point2 = CGPoint(x: 30, y: 30)
    ///     let point = point1 + point2
    ///     // point = CGPoint(x: 40, y: 40)
    ///
    /// - Parameters:
    ///   - lhs: CGPoint to add to.
    ///   - rhs: CGPoint to add.
    /// - Returns: result of addition of the two given CGPoints.
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    /// Add a CGPoints to self.
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let point2 = CGPoint(x: 30, y: 30)
    ///     point1 += point2
    ///     // point1 = CGPoint(x: 40, y: 40)
    ///
    /// - Parameters:
    ///   - lhs: self
    ///   - rhs: CGPoint to add.
    static func += (lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }

    /// Subtract two CGPoints.
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let point2 = CGPoint(x: 30, y: 30)
    ///     let point = point1 - point2
    ///     // point = CGPoint(x: -20, y: -20)
    ///
    /// - Parameters:
    ///   - lhs: CGPoint to subtract from.
    ///   - rhs: CGPoint to subtract.
    /// - Returns: result of subtract of the two given CGPoints.
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    /// Subtract a CGPoints from self.
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let point2 = CGPoint(x: 30, y: 30)
    ///     point1 -= point2
    ///     // point1 = CGPoint(x: -20, y: -20)
    ///
    /// - Parameters:
    ///   - lhs: self
    ///   - rhs: CGPoint to subtract.
    static func -= (lhs: inout CGPoint, rhs: CGPoint) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }

    /// Multiply a CGPoint with a scalar
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let scalar = point1 * 5
    ///     // scalar = CGPoint(x: 50, y: 50)
    ///
    /// - Parameters:
    ///   - point: CGPoint to multiply.
    ///   - scalar: scalar value.
    /// - Returns: result of multiplication of the given CGPoint with the scalar.
    static func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
        return CGPoint(x: point.x * scalar, y: point.y * scalar)
    }

    /// Multiply self with a scalar
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     point *= 5
    ///     // point1 = CGPoint(x: 50, y: 50)
    ///
    /// - Parameters:
    ///   - point: self.
    ///   - scalar: scalar value.
    /// - Returns: result of multiplication of the given CGPoint with the scalar.
    static func *= (point: inout CGPoint, scalar: CGFloat) {
        point.x *= scalar
        point.y *= scalar
    }

    /// Multiply a CGPoint with a scalar
    ///
    ///     let point1 = CGPoint(x: 10, y: 10)
    ///     let scalar = 5 * point1
    ///     // scalar = CGPoint(x: 50, y: 50)
    ///
    /// - Parameters:
    ///   - scalar: scalar value.
    ///   - point: CGPoint to multiply.
    /// - Returns: result of multiplication of the given CGPoint with the scalar.
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
