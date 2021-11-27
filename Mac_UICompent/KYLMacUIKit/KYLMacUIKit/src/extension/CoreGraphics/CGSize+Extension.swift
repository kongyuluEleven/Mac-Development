//
//  CGSize+Extension.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(CoreGraphics)
import CoreGraphics

public func min(_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
    return CGSize(width: Swift.min(lhs.width, rhs.width), height: Swift.min(lhs.height, rhs.height))
}

public func max(_ lhs: CGSize, _ rhs: CGSize) -> CGSize {
    return CGSize(width: Swift.max(lhs.width, rhs.width), height: Swift.max(lhs.height, rhs.height))
}


// MARK: - CGSize
public extension CGSize {

    /// width / height, 纵横比 https://en.wikipedia.org/wiki/Aspect_ratio_(image)
    var aspectRatio: CGFloat {
        return width / height
    }
    
    /// 返回宽度和高度中，较大的那个值
    var maxDimension: CGFloat {
        return max(width, height)
    }

    /// 返回宽度和高度中，较小的那个值
    var minDimension: CGFloat {
        return min(width, height)
    }

    var isNaN: Bool {
        return width.isNaN || height.isNaN
    }

    /// CGSize翻转后新Size
    /// CGSize(width: height, height: width)
    var rotated: CGSize {
        return CGSize(width: height, height: width)
    }

    var isNotEmpty: Bool {
        return width > 0 && height > 0
    }

    init(_ sideLength: CGFloat) {
        self.init(width: sideLength, height: sideLength)
    }

    // MARK: -
    
    /// 当前CGSize的宽高进行四舍五入
    /// - Parameter rule: 四舍五入的规则
    /// - Returns: 返回新Size
    func rounded(_ rule: FloatingPointRoundingRule = .toNearestOrAwayFromZero) -> CGSize {
        return CGSize(width: width.rounded(rule), height: height.rounded(rule))
    }

    
    /// 改变当前CGSize的宽高
    /// - Parameter length:  正数是CGSizes的宽度同时缩小length * 2； 负数是CGSizes的宽度同时放大length * 2
    /// - Returns: 改高宽后，新的Size
    func insetBy(_ length: CGFloat) -> CGSize {
        return CGSize(width: width - length * 2, height: height - length * 2)
    }

    // MARK: -

    /// 把区域的纵横比改为指定值(只会放大不会缩小)。
    func scaleToFit(_ aspectRatio: CGFloat) -> CGSize {
        guard aspectRatio > 0 && aspectRatio != self.aspectRatio else { return self }
        return CGSize(width: max(width, height * aspectRatio), height: max(height, width / aspectRatio))
    }

    /// 在保持自身纵横比的前提下，获取小于或等于指定尺寸的值(只会缩小不会放大)。
    func scaleAspectFit(_ size: CGSize) -> CGSize {
        if aspectRatio < size.aspectRatio {
            if height > size.height {
                return CGSize(width: size.height * aspectRatio, height: size.height)
            }
        } else {
            if width > size.width {
                return CGSize(width: size.width, height: size.width / aspectRatio)
            }
        }
        return self
    }

    /// 在保持自身纵横比的前提下，获取最大的可容纳于指定尺寸内的值(可能会缩小也可能放大)。
    func scaleAspectUpOrDownFit(_ size: CGSize) -> CGSize {
        return aspectRatio < size.aspectRatio ? CGSize(width: size.height * aspectRatio, height: size.height) : CGSize(width: size.width, height: size.width / aspectRatio)
    }

    /// 在保持自身纵横比的前提下，获取最小的可充满指定尺寸的值。
    func scaleAspectFill(_ size: CGSize) -> CGSize {
        return aspectRatio < size.aspectRatio ? CGSize(width: size.width, height: size.width / aspectRatio) : CGSize(width: size.height * aspectRatio, height: size.height)
    }

    func isEqual(_ size: CGSize, tolerance: CGFloat) -> Bool {
        return abs(width - size.width) <= tolerance && abs(height - size.height) <= tolerance
    }

    // MARK: -
    /// 当前Size的高宽分别增加值
    /// - Parameter wDelta: 宽度增加值
    /// - Parameter hDelta: 高度增加值
    func add(width wDelta: CGFloat = 0, height hDelta: CGFloat = 0) -> CGSize {
        return CGSize(width: width + wDelta, height: height + hDelta)
    }

    
    /// 替换当前Size的高宽值
    /// - Parameter width: 宽度值
    /// - Parameter height: 高度值
    func with(width: CGFloat? = nil, height: CGFloat? = nil) -> CGSize {
        return CGSize(width: width ?? self.width, height: height ?? self.height)
    }

    mutating func set(width: CGFloat? = nil, height: CGFloat? = nil) {
        self = self.with(width: width, height: height)
    }

    // MARK: -

    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width, height: lhs.height - rhs.height)
    }

    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    static func * (size: CGSize, factor: CGFloat) -> CGSize {
        return CGSize(width: size.width * factor, height: size.height * factor)
    }

    static func / (size: CGSize, divisor: CGFloat) -> CGSize {
        return CGSize(width: size.width / divisor, height: size.height / divisor)
    }

    static func += (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs + rhs
    }

    static func -= (lhs: inout CGSize, rhs: CGSize) {
        lhs = lhs - rhs
    }

    static func *= (size: inout CGSize, factor: CGFloat) {
        size = size * factor
    }

    static func /= (size: inout CGSize, divisor: CGFloat) {
        size = size / divisor
    }

}

extension CGSize {
    static func * (lhs: Self, rhs: Double) -> Self {
        .init(width: lhs.width * CGFloat(rhs), height: lhs.height * CGFloat(rhs))
    }
    
    init(widthHeight: CGFloat) {
        self.init(width: widthHeight, height: widthHeight)
    }

    var cgRect: CGRect { .init(origin: .zero, size: self) }

    func aspectFit(to boundingSize: CGSize) -> Self {
        let ratio = min(boundingSize.width / width, boundingSize.height / height)
        return self * ratio
    }

    func aspectFit(to widthHeight: CGFloat) -> Self {
        aspectFit(to: Self(width: widthHeight, height: widthHeight))
    }
}


#endif
