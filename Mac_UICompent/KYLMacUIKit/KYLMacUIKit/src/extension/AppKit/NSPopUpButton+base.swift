//
//  NSPopUpButton+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

//MARK: - 属性
public extension NSPopUpButton {
    
}


//MARK: - 方法
public extension NSPopUpButton {
    
    /// 添加分割线
    func addSeparatorItem(_ tag:Int = 0) {
        let item = NSMenuItem.separator()
        item.tag = tag
        menu?.addItem(item)
        synchronizeTitleAndSelectedItem()
    }
    
    
    /// 添加一个item
    /// 类似于-addItemWithTitle:，但是允许指定一个标签。但是，
    /// 它不会像-[NSPopUpButton addItemWithTitle:]那样删除任何其他具有相同名称的项。它还返回创建的项。
    /// - Parameters:
    ///   - title: 标题
    ///   - tag: tag值
    func addItem(title:String, tag:Int) -> NSMenuItem {
        let item = NSMenuItem(title)
        item.tag = tag
        menu?.add(item)
        synchronizeTitleAndSelectedItem()
        return item
    }
    
    /// 添加一个选项
    /// - Parameters:
    ///   - title: 显示的标题
    ///   - folder: 文件路径
    ///   - selected: 是否被选中
    func addItem(_ title: String,
                _ folder: String?,
                _ selected: Bool,
                _ tag:Int = 0,
                _ showIcon:Bool = false
    ) {
        guard let menu = menu else {return}
        
        let item = NSMenuItem.init(title: title,
                                   action: nil,
                                   keyEquivalent: "")
        item.representedObject = folder
        item.tag = tag
        if showIcon , let folder = folder {
            let icon = NSWorkspace.shared.icon(forFile: folder)
            icon.size = NSMakeSize(16, 16)
            item.image = icon
        }
        
        menu.addItem(item)
    }
    
    
    /// 插入一个item
    /// - Parameters:
    ///   - index: 需要插入的下标
    ///   - title: 标题
    ///   - folder: 文件路径
    ///   - selected: 是否被选中
    func insertItem(_ index: Int,
                    _ title: String,
                    _ folder: String,
                    _ selected: Bool,
                    _ tag:Int = 0,
                    _ showIcon:Bool = false) {
        guard let menu = menu else {return}
        
        let item = NSMenuItem.init(title: title,
                                   action: nil,
                                   keyEquivalent: "")
        item.representedObject = folder
        item.tag = tag
        if showIcon {
            let icon = NSWorkspace.shared.icon(forFile: folder)
            icon.size = NSMakeSize(16, 16)
            item.image = icon
        }
        
        menu.insertItem(item, at: max(index, 0))
    }
    
    

    
    /// 在对应下标插入分割线
    /// - Parameter index: 需要插入的下标
    func insertSeparatorItem(atIndex index: Int, _ tag:Int = 0) {
        guard let menu = menu else {return}
        
        let seperateItem = NSMenuItem.separator()
        seperateItem.tag = tag
        seperateItem.representedObject = nil
        menu.insertItem(seperateItem, at: max(index, menu.items.count))
    }
    
    
    /// 添加一个通用菜单项
    /// - Parameters:
    ///   - title: 显示的标题
    ///   - target: 监听事件的目标对象
    ///   - selector: 点击事件的回调方法
    func addCustomItem(_ title: String,
                       _ target: AnyObject? = nil,
                       _ selector: Selector? = nil,
                       _ tag:Int = 0) {
        guard let menu = menu else {return}
        
        let item = NSMenuItem.init(title: title,
                                   action: selector,
                                   keyEquivalent: title)
        item.representedObject = nil
        item.tag = tag
        if let target = target , let selector = selector {
            item.target = target
            item.action = selector
        }
        menu.addItem(item)
    }
    
}


#endif
