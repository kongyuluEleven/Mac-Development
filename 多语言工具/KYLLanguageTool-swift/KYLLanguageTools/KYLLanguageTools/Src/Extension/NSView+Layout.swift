//
//  NSView+Layout.swift
//  WSUIKit
//
//  Created by kongyulu on 2020/12/24.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit


// MARK: - Constraints

public extension NSView {
    /// 搜索约束，直到找到给定视图和属性的约束。这将枚举祖先，因为约束总是添加到公共视图。
    ///
    /// - Parameter attribute: 要查找的属性
    /// - Parameter at: 要查找的视图
    /// - Returns: 匹配到的约束
    func findConstraint(attribute: NSLayoutConstraint.Attribute, for view: NSView) -> NSLayoutConstraint? {
        let constraint = constraints.first {
            ($0.firstAttribute == attribute && $0.firstItem as? NSView == view) ||
                ($0.secondAttribute == attribute && $0.secondItem as? NSView == view)
        }
        return constraint ?? superview?.findConstraint(attribute: attribute, for: view)
    }

    /// 视图的第一个宽度约束
    var widthConstraint: NSLayoutConstraint? {
        findConstraint(attribute: .width, for: self)
    }

    /// 这个视图的第一个高度约束
    var heightConstraint: NSLayoutConstraint? {
        findConstraint(attribute: .height, for: self)
    }

    /// 第一个leading 约束
    var leadingConstraint: NSLayoutConstraint? {
        findConstraint(attribute: .leading, for: self)
    }

    /// 第一个 trailing 约束
    var trailingConstraint: NSLayoutConstraint? {
        findConstraint(attribute: .trailing, for: self)
    }

    /// 第一个 top 约束
    var topConstraint: NSLayoutConstraint? {
        findConstraint(attribute: .top, for: self)
    }

    /// 第一个 bottom 约束
    var bottomConstraint: NSLayoutConstraint? {
        findConstraint(attribute: .bottom, for: self)
    }
}

// MARK: - 边框约束
extension NSView {
    
    /// 相对于view窗口，居中约束
    /// - Parameter view: 参考的相对view
    func center(inView view: NSView) {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor),
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    
    /// 相对于View 的 中心点的x 坐标对齐
    /// - Parameter view: 参考的相对view
    func centerX(inView view: NSView) {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    /// 相对于View 的 中心点的 y 坐标对齐
    /// - Parameter view: 参考的相对view
    func centerY(inView view: NSView) {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    
    /// 添加一个视图居中显示
    /// - Parameter view: 需要添加视图
    func addSubviewToCenter(_ view: NSView) {
        addSubview(view)
        view.center(inView: superview!)
    }
    
    
    /// 四个边界都与参考视图等同
    /// - Parameters:
    ///   - view: 参考窗口
    ///   - insets: 边距
    func constrainEdges(to view: NSView, with insets: NSEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: insets.left),
            trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -insets.right),
            topAnchor.constraint(equalTo: view.topAnchor, constant: insets.top),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -insets.bottom)
        ])
    }

    func constrainEdges(to view: NSView, margin: Double = 0) {
        constrainEdges(to: view, with: .init(all: margin))
    }
    
    /// 约束和父窗口等边距
    /// - Parameter insets: 边距
    func constrainEdgesToSuperview(with insets: NSEdgeInsets = .zero) {
        guard let superview = superview else {
            assertionFailure("There is no superview for this view")
            return
        }

        constrainEdges(to: superview, with: insets)
    }

    
    /// 约束视图大小
    /// - Parameter size: 视图大小
    func constrain(to size: CGSize) {
        NSLayoutConstraint.activate([
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height)
        ])
    }
}



public enum DirectionRelate {
    case language
    case closeButton(NSWindow)
    case miniaturizeButton(NSWindow)
    case zoomButton(NSWindow)
}

// MARK: - 父窗口约束
extension NSView {
    @discardableResult
    func constrainToSuperviewBounds() -> [NSLayoutConstraint] {
        guard let superview = superview else {
            preconditionFailure("superview has to be set first")
        }

        var result = [NSLayoutConstraint]()
        result.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        result.append(contentsOf: NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(result)

        return result
    }
}


// MARK: - NSView Layout
public extension NSView {
    
    class func isLayoutFromRightToLeft() -> Bool {
        return NSApplication.shared.userInterfaceLayoutDirection == .rightToLeft
    }
    
    class func isLayoutFromLeftToRight() -> Bool {
        return NSApplication.shared.userInterfaceLayoutDirection == .leftToRight
    }
    
    /// 当前语言的文字方向
    /// - Returns: NSLocale.LanguageDirection
    @objc class var characterDirection: NSLocale.LanguageDirection  {
        let current = NSLocale.current
        guard let code = current.languageCode else { return .leftToRight }
        let direction = NSLocale.characterDirection(forLanguage: code)
        return direction
    }
    
    
    /// 当前线性排布方向
    /// - Returns: NSLocale.LanguageDirection
    @objc class var lineDirection: NSLocale.LanguageDirection {
        let current = NSLocale.current
        guard let code = current.languageCode else { return .leftToRight }
        let direction = NSLocale.lineDirection(forLanguage: code)
        return direction
    }
    
    /// 系统的布局方向：true 右到左，false 左到右
    class func layoutDirectionRightToLeft(relate: DirectionRelate? = DirectionRelate.language)-> Bool {
        switch relate {
        case .language:
            return NSView.characterDirection == .rightToLeft
        case let .closeButton(window):
            return buttonOnRight(window: window, type: .closeButton)
        case let .miniaturizeButton(window):
            return buttonOnRight(window: window, type: .miniaturizeButton)
        case let .zoomButton(window):
            return buttonOnRight(window: window, type: .zoomButton)
        case .none:
            return NSView.characterDirection == .rightToLeft
        }
    }
    
    @objc class func buttonOnRight(window: NSWindow, type: NSWindow.ButtonType) -> Bool {
        let windowWidth = NSWidth(window.frame)
        if  let sysCloseButton = window.standardWindowButton(type) {
            /// 在左边
            if NSMinX(sysCloseButton.frame) < (windowWidth * 0.5) {
                return false
            } else {
                return true
            }
        }
        return NSView.characterDirection == .rightToLeft
    }
    
    /// 在 window bar 上布局视图，会自动根据语言的方向特性进行适配，eg. 阿拉伯语从右到左
    /// - Parameters:
    ///   - window: 基于这个 window 对象上进行布局
    ///   - width: 要布局视图的宽
    ///   - height: 要布局视图的宽
    ///   - baseY: 基础 Y 位置，可以是正数/负数，最终的计算方式与系统的 autolayout 一致
    ///   - offset: 偏移
    ///   - relativelyView: 参考 View 对象，最终在根据这个 view 进行计算其 X 的位置
    ///   - buttonType: 参考 window 上的那个按钮：默认系统的关闭按钮
    /// - Returns: 新的 frame
    /// - Note: 起始 X 坐标都是参考的那个按钮反向计算的，eg. 当前语言是从左到右的，参考按钮在左边角，那此时计算起点则是最右边角+offset往左依次排布(如果有多个按钮时)
    @discardableResult
    @objc func layoutOnWindowBar(_ window: NSWindow,
                           width: CGFloat,
                           height: CGFloat,
                           baseY: CGFloat,
                           offset: CGFloat,
                           relativelyView: NSView? = nil,
                           buttonType: NSWindow.ButtonType = .closeButton) -> NSRect {
                
        /// 为适配阿拉伯语言，以系统关闭按钮为参考点，计算按钮的位置
        let sysCloseButton = window.standardWindowButton(.closeButton)
        let windowWidth = NSWidth(window.frame)
        var offsetX: CGFloat = 0.0

        if let relativelyView = relativelyView {
            if let sysCloseButton = sysCloseButton {
                   /// 在左边
                   if NSMinX(sysCloseButton.frame) < (windowWidth * 0.5) {
                       offsetX = (NSMinX(relativelyView.frame) - width) - offset
                   } else {
                       offsetX = NSMaxX(relativelyView.frame) + offset
                   }
                   
               } else {
                if NSView.layoutDirectionRightToLeft(relate: .language) {
                       if offset > 0 {
                           offsetX = NSMaxX(relativelyView.frame) - offset
                       } else {
                           offsetX = NSMaxX(relativelyView.frame) + offset
                       }
                       
                   } else {
                       if offset > 0 {
                           offsetX = NSMaxX(relativelyView.frame) + offset
                       } else {
                           offsetX = (NSMinX(relativelyView.frame) - width) + offset
                       }
                   }
               }
        } else {
            if let sysCloseButton = sysCloseButton {
                /// 在左边
                if NSMinX(sysCloseButton.frame) < (windowWidth * 0.5) {
                    if offset > 0 {
                        offsetX = (windowWidth - width) - offset
                    } else {
                        offsetX = (windowWidth - width) + offset
                    }
                } else {
                    offsetX = -offset
                }
                
            } else {
                if NSView.layoutDirectionRightToLeft(relate: .language) {
                    offsetX = offset
                    
                } else {
                    offsetX -= offset
                }
            }
        }
        
        let newRect = NSRect(x: offsetX, y: baseY, width: width, height: height)
        frame = newRect
        return newRect
    }
    
    
    /// 在toolbar上布局子视图，计算其X位置，主要用于适配不同意语言，
    /// - Parameters:
    ///   - window: 所在window
    ///   - width: 指定宽
    ///   - baseMinX: 离边缘的最小X，
    ///   - offset: 偏移
    ///   - relatively: 相对视图，默认为系统的关闭按钮，如系统关闭按钮在左时，自动布局到右边的相对位置，反之在左
    /// - Returns: 计算好的X
    @objc class func layoutXOnToolBar(window: NSWindow, width: CGFloat, baseMinX: CGFloat, offset: CGFloat = 0.0, relatively: NSWindow.ButtonType = NSWindow.ButtonType.closeButton) -> CGFloat {
        
        let sysButton = window.standardWindowButton(relatively)
        
        // 为适配阿拉伯语言，以系统关闭按钮为参考点，计算反馈与帮助按钮的位置
        let sysButtonFrame = sysButton?.frame
        guard let safeButtonFrame = sysButtonFrame else {
            return 0.0
        }
        
        let superView = sysButton?.superview
        guard let safeSuperView = superView else {
            return 0.0
        }
        
        let toolBarFrame = safeSuperView.frame
        var offsetX = toolBarFrame.width - safeButtonFrame.maxX - width // X position
        if offsetX < (toolBarFrame.width * 0.5) {
            if offsetX < baseMinX { offsetX = baseMinX }
            offsetX += offset
        } else {
            offsetX -= offset
        }
        
        return offsetX
    }
    
    /// 在 window bar 上布局视图，会自动根据语言的方向特性进行适配，eg. 阿拉伯语从右到左
    /// - Parameters:
    ///   - window: 基于这个 window 对象上进行布局
    ///   - width: 要布局视图的宽
    ///   - height: 要布局视图的宽
    ///   - baseY: 基础 Y 位置，可以是正数/负数，最终的计算方式与系统的 autolayout 一致
    ///   - offset: 偏移
    ///   - relativelyView: 参考 View 对象，最终在根据这个 view 进行计算其 X 的位置
    ///   - buttonType: 参考 window 上的那个按钮：默认系统的关闭按钮
    /// - Returns: 新的 frame
    /// - Note: 起始 X 坐标都是参考的那个按钮反向计算的，eg. 当前语言是从左到右的，参考按钮在左边角，那此时计算起点则是最右边角+offset往左依次排布(如果有多个按钮时)
    @discardableResult
    @objc func layoutOnWindowBar(_ window: NSWindow, width: CGFloat, height: CGFloat, offsetX offset: CGFloat, minY: CGFloat, relativelyView: NSView? = nil, buttonType: NSWindow.ButtonType = .closeButton) -> NSRect {
        
        /// 为适配阿拉伯语言，以系统关闭按钮为参考点，计算按钮的位置
        let sysCloseButton = window.standardWindowButton(.closeButton)
        let windowWidth = NSWidth(window.frame)
        var offsetX: CGFloat = 0.0
        
        if let relativelyView = relativelyView {
            if let sysCloseButton = sysCloseButton {
                /// 在左边
                if NSMinX(sysCloseButton.frame) < (windowWidth * 0.5) {
                    offsetX = (NSMinX(relativelyView.frame) - width) - offset
                } else {
                    offsetX = NSMaxX(relativelyView.frame) + offset
                }
                
            } else {
                if NSView.layoutDirectionRightToLeft() {
                    if offset > 0 {
                        offsetX = NSMaxX(relativelyView.frame) - offset
                    } else {
                        offsetX = NSMaxX(relativelyView.frame) + offset
                    }
                    
                } else {
                    if offset > 0 {
                        offsetX = NSMaxX(relativelyView.frame) + offset
                    } else {
                        offsetX = (NSMinX(relativelyView.frame) - width) + offset
                    }
                }
            }
        } else {
            if let sysCloseButton = sysCloseButton {
                /// 在左边
                if NSMinX(sysCloseButton.frame) < (windowWidth * 0.5) {
                    if offset > 0 {
                        offsetX = (windowWidth - width) - offset
                    } else {
                        offsetX = (windowWidth - width) + offset
                    }
                } else {
                    offsetX = -offset
                }
                
            } else {
                if NSView.layoutDirectionRightToLeft() {
                    offsetX = offset
                    
                } else {
                    offsetX -= offset
                }
            }
        }
        
        let newRect = NSRect(x: offsetX, y: minY, width: width, height: height)
        frame = newRect
        return newRect
    }
    
    /// 在 window bar 上布局视图，会自动根据语言的方向特性进行适配，eg. 阿拉伯语从右到左
    /// - Parameters:
    ///   - window: 基于这个 window 对象上进行布局
    ///   - width: 要布局视图的宽
    ///   - height: 要布局视图的宽
    ///   - baseY: 基础 Y 位置，可以是正数/负数，最终的计算方式与系统的 autolayout 一致
    ///   - offset: 偏移
    ///   - relativelyView: 参考 View 对象，最终在根据这个 view 进行计算其 X 的位置
    ///   - buttonType: 参考 window 上的那个按钮：默认系统的关闭按钮
    /// - Returns: 新的 frame
    /// - Note: 起始 X 坐标都是参考的那个按钮反向计算的，eg. 当前语言是从左到右的，参考按钮在左边角，那此时计算起点则是最右边角+offset往左依次排布(如果有多个按钮时)
    @discardableResult
    @objc func layoutXOnWindowBar(_ window: NSWindow, offsetX offset: CGFloat, minY: CGFloat = CGFloat(MAXFLOAT), relativelyView: NSView? = nil, buttonType: NSWindow.ButtonType = .closeButton) -> NSRect {
        
        let width = NSWidth(frame)
        let height = NSHeight(frame)
        var baseY = minY
        if minY == CGFloat(MAXFLOAT) {
            baseY = NSMinY(frame)
        }
        
        /// 为适配阿拉伯语言，以系统关闭按钮为参考点，计算按钮的位置
        let sysCloseButton = window.standardWindowButton(.closeButton)
        let windowWidth = NSWidth(window.frame)
        var offsetX: CGFloat = 0.0
        
        if let relativelyView = relativelyView {
            if let sysCloseButton = sysCloseButton {
                /// 在左边
                if NSMinX(sysCloseButton.frame) < (windowWidth * 0.5) {
                    offsetX = (NSMinX(relativelyView.frame) - width) - offset
                } else {
                    offsetX = NSMaxX(relativelyView.frame) + offset
                }
                
            } else {
                if NSView.layoutDirectionRightToLeft() {
                    if offset > 0 {
                        offsetX = NSMaxX(relativelyView.frame) - offset
                    } else {
                        offsetX = NSMaxX(relativelyView.frame) + offset
                    }
                    
                } else {
                    if offset > 0 {
                        offsetX = NSMaxX(relativelyView.frame) + offset
                    } else {
                        offsetX = (NSMinX(relativelyView.frame) - width) + offset
                    }
                }
            }
        } else {
            if let sysCloseButton = sysCloseButton {
                /// 在左边
                if NSMinX(sysCloseButton.frame) < (windowWidth * 0.5) {
                    if offset > 0 {
                        offsetX = (windowWidth - width) - offset
                    } else {
                        offsetX = (windowWidth - width) + offset
                    }
                } else {
                    offsetX = -offset
                }
                
            } else {
                if NSView.layoutDirectionRightToLeft() {
                    offsetX = offset
                    
                } else {
                    offsetX -= offset
                }
            }
        }
        
        let newRect = NSRect(x: offsetX, y: baseY, width: width, height: height)
        frame = newRect
        return newRect
    }
}


// MARK: - NSView AutoLayout
public extension NSView {
    fileprivate static var kUpdateConstraint = "needsLayoutWhenHidden"
    fileprivate static var kOriginaConstant = "originaConstant"
    
    /// 约束依赖的 View 隐藏后，自动往前补位
    @IBInspectable var needsLayoutWhenHidden: Bool {
        set {
            objc_setAssociatedObject(self, &NSView.kUpdateConstraint, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
        get {
            let isNeed = objc_getAssociatedObject(self, &NSView.kUpdateConstraint)
            if let isNeed = isNeed as? Bool {
                return isNeed
            }
            return false
        }
    }
    
    private var originaConstants: [String: CGFloat] {
        set {
            objc_setAssociatedObject(self, &NSView.kOriginaConstant, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        get {
            let value = objc_getAssociatedObject(self, &NSView.kOriginaConstant)
            if let value = value as? [String: CGFloat] {
                return value
            }
            return [String: CGFloat]()
        }
    }
    
    @objc class func initializeMethod() -> Bool {
        
        if self != NSView.self { return false }
        
        DispatchQueue.once(token: "NSView.initializeMethod", block: {
            let originalSelector = #selector(setter: NSView.isHidden)
            let swizzledSelector = #selector(NSView.swizzled_isHidden(_:))
            
            let originalMethod = class_getInstanceMethod(self, originalSelector)
            let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
            
            let didAddMethod: Bool = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod!), method_getTypeEncoding(swizzledMethod!))
            if didAddMethod {
                class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod!), method_getTypeEncoding(originalMethod!))
            } else {
                method_exchangeImplementations(originalMethod!, swizzledMethod!)
            }
        }) 
        return true
    }
    
    @objc private func swizzled_isHidden(_ isHidden: Bool) {
        swizzled_isHidden(isHidden)
        if needsLayoutWhenHidden {
            if isHidden {
                var existConstant = false
                if let super_view = self.superview {
                    for item in super_view.constraints {
                        let name = String(item.firstAttribute.rawValue)
                        let firstItem = item.firstItem
                        if let firstItem = firstItem as? NSView, firstItem == self {
                            if item.isMember(of: NSLayoutConstraint.self) {
                                if item.firstAttribute == .trailing {
                                    item.identifier = getConstantIdentifier(attribute: item.firstAttribute)
                                    originaConstants[description + name] = item.constant
                                    item.constant = 0
                                } else if item.firstAttribute == .leading {
                                    item.identifier = getConstantIdentifier(attribute: item.firstAttribute)
                                    originaConstants[description + name] = item.constant
                                    item.constant = 0
                                }
                            }
                        }
                    }
                }
                
                let orgWConstants = constraints.filter( {$0.firstAttribute == .width} )
                if orgWConstants.count > 0 {
                    for item in orgWConstants {
                        let firstItem2 = item.firstItem
                        if let firstItem2 = firstItem2 as? NSView, firstItem2 == self {
                            /// 只有当前约束是`NSLayoutConstraint`类的时候才是正确的，还有`NSContentSizeLayoutConstraint`也会进入这个条件
                            if item.isMember(of: NSLayoutConstraint.self) {
                                existConstant = true
                                item.identifier = getConstantIdentifier(attribute: item.firstAttribute)
                                originaConstants[description + String(item.firstAttribute.rawValue)] = item.constant
                                if item.relation != .equal {
                                    item.priority = .defaultLow
                                    addAssistantWidthConstraint()
                                } else {
                                    item.constant = 0
                                }
                            }
                        }
                    }
                }
                
                if existConstant == false {
                    addAssistantWidthConstraint()
                }
                
            } else {
                /// 需要优先找到额外添加的约束，否则会报⚠️
                let widths = constraints.filter({$0.identifier == getConstantIdentifier(isNew: true, attribute: .width)})
                if widths.count > 0, let width = widths.first {
                    removeConstraint(width)
                }
                
                for item in constraints {
                    if item.identifier == getConstantIdentifier(attribute: .width) {
                        item.priority = .required
                        if let constant = originaConstants[description + String(item.firstAttribute.rawValue)] {
                            item.constant = constant
                            break
                        }
                    }
                }
                if let super_view = self.superview {
                    for item in super_view.constraints {
                        if item.identifier == getConstantIdentifier(attribute: .leading) {
                            if let constant = originaConstants[description + String(item.firstAttribute.rawValue)] {
                                item.constant = constant
                            }
                        } else if item.identifier == getConstantIdentifier(attribute: .trailing) {
                            if let constant = originaConstants[description + String(item.firstAttribute.rawValue)] {
                                item.constant = constant
                            }
                        }
                    }
                }
            }
        }
    }
    
    /// 添加辅助宽的临时约束
    private func addAssistantWidthConstraint() {
        let width = NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1.0, constant: 0)
        width.identifier = getConstantIdentifier(isNew: true, attribute: .width)
        addConstraint(width)
    }
    
    /// 获取约束的标识
    /// - Parameters:
    ///   - isNew: 是否新添加的约束
    ///   - attribute: attribute description
    /// - Returns: 约束标识
    private func getConstantIdentifier(isNew: Bool = false, attribute: NSLayoutConstraint.Attribute) -> String {
        if isNew {
            return "ws_add_" + String(attribute.hashValue) + "_" + String(attribute.rawValue)
        }
        return "ws_org_" + String(attribute.hashValue) + "_" + String(attribute.rawValue)
    }
}


// MARK: - NSControl Layout
@objc public extension NSControl {
    /// 自动适配国际语言的书写、布局、对齐方向
    @IBInspectable var autoLayoutDirection: Bool {
        set {
            autoLayoutDirectionWhenInternationalizing()
        }
        get {
            if NSView.layoutDirectionRightToLeft() {
                return userInterfaceLayoutDirection == .rightToLeft
            } else {
                return userInterfaceLayoutDirection == .leftToRight
            }
        }
    }
    
    /// 自动反向文字对刘齐：左到右的语言为右对齐，右到左的语言为左对齐
    @IBInspectable var reverseTextAlignment: Bool {
        set {
            autoReverseTextAlignment()
        }
        get {
            if NSView.layoutDirectionRightToLeft() {
                return alignment == .left
            } else {
                return alignment == .right
            }
        }
    }
    
    func autoLayoutDirectionWhenInternationalizing() {
        /// mirrorLayoutDirectionWhenInternationalizing
        if NSView.layoutDirectionRightToLeft() {
            alignment = .right
            userInterfaceLayoutDirection = .rightToLeft
            baseWritingDirection = .rightToLeft
        } else {
            alignment = .natural
            baseWritingDirection = .leftToRight
            userInterfaceLayoutDirection = .leftToRight
        }
    }
    
    /// 自动反向文字对刘齐：左到右的语言为右对齐，右到左的语言为左对齐
    func autoReverseTextAlignment() {
        /// mirrorLayoutDirectionWhenInternationalizing
        if NSView.layoutDirectionRightToLeft() {
            alignment = .left
        } else {
            alignment = .right
        }
    }
}


// MARK: - NSCollectionViewItem Layout
@objc public extension NSCollectionViewItem {
   class func identifier() -> NSUserInterfaceItemIdentifier {
        return NSUserInterfaceItemIdentifier(getClassName())
    }
}


// MARK: - NSCell Layout
public extension NSCell {
    /// 自动适配国际语言的书写、布局、对齐方向
    func autoLayoutDirectionWhenInternationalizing() {
        /// mirrorLayoutDirectionWhenInternationalizing
        if NSView.layoutDirectionRightToLeft() {
            if alignment != .center {
                alignment = .right
            }
            userInterfaceLayoutDirection = .rightToLeft
            baseWritingDirection = .rightToLeft
        } else {
            if alignment != .center {
                alignment = .natural
            }
            baseWritingDirection = .leftToRight
            userInterfaceLayoutDirection = .leftToRight
        }
    }
}

// MARK: - NSTextAlignment Layout
public extension NSTextAlignment {
    static var autoByLanguage: NSTextAlignment {
        get {
            if NSView.layoutDirectionRightToLeft() {
                return .right
            }
            return .left
        }
    }
}


// MARK: - NSUserInterfaceLayoutDirection Layout
public extension NSUserInterfaceLayoutDirection {
    static var autoByLanguage: NSUserInterfaceLayoutDirection {
        get {
            if NSView.layoutDirectionRightToLeft() {
                return .rightToLeft
            }
            return .leftToRight
        }
    }
}


// MARK: - NSWritingDirection Layout
public extension NSWritingDirection {
    static var autoByLanguage: NSWritingDirection {
        get {
            if NSView.layoutDirectionRightToLeft() {
                return .rightToLeft
            }
            return .leftToRight
        }
    }
}


#endif
