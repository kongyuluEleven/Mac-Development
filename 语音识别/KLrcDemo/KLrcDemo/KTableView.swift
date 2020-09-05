//
//  KTableView.swift
//  KLrcDemo
//
//  Created by kongyulu on 2020/9/4.
//  Copyright © 2020 wondershare. All rights reserved.
//

import Cocoa
import Cocoa

let fm_base_bk_color: NSColor               = NSColor.init(rgb: 0x1C232A)
let fm_base_label_color: NSColor            = NSColor.init(rgb: 0xCDD5DD)
let fm_base_highlight_color: NSColor        = NSColor.init(rgb: 0x61DED0)

let fm_default_btn_title_normal: NSColor    = fm_base_bk_color
let fm_default_btn_title_alter: NSColor     = fm_base_bk_color
let fm_common_btn_title_normal: NSColor     = NSColor.init(rgb: 0x61DED0)
let fm_common_btn_title_alter: NSColor      = NSColor.init(rgb: 0x61DED0)

let fm_guide_btn_title_normal: NSColor    = NSColor.white
let fm_guide_btn_title_alter: NSColor     = NSColor.white
let fm_common_guide_btn_title_normal: NSColor     = NSColor.init(rgb: 0x266ef2)
let fm_common_guide_btn_title_alter: NSColor      = NSColor.init(rgb: 0x266ef2)

let fm_resource_browser_background_color: NSColor   = NSColor.init(srgbRed: 28/255.0, green: 35/255.0, blue: 42/255.0, alpha: 1.0)
let fm_resource_outlineView_background_color: NSColor = NSColor.init(srgbRed: 33/255.0, green: 41/255.0, blue: 49/255.0, alpha: 1.0)

/// 对应9.5版本加入的各类型tip的背景色
let fm_common_tip_background_color: NSColor      = NSColor.init(rgb: 0x61778F)



extension NSColor {
    static func colorWithInt(_ value: Int) -> NSColor {
        let blue = CGFloat(value & 0xFF) / 255.0
        let green = CGFloat((value>>8) & 0xFF) / 255.0
        let red = CGFloat((value>>16) & 0xFF) / 255.0
        
        return NSColor.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    /*strVal: 0xAARRGGBB**/
    static func colorWithHexString(_ strVal: String, preString: String = "0x") -> NSColor {
        let strColor = strVal.replacingOccurrences(of: preString, with: "") as NSString
        if strColor.length != 8 {
            return NSColor.black
        }
        
        let alpha = strColor.substring(with: NSMakeRange(0, 2))
        let strRed = strColor.substring(with: NSMakeRange(2, 2))
        let strGreen = strColor.substring(with: NSMakeRange(4, 2))
        let strBlue = strColor.substring(with: NSMakeRange(6, 2))
        
        var a: UInt32 = 0
        var r: UInt32 = 0
        var g: UInt32 = 0
        var b: UInt32 = 0
        Scanner.init(string: alpha).scanHexInt32(&a)
        Scanner.init(string: strRed).scanHexInt32(&r)
        Scanner.init(string: strGreen).scanHexInt32(&g)
        Scanner.init(string: strBlue).scanHexInt32(&b)
        
        return NSColor.init(red: CGFloat(r) / 255.0,
                            green: CGFloat(g) / 255.0,
                            blue: CGFloat(b) / 255.0,
                            alpha: CGFloat(a) / 255.0)
    }
    
    func intValue() -> Int {
        let color = self.usingColorSpace(NSColorSpace.deviceRGB)
        if color == nil {
            return 0
        }
        
        var value: Int = 0
        value |= lround(Double(color!.blueComponent*255.0))
        value |= lround(Double(color!.greenComponent*255.0)) << 8
        value |= lround(Double(color!.redComponent*255.0)) << 16
        
        return value
    }
    
    func argbIntValue() -> Int {//NSColor->NLEColor
        let color = self.usingColorSpace(NSColorSpace.deviceRGB)
        if color == nil {
            return 0
        }
        
        var value: Int = 0
        value |= lround(Double(color!.blueComponent*255.0))
        value |= lround(Double(color!.greenComponent*255.0)) << 8
        value |= lround(Double(color!.redComponent*255.0)) << 16
        value |= lround(Double(color!.alphaComponent*255.0)) << 24
        
        return value
    }
    
    func hexStringValue(preString: String = "0x") -> String {
        var strHex: String = preString
        let color = self.usingColorSpace(NSColorSpace.deviceRGB)
        if color == nil {
            return ""
        }
        
        let red = lround(Double(color!.redComponent*255.0))
        let green = lround(Double(color!.greenComponent*255.0))
        let blue = lround(Double(color!.blueComponent*255.0))
        
        strHex = strHex.appendingFormat("FF%02X%02X%02X", red, green, blue)
        
        return strHex
    }
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    convenience init(argb: Int) {//NLEColor->NSColor
        let a = (argb >> 24) & 0xFF
        let r = (argb >> 16) & 0xFF
        let g = (argb >> 8) & 0xFF
        let b = argb & 0xFF
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: CGFloat(a) / 255.0)
    }
    
    convenience init(rgb: Int, alpha: CGFloat) {
        let r = (rgb >> 16) & 0xFF
        let g = (rgb >> 8) & 0xFF
        let b = rgb & 0xFF
        
        self.init(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: alpha)
    }
}

class FSButton: NSButton {
    public var hoverImg: NSImage?                   = nil
    
    private var _normalImg: NSImage?                = nil
    private var _isMouseEnter: Bool                 = false
    private var _trackRectTag:NSView.TrackingRectTag?    = nil
    
    public var defautlValue: Any?                   = nil
    public var tagString: String?                   = nil
    
    public func configureImage(normal: String, press: String? = nil, hover: String? = nil) {
        image          = NSImage(named: NSImage.Name.init(normal))
        alternateImage = NSImage(named: NSImage.Name.init(press ?? normal))
        hoverImg       = NSImage(named: NSImage.Name.init(hover ?? normal))
        _normalImg     = nil
    }
    
    override public init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.addTrackingRect(frameRect, owner: self, userData: nil, assumeInside: true)
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        _trackRectTag = self.addTrackingRect(self.bounds, owner: self, userData: nil, assumeInside: true)
    }
    
    override func setButtonType(_ type: NSButton.ButtonType) {
        super.setButtonType(type)
    }
    
    override open func updateTrackingAreas() {
        if let tag = _trackRectTag {
            self.removeTrackingRect(tag)
            _trackRectTag = nil
        }
        
        _trackRectTag = self.addTrackingRect(self.bounds, owner: self, userData: nil, assumeInside: true)
        
    }
    
    override open func mouseEntered(with event: NSEvent) {
        if self.hoverImg == nil {
            return super.mouseEntered(with: event)
        }
        
        if !self.isEnabled || self.isHidden {
            return super.mouseEntered(with: event)
        }
        
        _isMouseEnter = true
        if _normalImg == nil {
            _normalImg = self.image
        }
        
        self.image = hoverImg
        self.needsDisplay = true
        
        super.mouseEntered(with: event)
    }
    
    override open func mouseExited(with event: NSEvent) {
        if self.hoverImg == nil {
            return super.mouseExited(with: event)
        }
        if !self.isEnabled || self.isHidden {
            return super.mouseExited(with: event)
        }
        
        _isMouseEnter = false
        if _normalImg != nil {
            self.image = _normalImg;
        }
        self.needsDisplay = true
        
        super.mouseExited(with: event)
    }
}


class IconTextFieldCell: NSTextFieldCell {
    public var iconImage: NSImage?              = nil
    public var isSelected: Bool                 = false
    
    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override init(textCell string: String) {
        super.init(textCell: string)
    }
    
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        var cellF = cellFrame
        cellF.size.height = 17
        cellF.origin.y += (cellFrame.size.height - cellF.size.height)/2
        if self.iconImage == nil {
            super.draw(withExpansionFrame: cellF, in: controlView)
            return
        }
        
        let imgSize = self.iconImage!.size
        var cellRt = cellF
        var imgFrame = cellF
        NSDivideRect(cellFrame, &imgFrame, &cellRt, imgSize.width+3, NSRectEdge.minX)
        if self.drawsBackground {
            self.backgroundColor?.set()
            NSBezierPath.fill(imgFrame)
        }
        imgFrame.origin.x += 3
        imgFrame.size = imgSize
        
        if controlView.isFlipped {
            imgFrame.origin.y += ceil((cellRt.size.height+imgFrame.size.height)/2)
        } else {
            imgFrame.origin.y += ceil((cellRt.size.height-imgFrame.size.height)/2)
        }
        
        iconImage!.draw(at: imgFrame.origin, from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        super.draw(withExpansionFrame: cellRt, in: controlView)
    }
}

class FMIconTextField: NSTextField {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        self.customIconTextFieldCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.customIconTextFieldCell()
    }
    
    func customIconTextFieldCell() {
        let customCell = IconTextFieldCell.init(textCell: "")
        self.cell = customCell
        self.drawsBackground = false
    }
}

class MissFileCellView: NSTableCellView {
    public weak var buttonView: FSButton?           = nil {
        didSet {
            if self.buttonView != nil {
                self.addSubview(self.buttonView!)
            }
        }
    }
    
    public weak var labelView: FMIconTextField?     = nil {
        didSet {
            if self.labelView != nil {
                self.labelView?.autoresizingMask = [NSView.AutoresizingMask.maxXMargin, NSView.AutoresizingMask.minXMargin, NSView.AutoresizingMask.width]
                self.addSubview(self.labelView!)
            }
        }
    }
    
    deinit {
        self.buttonView?.removeFromSuperview()
        self.buttonView = nil
        
        self.labelView?.removeFromSuperview()
        self.labelView = nil
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
}

class FMTableHeadView: NSTableHeaderView {
}

class FMTableHeaderCell: NSTableHeaderCell {
    override func draw(withFrame cellFrame: NSRect, in controlView: NSView) {
        NSColor.init(rgb: 0x67DDCF).set()
        NSBezierPath.fill(cellFrame)
        NSColor.black.set()
        NSBezierPath.fill(NSMakeRect(NSMaxX(cellFrame)-1, NSMinY(cellFrame), 1, NSHeight(cellFrame)))
        if ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 10 && ProcessInfo.processInfo.operatingSystemVersion.minorVersion == 14 {
            super.drawInterior(withFrame: NSInsetRect(cellFrame, 1.0, cellFrame.size.height-20), in: controlView)
        } else if ProcessInfo.processInfo.operatingSystemVersion.majorVersion == 10 && ProcessInfo.processInfo.operatingSystemVersion.minorVersion == 15 {
            super.drawInterior(withFrame: NSInsetRect(cellFrame, 1.0, cellFrame.size.height-20), in: controlView)
        } else {
            super.drawInterior(withFrame: NSInsetRect(cellFrame, 1.0, cellFrame.size.height-17), in: controlView)
        }
    }
    
}

class FMTableView: NSTableView {
    override func drawBackground(inClipRect clipRect: NSRect) {
        let evenColor = NSColor.init(rgb: 0x242B33)
        let oddColor = NSColor.init(rgb: 0x2A313A)
        let rowH = self.rowHeight + self.intercellSpacing.height
        var highlightRt = NSZeroRect
        
        highlightRt.origin = NSMakePoint(clipRect.origin.x, CGFloat(Int(NSMinY(clipRect)/rowHeight))*rowHeight)
        highlightRt.size = NSMakeSize(clipRect.size.width, rowHeight-self.intercellSpacing.height)
        
        while NSMinY(highlightRt) < NSMaxY(clipRect) {
            var clippedHighlightRect = NSIntersectionRect(highlightRt, clipRect)
            clippedHighlightRect.origin.x = clipRect.origin.x
            clippedHighlightRect.size.width = clipRect.size.width
            
            let row = Int((NSMinY(highlightRt)+rowH/2.0)/rowH)
            let color = (0 == row % 2) ? evenColor : oddColor
            color.set()
            NSBezierPath.fill(clippedHighlightRect)
            highlightRt.origin.y += rowH
        }
    }
}

class FMTableRowView : NSTableRowView {
    var bkColor: NSColor?           = nil
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
    }
    
    required init?(coder: NSCoder){
        super.init(coder: coder)
    }
    
    override func drawBackground(in dirtyRect: NSRect) {
        let color = bkColor == nil ? NSColor.init(rgb: 0x29333E) : bkColor
        color?.set()
        NSBezierPath.fill(self.bounds)
    }
    
    override func drawSelection(in dirtyRect: NSRect) {
        NSColor.init(deviceRed: 49/255.0, green: 60/255.0, blue: 71/255.0, alpha: 1.0).set()
        NSBezierPath.fill(self.bounds)
    }
    
//    override func drawDraggingDestinationFeedback(in dirtyRect: NSRect) {
//        NSColor.init(deviceRed: 92/255.0, green: 190/255.0, blue: 199/255.0, alpha: 1.0).set()
//        NSBezierPath.fill(self.bounds)
//    }
    
    override func drawSeparator(in dirtyRect: NSRect) {
    }
}
