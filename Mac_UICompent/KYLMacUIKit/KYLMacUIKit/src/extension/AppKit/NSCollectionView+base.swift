//
//  NSCollectionView+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - 属性

public extension NSCollectionView {
    /// collectionView中最后一节的索引。
    var lastSection: Int {
        return numberOfSections > 0 ? numberOfSections - 1 : 0
    }
}

// MARK: - Methods

public extension NSCollectionView {
    /// collectionView所有部分中所有项的数目。
    ///
    /// - Returns: collectionView中所有行的计数。
    func numberOfItems() -> Int {
        var section = 0
        var itemsCount = 0
        while section < numberOfSections {
            itemsCount += numberOfItems(inSection: section)
            section += 1
        }
        return itemsCount
    }

    /// section中最后一项的IndexPath。
    ///
    /// - Parameter section: 将最后一项放入。
    /// - Returns: 可选last indexPath用于section中的最后一项(如果适用)。
    func indexPathForLastItem(inSection section: Int) -> IndexPath? {
        guard section >= 0 else {
            return nil
        }
        guard section < numberOfSections else {
            return nil
        }
        guard numberOfItems(inSection: section) > 0 else {
            return IndexPath(item: 0, section: section)
        }
        return IndexPath(item: numberOfItems(inSection: section) - 1, section: section)
    }


    /// 安全地滚动到可能无效的IndexPath
    ///
    /// - Parameters:
    ///   - indexPath: 指向要滚动到的IndexPath
    ///   - scrollPosition: 滚动位置
    func safeScrollToItem(at indexPath: IndexPath, at scrollPosition: NSCollectionView.ScrollPosition) {
        guard indexPath.item >= 0,
            indexPath.section >= 0,
            indexPath.section < numberOfSections,
            indexPath.item < numberOfItems(inSection: indexPath.section) else {
            return
        }
        scrollToItems(at:[indexPath], scrollPosition: scrollPosition)
    }

    /// 检查IndexPath在CollectionView中是否有效
    ///
    /// - Parameter indexPath: 要检查的索引
    /// - Returns: 有效或无效索引的布尔值
    func isValidIndexPath(_ indexPath: IndexPath) -> Bool {
        return indexPath.section >= 0 &&
            indexPath.item >= 0 &&
            indexPath.section < numberOfSections &&
            indexPath.item < numberOfItems(inSection: indexPath.section)
    }
}



#endif
