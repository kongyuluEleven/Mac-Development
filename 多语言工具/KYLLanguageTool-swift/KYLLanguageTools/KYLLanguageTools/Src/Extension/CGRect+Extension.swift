//
//  CGRect+Extension.swift
//  BaseUIKit
//
//  Created by kongyulu on 2020/12/22.
//  Copyright © 2020 Wondershare. All rights reserved.
//

#if canImport(CoreGraphics)
import CoreGraphics


public extension CGFloat {
  var radians: CGFloat {
    return self * CGFloat(2 * Double.pi / 360)
  }
  
  var degrees: CGFloat {
    return 360.0 * self / CGFloat(2 * Double.pi)
  }
}

public func min(_ lhs: CGRect, _ rhs: CGRect) -> CGRect {
    return CGRect(origin: min(lhs.origin, rhs.origin), size: min(lhs.size, rhs.size))
}

public func max(_ lhs: CGRect, _ rhs: CGRect) -> CGRect {
    return CGRect(origin: max(lhs.origin, rhs.origin), size: max(lhs.size, rhs.size))
}

// MARK: - CGRect
public extension CGRect {

    var isNotEmpty: Bool {
        return !isEmpty
    }

    var isNaN: Bool {
        return origin.isNaN || size.isNaN
    }

    /// width / height
    var aspectRatio: CGFloat {
        return size.aspectRatio
    }

    var topLeft: CGPoint {
        get {
            return CGPoint(x: minX, y: minY)
        }
        set {
            self.origin = newValue
        }
    }

    var topCenter: CGPoint {
        get {
            return CGPoint(x: midX, y: minY)
        }
        set {
            self.origin = CGPoint(x: newValue.x - width / 2, y: newValue.y)
        }
    }

    var topRight: CGPoint {
        get {
            return CGPoint(x: maxX, y: minY)
        }
        set {
            self.origin = CGPoint(x: newValue.x - width, y: newValue.y)
        }
    }

    var middleLeft: CGPoint {
        get {
            return CGPoint(x: minX, y: midY)
        }
        set {
            self.origin = CGPoint(x: newValue.x, y: newValue.y - height / 2)
        }
    }

    var center: CGPoint {
        get {
            return CGPoint(x: midX, y: midY)
        }
        set {
            self.origin = CGPoint(x: newValue.x - width / 2, y: newValue.y - height / 2)
        }
    }

    var middleRight: CGPoint {
        get {
            return CGPoint(x: maxX, y: midY)
        }
        set {
            self.origin = CGPoint(x: newValue.x - width, y: newValue.y - height / 2)
        }
    }

    var bottomLeft: CGPoint {
        get {
            return CGPoint(x: minX, y: maxY)
        }
        set {
            self.origin = CGPoint(x: newValue.x, y: newValue.y - height)
        }
    }

    var bottomCenter: CGPoint {
        get {
            return CGPoint(x: midX, y: maxY)
        }
        set {
            self.origin = CGPoint(x: newValue.x - width / 2, y: newValue.y - height)
        }
    }

    var bottomRight: CGPoint {
        get {
            return CGPoint(x: maxX, y: maxY)
        }
        set {
            self.origin = CGPoint(x: newValue.x - width, y: newValue.y - height)
        }
    }

    // MARK: -

    /// 根据中心点和边长创建正方形
    init(center: CGPoint, sideLength: CGFloat) {
        self.init(center: center, width: sideLength, height: sideLength)
    }

    /// 根据中心点和宽高创建矩形
    init(center: CGPoint, width: CGFloat, height: CGFloat) {
        self.init(center: center, size: CGSize(width: width, height: height))
    }

    /// 根据中心点和长宽创建矩形
    init(center: CGPoint, size: CGSize) {
        self.init()
        self.size = size
        self.center = center
    }

    init(sideLength: CGFloat) {
        self.init(width: sideLength, height: sideLength)
    }

    init(width: CGFloat, height: CGFloat) {
        self.init(x: 0, y: 0, width: width, height: height)
    }

    init(x: CGFloat, y: CGFloat, size: CGSize) {
        self.init(origin: CGPoint(x: x, y: y), size: size)
    }

    init(origin: CGPoint, width: CGFloat, height: CGFloat) {
        self.init(origin: origin, size: CGSize(width: width, height: height))
    }

    init(pointA: CGPoint, pointB: CGPoint) {
        self.init(x: min(pointA.x, pointB.x), y: min(pointA.y, pointB.y), width: abs(pointA.x - pointB.x), height: abs(pointA.y - pointB.y))
    }

    /// 获取包含所有给定点的最小的矩形区域
    static func minRect(_ points: CGPoint...) -> CGRect {
        return minRect(points)
    }

    static func minRect(_ points: [CGPoint]) -> CGRect {
        guard let firstPoint = points.first else { return .zero }

        var minX = firstPoint.x
        var minY = firstPoint.y
        var maxX = minX
        var maxY = minY

        points.forEach {
            minX = min(minX, $0.x)
            minY = min(minY, $0.y)
            maxX = max(maxX, $0.x)
            maxY = max(maxY, $0.y)
        }
        return CGRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }

    /// 返回一个包含所有给定矩形的大矩形
    static func unionRects(_ rects: [CGRect]) -> CGRect {
        guard rects.isNotEmpty else { return .zero }
        var rects = rects
        let fisrtRect = rects.removeFirst()
        return rects.reduce(fisrtRect) { $0.union($1) }
    }

    /// 返回一个包含所有给定矩形和点的大矩形
    static func union(rects: [CGRect], points: [CGPoint]) -> CGRect {
        guard points.isNotEmpty else { return CGRect.unionRects(rects) }
        let pointsRect = minRect(points)
        return rects.reduce(pointsRect) { $0.union($1) }
    }

    /// 是否是正方形
    func isSquare(tolerance: CGFloat = .ulpOfOne) -> Bool {
        guard width > 0 && height > 0 else { return false }
        return abs(width - height) < max(tolerance, 0)
    }

    /// 是否包含路径
    func contains(path: CGPath) -> Bool {
        let rect = path.boundingBoxOfPath
        return self.contains(rect)
    }

    /// 是否包含点
    func contains(point: CGPoint, tolerance: CGFloat = 0) -> Bool {
        let toleratedRect = self.insetBy(-tolerance)
        return toleratedRect.contains(point)
    }

    /// 在保持自身纵横比的前提下，获取能在容器内完整显示出来的值。
    func scaleAspectFit(_ bounds: CGRect) -> CGRect {
        guard !bounds.contains(self) else { return self }

        let newSize = size.scaleAspectFit(bounds.size)
        let maxOrigin = bounds.bottomRight.add(x: -newSize.width, y: -newSize.height)
        let newOrigin = min(max(origin, bounds.origin), maxOrigin)
        return CGRect(origin: newOrigin, size: newSize)
    }

    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGRect {
        return CGRect(origin: origin.rounded(rule), size: size.rounded(rule))
    }

    func insetBy(_ length: CGFloat, safely: Bool = false) -> CGRect {
        if safely {
            return self.insetBy(dx: min(length, width / 2), dy: min(length, height / 2))
        }
        return self.insetBy(dx: length, dy: length)
    }

    func isEqual(_ rect: CGRect, tolerance: CGFloat) -> Bool {
        return size.isEqual(rect.size, tolerance: tolerance) && origin.isEqual(rect.origin, tolerance: tolerance)
    }

    // MARK: -

    func add(x: CGFloat = 0, y: CGFloat = 0, width: CGFloat = 0, height: CGFloat = 0) -> CGRect {
        return CGRect(origin: origin.add(x: x, y: y), size: size.add(width: width, height: height))
    }

    func with(x: CGFloat? = nil, y: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil) -> CGRect {
        return CGRect(origin: origin.with(x: x, y: y), size: size.with(width: width, height: height))
    }

    func with(origin: CGPoint? = nil, size: CGSize? = nil) -> CGRect {
        return CGRect(origin: origin ?? self.origin, size: size ?? self.size)
    }

    func with(center: CGPoint) -> CGRect {
        return CGRect(center: center, size: size)
    }

    func with(midX: CGFloat? = nil, midY: CGFloat? = nil) -> CGRect {
        return self.with(center: CGPoint(x: midX ?? self.midX, y: midY ?? self.midY))
    }

    func with(maxX: CGFloat? = nil, maxY: CGFloat? = nil) -> CGRect {
        let point = CGPoint(x: (maxX ?? self.maxX) - width, y: (maxY ?? self.maxY) - height)
        return self.with(origin: point)
    }

    mutating func set(x: CGFloat? = nil, y: CGFloat? = nil, width: CGFloat? = nil, height: CGFloat? = nil) {
        self = self.with(x: x, y: y, width: width, height: height)
    }

    mutating func set(origin: CGPoint? = nil, size: CGSize? = nil) {
        self = self.with(origin: origin, size: size)
    }

    // MARK: -

    static func - (lhs: CGRect, rhs: CGSize) -> CGRect {
        return CGRect(origin: lhs.origin, size: lhs.size - rhs)
    }

    static func + (lhs: CGRect, rhs: CGSize) -> CGRect {
        return CGRect(origin: lhs.origin, size: lhs.size + rhs)
    }

    static func - (lhs: CGRect, rhs: CGPoint) -> CGRect {
        return CGRect(origin: lhs.origin - rhs, size: lhs.size)
    }

    static func + (lhs: CGRect, rhs: CGPoint) -> CGRect {
        return CGRect(origin: lhs.origin + rhs, size: lhs.size)
    }

    static func * (rect: CGRect, factor: CGFloat) -> CGRect {
        return CGRect(origin: rect.origin * factor, size: rect.size * factor)
    }

    static func / (rect: CGRect, divisor: CGFloat) -> CGRect {
        return CGRect(origin: rect.origin / divisor, size: rect.size / divisor)
    }

}

extension CGRect {

    init(widthHeight: CGFloat) {
        self.init()
        self.origin = .zero
        self.size = CGSize(widthHeight: widthHeight)
    }

    var x: CGFloat {
        get { origin.x }
        set {
            origin.x = newValue
        }
    }

    var y: CGFloat {
        get { origin.y }
        set {
            origin.y = newValue
        }
    }

    var width: CGFloat {
        get { size.width }
        set {
            size.width = newValue
        }
    }

    var height: CGFloat {
        get { size.height }
        set {
            size.height = newValue
        }
    }

    // MARK: - Edges

    var left: CGFloat {
        get { x }
        set {
            x = newValue
        }
    }

    var right: CGFloat {
        get { x + width }
        set {
            x = newValue - width
        }
    }

    var top: CGFloat {
        get { y + height }
        set {
            y = newValue - height
        }
    }

    var bottom: CGFloat {
        get { y }
        set {
            y = newValue
        }
    }


    var centerX: CGFloat {
        get { midX }
        set {
            center = CGPoint(x: newValue, y: midY)
        }
    }

    var centerY: CGFloat {
        get { midY }
        set {
            center = CGPoint(x: midX, y: newValue)
        }
    }

    /**
    Returns a `CGRect` where `self` is centered in `rect`.
    */
    func centered(
        in rect: Self,
        xOffset: Double = 0,
        yOffset: Double = 0
    ) -> Self {
        .init(
            x: ((rect.width - size.width) / 2) + CGFloat(xOffset),
            y: ((rect.height - size.height) / 2) + CGFloat(yOffset),
            width: size.width,
            height: size.height
        )
    }

    /**
    Returns a CGRect where `self` is centered in `rect`.

    - Parameters:
        - xOffsetPercent: The offset in percentage of `rect.width`.
    */
    func centered(
        in rect: Self,
        xOffsetPercent: Double,
        yOffsetPercent: Double
    ) -> Self {
        centered(
            in: rect,
            xOffset: Double(rect.width) * xOffsetPercent,
            yOffset: Double(rect.height) * yOffsetPercent
        )
    }
}

#endif
