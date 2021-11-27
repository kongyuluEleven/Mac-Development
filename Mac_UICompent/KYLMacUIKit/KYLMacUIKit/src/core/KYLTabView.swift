//
//  KTabView.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

import Cocoa

@objc protocol KTabViewDelegate : NSObjectProtocol {
   @objc optional func kTabView(_ tabView: KYLTabView, willSelect tabViewItem: NSButton?)

   @objc optional func kTabView(_ tabView: KYLTabView, didSelect tabViewItem: NSButton?)
}

class KYLTabView: NSStackView {
    private var itemActionDic: [NSButton :(target: AnyObject?, action: Selector?)] = [:]
    private var underlineLayer : CALayer = CALayer.init()
    private var selectedIndex: Int = 0
    
    
    /// 选中切换代理方法
    weak open var tabViewDelegate: KTabViewDelegate?
    open var isDrawUnderline : Bool = true {
        didSet {
            underlineLayer.isHidden = !isDrawUnderline
        }
    }
    
    /// 下划线的颜色
    open var underlineColor : NSColor? {
        didSet {
            underlineLayer.backgroundColor = underlineColor?.cgColor
        }
    }
    
    /// 下划线离按钮底部的距离
    open var underlineEdgeInsetBottom : CGFloat = 1.0{
        didSet {
            if let selectedButton = selectedTabViewItem() {
                self.drawUndownline(selectedButton)
            }
        }
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        configItemViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override public func awakeFromNib() {
        super.awakeFromNib()
        configItemViews()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSView.frameDidChangeNotification, object: nil)
    }
    
    //MARK:- 私有方法
    private func configItemViews() {
        for itemView in views {
            if let button = itemView as? NSButton{
                saveButtonAction(button)
            }
        }
        
        wantsLayer = true
        underlineLayer.backgroundColor = NSColor.red.cgColor
        layer?.addSublayer(underlineLayer)
        selectTabViewItem(at: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(tabviewFrameDidChangeNotification(_:)), name: NSView.frameDidChangeNotification, object: nil)
    }
    
    private func cleanSelectedTabView(exceptionItem: NSButton?){
        for item in views {
            if item == exceptionItem {
                continue
            }
            
            (item as? NSButton)?.state = .off
        }
    }
    
    private func drawUndownline(_ selectedButton: NSButton) {
        let viewFrame = NSInsetRect(selectedButton.frame, 1, 0)
        self.underlineLayer.frame = NSMakeRect(viewFrame.origin.x, viewFrame.origin.y - underlineEdgeInsetBottom, NSWidth(viewFrame), 1)
    }
    
    private func setSelectedButton(_ selectedButton: NSButton) {
        let selIndex = self.indexOfTabViewItem(selectedButton)
        guard selIndex >= 0 else {
            return
        }
        
        selectedButton.state = .on
        selectedIndex = selIndex
        cleanSelectedTabView(exceptionItem: selectedButton)
    }
    
    private func saveButtonAction(_ tabViewItem: NSButton) {
        itemActionDic[tabViewItem] = (tabViewItem.target, tabViewItem.action)
        (tabViewItem.cell as? NSButtonCell)?.setButtonType(NSButton.ButtonType.pushOnPushOff)
        tabViewItem.action = #selector(clicktabViewItem(_:))
        tabViewItem.target = self
    }
    
    //MARK:- Public接口方法
    
    /// Tab按钮的个数
    open var numberOfviews: Int {
        get{
            return views.count
        }
    }
    
    
    /// 设置Tab为选中状态
    /// - Parameter index: 选中index
    open func selectTabViewItem(at index: Int){
        if index > -1, index < views.count  {
            if let selectedButton = views[index] as? NSButton {
                self.setSelectedButton(selectedButton)
                self.drawUndownline(selectedButton)
            }
        }else{
            self.underlineLayer.frame = NSMakeRect(0, 0, 0, 0)
        }
    }

    /// 添加Tab按钮到管理器中
    /// - Parameter tabViewItem: 按钮
    open func addTabViewItem(_ tabViewItem: NSButton){
        guard let selectedButton = selectedTabViewItem() else { return  }
        
        addView(tabViewItem, in: NSStackView.Gravity.leading)
        saveButtonAction(tabViewItem)
        
        var selIndex = indexOfTabViewItem(selectedButton)
        selIndex = selIndex >= 0 ? selIndex : 0
        selectTabViewItem(at: selIndex)
    }
    
    
    /// 插入按钮到Tab管理器
    /// - Parameter tabViewItem: 按钮
    /// - Parameter index: index
    open func insertTabViewItem(_ tabViewItem: NSButton, at index: Int){
        guard let selectedButton = selectedTabViewItem() else { return  }
        
        insertView(tabViewItem, at: index, in: NSStackView.Gravity.leading)
        saveButtonAction(tabViewItem)
        
        var selIndex = indexOfTabViewItem(selectedButton)
        selIndex = selIndex >= 0 ? selIndex : 0
        selectTabViewItem(at: selIndex)
    }
    
    
    /// 从Tab管理器中删除按钮
    /// - Parameter tabViewItem: 按钮
    open func removeTabViewItem(_ tabViewItem: NSButton) {
        var selIndex = indexOfTabViewItem(tabViewItem)
        
        itemActionDic[tabViewItem] = nil
        removeView(tabViewItem)

        selIndex = selIndex < views.count ? selIndex : 0
        selectTabViewItem(at: selIndex)
    }
    
    
    /// 获取Index指定按钮
    /// - Parameter tabViewItem: 按钮
    open func indexOfTabViewItem(_ tabViewItem: NSButton) -> Int {
        if let index = views.firstIndex(of: tabViewItem) {
            return index
        }
        return -1
    }
    
    
    /// 获取Tab按钮从管理器中
    /// - Parameter index: index按钮
    open func tabViewItem(at index: Int) -> NSButton? {
        if index > -1, index < views.count  {
            return (views[index] as? NSButton)
        }
        return nil
    }
    
    
    /// 返回选中Tab按钮
    open func selectedTabViewItem() -> NSButton? {
        return tabViewItem(at: selectedIndex)
    }

    @objc func clicktabViewItem(_ sender: NSButton) {
        tabViewDelegate?.kTabView?(self, willSelect: sender)
        
        self.setSelectedButton(sender)
        if let itemAction = itemActionDic[sender], let action = itemAction.action {
            NSApp.sendAction(action, to: itemAction.target, from: sender)
        }
        self.drawUndownline(sender)

        tabViewDelegate?.kTabView?(self, didSelect: sender)
    }
    
    @objc func tabviewFrameDidChangeNotification(_ notification: NSNotification) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2) {
            if let selectedButton = self.selectedTabViewItem() {
                self.drawUndownline(selectedButton)
             }
        }
    }
    

}
