//
//  NSOutlineView+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

@objc public protocol WSNSOutlineViewDelegate:NSOutlineViewDelegate {
    @objc optional func outlineView(outlineView:NSOutlineView, menuFor tableCol:NSTableColumn, items: Any) -> NSMenu?
}


typealias DidSelectedAction = (_ selectedRow: Int) -> Void

extension NSOutlineView {
    
    private struct AssociatedKeys{
        static var actionKey = "actionKey"
    }
    
    @objc dynamic var didSelectedAction: DidSelectedAction? {
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.actionKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_COPY)
        }
        get{
            if let action = objc_getAssociatedObject(self, &AssociatedKeys.actionKey) as? DidSelectedAction {
                return action
            }
            return nil
        }
    }
    
    public func enableClickExpandedOrCollapseItem(_ open: Bool) {
        if open {
            self.action = #selector(clickExpandedOrCollapseItem)
        } else {
            self.action = nil
        }
    }
    
    @objc private func clickExpandedOrCollapseItem() {
        let item = self.item(atRow: self.selectedRow)
        let isItemExpanded = self.isItemExpanded(item)
        if let currentEvent = window?.currentEvent {
          let locationInWindow = currentEvent.locationInWindow
            let row = self.row(at: convert(locationInWindow, from: nil))
            if row == -1 { return }
        }
        
        if isItemExpanded {
            self.collapseItem(item, collapseChildren: true)
        } else {
            self.expandItem(item, expandChildren: false)
        }
        
        self.didSelectedAction?(self.selectedRow)
    }
}

public extension NSOutlineView {
    
    var wsDelegate:WSNSOutlineViewDelegate? {
        return delegate as? WSNSOutlineViewDelegate
    }
    
    /// 返回选择的条目
    /// - Returns: 根据当前选中行，返回对应的item对象
    func selectedItem() -> Any? {
        return self.item(atRow: self.selectedRow)
    }
    
    
    /// 选中一组items
    /// - Parameters:
    ///   - items: 选要选择的item
    ///   - byExtendingSelection: 是否展开节点
    func select(items:[NSView], byExtendingSelection:Bool) {
        let indexs = NSMutableIndexSet()
        items.forEach { (item) in
            let row = self.row(for: item)
            if row >= 0 {
                indexs.add(row)
            }
        }
        self.selectRowIndexes(indexs as IndexSet, byExtendingSelection: byExtendingSelection)
    }
    
    
    /// 覆盖NSView方法，允许为单独的行和列提供上下文菜单。你应该实现-outlineView:menuForTableColumn:byItem:在你的outline委托中。
    /// 如果没有实现，则返回默认菜单。
    /// - Parameter event: 事件
    /// - Returns: 返回事件的菜单
    func wsMenu(for event:NSEvent) -> NSMenu? {

        let point = convert(event.locationInWindow, from: nil)
        
        let col = column(at: point)
        let row = self.row(at: point)
        
        if col >= 0,
           let item = self.item(atRow: row) {
            return wsDelegate?.outlineView?(outlineView: self, menuFor: self.tableColumns[col], items: item)
        }
        
        return super.menu(for: event)
    }
    
}

#endif
