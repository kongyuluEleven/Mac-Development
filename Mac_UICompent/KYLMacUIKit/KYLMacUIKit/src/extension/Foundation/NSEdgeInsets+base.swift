//
//  NSEdgeInsets+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation


// MARK: - 属性

public extension NSEdgeInsets {
    /// 默认为空的NSEdgeInsets对象
    static let zero = NSEdgeInsetsZero

    /// 水平边距，左边距+右边距
    var horizontal: Double { Double(left + right) }
    
    /// 垂直边距，上边距+右边距
    var vertical: Double { Double(top + bottom) }
}


// MARK: - 构造函数

public extension NSEdgeInsets {
    /// 构造函数，初始化NSEdgeInsets对象
    ///
    ///  let inset = NSEdgeInsets()  => 返回一个初始化四个边距都为0的zero
    ///  let inset2 = NSEdgeInsets(top:1,left:2, bottom:3, right:4)
    ///
    /// - Parameters:
    ///   - top: 上边距，默认为0
    ///   - left: 左边距，默认为0
    ///   - bottom: 低边距，默认为0
    ///   - right: 右边距，默认为0
    init(
        top: Double = 0,
        left: Double = 0,
        bottom: Double = 0,
        right: Double = 0
    ) {
        self.init()
        self.top = CGFloat(top)
        self.left = CGFloat(left)
        self.bottom = CGFloat(bottom)
        self.right = CGFloat(right)
    }

    
    /// 构造函数，初始化NSEdgeInsets对象，每个边距都设置相同
    ///
    /// let insert = NSEdgeInsets(all:5) => 初始化一个边距都为5的NSEdgeInsets对象
    ///
    /// - Parameter all: 每个边距都是设置的值
    init(all: Double) {
        self.init(
            top: all,
            left: all,
            bottom: all,
            right: all
        )
    }

    
    /// 构造函数，初始化NSEdgeInsets对象，上下边距相等对称，左右边距相等对称
    ///
    /// let insert = NSEdgeInsets(horizontal: 5.0, vertical: 6.0) => 初始化一个NSEdgeInsets对象，水平方向的边距左右边距都为5， 垂直方向的上下边距都为6
    ///
    /// - Parameters:
    ///   - horizontal: 水平方向的边距
    ///   - vertical: 垂直方向的边距
    init(horizontal: Double, vertical: Double) {
        self.init(
            top: CGFloat(vertical),
            left: CGFloat(horizontal),
            bottom: CGFloat(vertical),
            right: CGFloat(horizontal)
        )
    }

}


// MARK: - 方法

public extension NSEdgeInsets {
    /// 创建一个' EdgeInsets '，将inset值应用于所有(top, bottom, right, left)
    ///
    /// - Parameter inset:要应用于所有边缘的插入。
    init(inset: CGFloat) {
        self.init(top: inset, left: inset, bottom: inset, right: inset)
    }

    /// 创建一个' EdgeInsets '，其水平值平均划分并应用于左右。
    ///  而垂直值则是等分的并分别应用于顶部和底部。
    ///
    ///
    /// - Parameter horizontal: 要应用于左右的偏差值。
    /// - Parameter vertical: 要应用于上下的偏差值。
    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical / 2, left: horizontal / 2, bottom: vertical / 2, right: horizontal / 2)
    }

    /// 基于当前值和顶偏移量创建一个“EdgeInsets”。
    ///
    /// - Parameters:
    ///   - top: 要应用于上边缘的偏移量。
    /// - Returns: EdgeInsets给定偏移量的偏移量。
    func insetBy(top: CGFloat) -> NSEdgeInsets {
        return NSEdgeInsets(top: self.top + top, left: left, bottom: bottom, right: right)
    }

    /// 基于当前值和左偏移量创建一个' EdgeInsets '。
    ///
    /// - Parameters:
    ///   - left: 要应用于左边缘的偏移量。
    /// - Returns: EdgeInsets给定偏移量的偏移量。
    func insetBy(left: CGFloat) -> NSEdgeInsets {
        return NSEdgeInsets(top: top, left: self.left + left, bottom: bottom, right: right)
    }

    /// 基于当前值和底部偏移量创建一个“EdgeInsets”。
    ///
    /// - Parameters:
    ///   - bottom: 要应用于底边的偏移量。
    /// - Returns: EdgeInsets给定偏移量的偏移量。
    func insetBy(bottom: CGFloat) -> NSEdgeInsets {
        return NSEdgeInsets(top: top, left: left, bottom: self.bottom + bottom, right: right)
    }

    /// 基于当前值和右偏移量创建一个“EdgeInsets”。
    ///
    /// - Parameters:
    ///   - right: 应用于右边缘的偏移量。
    /// - Returns: EdgeInsets给定偏移量的偏移量。
    func insetBy(right: CGFloat) -> NSEdgeInsets {
        return NSEdgeInsets(top: top, left: left, bottom: bottom, right: self.right + right)
    }

    /// 根据当前值和水平值等分并应用于右偏移量和左偏移量创建一个“EdgeInsets”。
    ///
    /// - Parameters:
    ///   - horizontal: 用于左右的偏移量。
    /// - Returns: EdgeInsets给定偏移量的偏移量。
    func insetBy(horizontal: CGFloat) -> NSEdgeInsets {
        return NSEdgeInsets(top: top, left: left + horizontal / 2, bottom: bottom, right: right + horizontal / 2)
    }

    /// 基于当前值和垂直值创建一个“EdgeInsets”，平均划分并应用于顶部和底部。
    ///
    /// - Parameters:
    ///   - vertical: 应用于顶部和底部的偏移量。
    /// - Returns: EdgeInsets给定偏移量的偏移量。
    func insetBy(vertical: CGFloat) -> NSEdgeInsets {
        return NSEdgeInsets(top: top + vertical / 2, left: left, bottom: bottom + vertical / 2, right: right)
    }
}



// MARK: - 操作符

extension NSEdgeInsets: Equatable {
    /// 返回一个布尔值，该值指示两个值是否相等。
    ///
    /// 等式是不等式的反义词. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: 要比较的值
    ///   - rhs: 另一个比较值
    public static func == (lhs: NSEdgeInsets, rhs: NSEdgeInsets) -> Bool {
        return lhs.top == rhs.top &&
            lhs.left == rhs.left &&
            lhs.bottom == rhs.bottom &&
            lhs.right == rhs.right
    }
    
    /// 添加两个' EdgeInsets '的所有属性，以创建它们的添加。
    ///
    /// - Parameters:
    ///   - lhs: 左边的表达式
    ///   - rhs: 右边的表达式
    /// - Returns: 一个新的' EdgeInsets '实例，其中' lhs '和' rhs '的值被相加。
    static func + (_ lhs: NSEdgeInsets, _ rhs: NSEdgeInsets) -> NSEdgeInsets {
        return NSEdgeInsets(top: lhs.top + rhs.top,
                          left: lhs.left + rhs.left,
                          bottom: lhs.bottom + rhs.bottom,
                          right: lhs.right + rhs.right)
    }

    /// 将两个' EdgeInsets '的所有属性添加到左边的实例中。
    ///
    /// - Parameters:
    ///   - lhs: 被修改的左边表达式
    ///   - rhs: 右边表达式
    static func += (_ lhs: inout NSEdgeInsets, _ rhs: NSEdgeInsets) {
        lhs.top += rhs.top
        lhs.left += rhs.left
        lhs.bottom += rhs.bottom
        lhs.right += rhs.right
    }
}


#endif

