//
//  DrawingSegmentationView.swift
//  SemanticSegmentation-CoreML
//
//  Created by Doyoung Gwak on 20/07/2019.
//  Copyright © 2019 Doyoung Gwak. All rights reserved.
//

import Cocoa

class DrawingSegmentationView: NSView {
    
    static private var colors: [Int32: NSColor] = [:]
    
    func segmentationColor(with index: Int32) -> NSColor {
        if let color = DrawingSegmentationView.colors[index] {
            return color
        } else {
            let color = NSColor(hue: CGFloat(index) / CGFloat(30), saturation: 1, brightness: 1, alpha: 0.5)
            print(index)
            DrawingSegmentationView.colors[index] = color
            return color
        }
    }
    
    var segmentationmap: SegmentationResultMLMultiArray? = nil {
        didSet {
            self.needsDisplay = true
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        if let ctx = NSGraphicsContext.current?.cgContext {
            
            ctx.clear(rect);
            
            guard let segmentationmap = self.segmentationmap else { return }
            
            let size = self.bounds.size
            let segmentationmapWidthSize = segmentationmap.segmentationmapWidthSize
            let segmentationmapHeightSize = segmentationmap.segmentationmapHeightSize
            let w = size.width / CGFloat(segmentationmapWidthSize)
            let h = size.height / CGFloat(segmentationmapHeightSize)
            
            for j in 0..<segmentationmapHeightSize {
                //let i = 0
                for i in 0..<segmentationmapWidthSize {
                    let value = segmentationmap[j, i].int32Value

                    let rect: CGRect = CGRect(x: CGFloat(i) * w, y: CGFloat(j) * h, width: w, height: h)

                    let color: NSColor = segmentationColor(with: value)

                    color.setFill()
                    NSBezierPath(rect: rect).fill()
                }
            }
        }
    } // end of draw(rect:)

}
