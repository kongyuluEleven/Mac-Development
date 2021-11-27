//
//  NSPredicate+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

// MARK: - 属性

public extension NSPredicate {
    /// 返回一个由非谓词组成的新谓词
    var not: NSCompoundPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: self)
    }
}

// MARK: - 方法

public extension NSPredicate {
    /// 返回一个新的谓词，该谓词由与-ing参数组成。
    ///
    /// - Parameter predicate: NSPredicate
    /// - Returns: NSCompoundPredicate
    func and(_ predicate: NSPredicate) -> NSCompoundPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [self, predicate])
    }

    /// 返回一个新的谓词，该谓词由参数与谓词形成或ing。
    ///
    /// - Parameter predicate: NSPredicate
    /// - Returns: NSCompoundPredicate
    func or(_ predicate: NSPredicate) -> NSCompoundPredicate {
        return NSCompoundPredicate(orPredicateWithSubpredicates: [self, predicate])
    }
}

// MARK: - 操作符

public extension NSPredicate {
    /// 取反操作，返回一个由非谓词组成的新谓词。
    /// - Parameters: rhs: NSPredicate to convert.
    /// - Returns: NSCompoundPredicate
    static prefix func ! (rhs: NSPredicate) -> NSCompoundPredicate {
        return rhs.not
    }

    /// 相加操作，返回一个新的谓词，该谓词由与-ing参数组成。
    ///
    /// - Parameters:
    ///   - lhs: NSPredicate.
    ///   - rhs: NSPredicate.
    /// - Returns: NSCompoundPredicate
    static func + (lhs: NSPredicate, rhs: NSPredicate) -> NSCompoundPredicate {
        return lhs.and(rhs)
    }

    /// 或运算，返回一个新的谓词，该谓词由参数与谓词形成或ing。
    ///
    /// - Parameters:
    ///   - lhs: NSPredicate.
    ///   - rhs: NSPredicate.
    /// - Returns: NSCompoundPredicate
    static func | (lhs: NSPredicate, rhs: NSPredicate) -> NSCompoundPredicate {
        return lhs.or(rhs)
    }

    /// 减操作，返回一个由移除谓词的实参而形成的新谓词。
    ///
    /// - Parameters:
    ///   - lhs: NSPredicate.
    ///   - rhs: NSPredicate.
    /// - Returns: NSCompoundPredicate
    static func - (lhs: NSPredicate, rhs: NSPredicate) -> NSCompoundPredicate {
        return lhs + !rhs
    }
}

#endif
