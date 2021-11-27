//
//  NSBezierPath+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - 属性

public extension NSBezierPath {
    
    /// 获取cgPath
    var cgPath: CGPath {
        let path = CGMutablePath()
        var points = [CGPoint](repeating: .zero, count: 3)
        for i in 0 ..< self.elementCount {
            let type = self.element(at: i, associatedPoints: &points)
            
            switch type {
            case .moveTo:
                path.move(to: points[0])
                
            case .lineTo:
                path.addLine(to: points[0])
                
            case .curveTo:
                path.addCurve(to: points[2], control1: points[0], control2: points[1])
                
            case .closePath:
                path.closeSubpath()
                
            @unknown default:
                break
            }
        }
        return path
    }
}


// MARK: - Initializers

public extension NSBezierPath {
    /// 用一行从一个CGPoint到另一个CGPoint初始化UIBezierPath。
    ///
    /// - Parameters:
    ///   - from: 路径的起点。
    ///   - to: 这条曲线的终点。
    convenience init(from: CGPoint, to otherPoint: CGPoint) {
        self.init()
        move(to: from)
        line(to: otherPoint)
    }

    /// 用直线初始化连接给定CGPoints的UIBezierPath。
    ///
    /// - Parameter points: 这条曲线应该包含的点。
    convenience init(points: [CGPoint]) {
        self.init()
        if !points.isEmpty {
            move(to: points[0])
            for point in points[1...] {
                line(to: point)
            }
        }
    }

    /// 用给定的CGPoints初始化一个多边形uibezier路径。至少3个顶点必须给出。
    ///
    /// - Parameter points: 路径应该形成的多边形的点。
    convenience init?(polygonWithPoints points: [CGPoint]) {
        guard points.count > 2 else { return nil }
        self.init()
        move(to: points[0])
        for point in points[1...] {
            line(to: point)
        }
        close()
    }

    /// 用给定大小的椭圆路径初始化NSBezierPath。
    ///
    /// - Parameters:
    ///   - size: 椭圆的宽度和高度。
    ///   - centered: 椭圆是否应在其坐标空间居中。
    convenience init(ovalOf size: CGSize, centered: Bool) {
        let origin = centered ? CGPoint(x: -size.width / 2, y: -size.height / 2) : .zero
        self.init(ovalIn: CGRect(origin: origin, size: size))
    }

    /// 用给定大小的矩形路径初始化NSBezierPath。
    ///
    /// - Parameters:
    ///   - size: 矩形的宽度和高度。
    ///   - centered: 椭圆是否应在其坐标空间居中。
    convenience init(rectOf size: CGSize, centered: Bool) {
        let origin = centered ? CGPoint(x: -size.width / 2, y: -size.height / 2) : .zero
        self.init(rect: CGRect(origin: origin, size: size))
    }
}

#endif
