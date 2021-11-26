//
//  CustomButton.swift
//  WSStoreKitDemo
//
//  Created by ws on 2020/7/24.
//  Copyright © 2020 ws. All rights reserved.
//

import Cocoa


class CustomButton: NSButton {
    
    var titleColor: NSColor?
    var backgroundColor: NSColor?
    

    override func awakeFromNib() {
        super.awakeFromNib()

        titleColor = NSColor.textColor
        backgroundColor = NSColor.textBackgroundColor

    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let tColor = titleColor, let bColor = backgroundColor else {
            return
        }

        bColor.set()
        NSBezierPath.fill(self.bounds)
        
        // 绘制文字
        let paraStyle = NSMutableParagraphStyle.init()
        paraStyle.setParagraphStyle(NSParagraphStyle.default)
        paraStyle.alignment = .center
        let font = self.font ?? NSFont.systemFont(ofSize: 14)
        let attributedKeys: [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font : font,
                                                              NSAttributedStringKey.foregroundColor : tColor,
                                                              NSAttributedStringKey.paragraphStyle : paraStyle ]
        
        let btnString = NSAttributedString.init(string: self.title, attributes: attributedKeys)
        let y = (self.bounds.size.height - font.pointSize) * 0.5 - (font.xHeight * 0.5)
        let rect = NSRect(x: 0, y: y, width: self.bounds.size.width, height: self.bounds.size.height)
        btnString.draw(in: rect)

    }
    
}



