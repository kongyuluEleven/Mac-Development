//
//  NSImage+draw.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - 绘制图片
public extension NSImage {
    
    class func drawInHorizial(_ image: NSImage, orignDrawRect: NSRect, visibleRect: NSRect, fraction: CGFloat = 1.0, insets: NSEdgeInsets? = nil) {
        let imgSize = image.size
        let drawSize = orignDrawRect.size
        let imgLeft = Int((imgSize.width-1)/2)
        
        var imgInsets = NSEdgeInsets.init(top: 0,
                                        left: CGFloat(imgLeft),
                                        bottom: imgSize.height,
                                        right: imgSize.width-CGFloat(imgLeft))
        if insets != nil {
            imgInsets = insets!
        }
        
        let drawInsets = NSEdgeInsets.init(top: 0,
                                         left: imgInsets.left,
                                         bottom: drawSize.height,
                                         right: drawSize.width-imgInsets.left)
        
        if drawInsets.left*2 >= orignDrawRect.width {
            image.draw(in: orignDrawRect)
            return
        }
        
        var imgRt: NSRect = NSZeroRect
        var drawRt: NSRect = NSZeroRect
        
        //左
        imgRt.origin = NSMakePoint(0, 0)
        imgRt.size = NSMakeSize(imgInsets.left, imgSize.height)
        drawRt.origin = orignDrawRect.origin
        drawRt.size = NSMakeSize(drawInsets.left, drawSize.height)
        image.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
        
        //中
        imgRt.origin = NSMakePoint(imgInsets.left, 0)
        imgRt.size = NSMakeSize(imgInsets.right-imgInsets.left, imgSize.height)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x+drawInsets.left, orignDrawRect.origin.y)
        drawRt.size = NSMakeSize(drawInsets.right-drawInsets.left, drawSize.height)
        image.draw(in: NSIntersectionRect(drawRt, visibleRect), from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
        
        //右
        imgRt.origin = NSMakePoint(imgInsets.right, 0)
        imgRt.size = NSMakeSize(imgSize.width-imgInsets.right, imgSize.height)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x+drawInsets.right, orignDrawRect.origin.y)
        drawRt.size = NSMakeSize(drawSize.width-drawInsets.right, drawSize.height)
        image.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
    }

    class func drawInHorizialFlipped(_ image: NSImage, orignDrawRect: NSRect, visibleRect: NSRect, fraction: CGFloat = 1.0, insets: NSEdgeInsets? = nil) {
        let imgSize = image.size
        let drawSize = orignDrawRect.size
        let imgLeft = Int((imgSize.width-1)/2)
        
        var imgInsets = NSEdgeInsets.init(top: 0,
                                        left: CGFloat(imgLeft),
                                        bottom: imgSize.height,
                                        right: imgSize.width-CGFloat(imgLeft))
        if insets != nil {
            imgInsets = insets!
        }
        
        let drawInsets = NSEdgeInsets.init(top: 0,
                                         left: imgInsets.left,
                                         bottom: drawSize.height,
                                         right: drawSize.width-imgInsets.left)
        
        if drawInsets.left*2 >= orignDrawRect.width {
            image.draw(in: orignDrawRect)
            return
        }
        
        var imgRt: NSRect = NSZeroRect
        var drawRt: NSRect = NSZeroRect
        
        //左
        imgRt.origin = NSMakePoint(0, 0)
        imgRt.size = NSMakeSize(imgInsets.left, imgSize.height)
        drawRt.origin = orignDrawRect.origin
        drawRt.size = NSMakeSize(drawInsets.left, drawSize.height)
        image.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction, respectFlipped: true, hints: nil)
        
        //中
        imgRt.origin = NSMakePoint(imgInsets.left, 0)
        imgRt.size = NSMakeSize(imgInsets.right-imgInsets.left, imgSize.height)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x+drawInsets.left, orignDrawRect.origin.y)
        drawRt.size = NSMakeSize(drawInsets.right-drawInsets.left, drawSize.height)
        
        image.draw(in: NSIntersectionRect(drawRt, visibleRect), from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction, respectFlipped: true, hints: nil)
        //右
        imgRt.origin = NSMakePoint(imgInsets.right, 0)
        imgRt.size = NSMakeSize(imgSize.width-imgInsets.right, imgSize.height)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x+drawInsets.right, orignDrawRect.origin.y)
        drawRt.size = NSMakeSize(drawSize.width-drawInsets.right, drawSize.height)
        image.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction, respectFlipped: true, hints: nil)
    }

    class func drawInVertical(_ image: NSImage, orignDrawRect: NSRect, visibleRect: NSRect, fraction: CGFloat = 1.0, insets: NSEdgeInsets? = nil) {
        let imgSize = image.size
        let drawSize = orignDrawRect.size
        let imgTop = Int((imgSize.height-1)/2)
        
        var imgInsets = NSEdgeInsets.init(top: CGFloat(imgTop),
                                        left: 0,
                                        bottom: imgSize.height-CGFloat(imgTop),
                                        right: imgSize.width)
        if insets != nil {
            imgInsets = insets!
        }
        
        let drawInsets = NSEdgeInsets.init(top: imgInsets.top,
                                         left: 0,
                                         bottom: drawSize.height-imgInsets.top,
                                         right: drawSize.width)
        
        if drawInsets.top*2 >= orignDrawRect.height {
            image.draw(in: orignDrawRect)
            return
        }
        
        var imgRt: NSRect = NSZeroRect
        var drawRt: NSRect = NSZeroRect
        
        //下
        imgRt.origin = NSMakePoint(0, 0)
        imgRt.size = NSMakeSize(imgSize.width, imgSize.height-imgInsets.bottom)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x, orignDrawRect.origin.y)
        drawRt.size = NSMakeSize(drawSize.width, drawSize.height-drawInsets.bottom)
        image.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
        
        //中
        imgRt.origin = NSMakePoint(0, imgSize.height-imgInsets.bottom)
        imgRt.size = NSMakeSize(imgSize.width, imgInsets.bottom-imgInsets.top)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x, orignDrawRect.origin.y+orignDrawRect.size.height-drawInsets.bottom)
        drawRt.size = NSMakeSize(drawSize.width, drawInsets.bottom-drawInsets.top)
        image.draw(in: NSIntersectionRect(drawRt, visibleRect), from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
        
        //上
        imgRt.origin = NSMakePoint(0, imgSize.height-imgInsets.top)
        imgRt.size = NSMakeSize(imgSize.width, imgInsets.top)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x, orignDrawRect.origin.y+orignDrawRect.size.height-drawInsets.top)
        drawRt.size = NSMakeSize(drawSize.width, drawInsets.top)
        image.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
    }

    class func drawIn9Part(_ image: NSImage, orignDrawRect: NSRect, visibleRect: NSRect, fraction: CGFloat = 1.0, insets: NSEdgeInsets? = nil) {
        let imgSize = image.size
        let drawSize = orignDrawRect.size
        let imgTop = Int((imgSize.height-1)/2)
        let imgLeft = Int((imgSize.width-1)/2)
        
        var imgInsets = NSEdgeInsets.init(top: CGFloat(imgTop),
                                        left: CGFloat(imgLeft),
                                        bottom: imgSize.height-CGFloat(imgTop),
                                        right: imgSize.width-CGFloat(imgLeft))
        if insets != nil {
            imgInsets = insets!
        }
        
        let drawInsets = NSEdgeInsets.init(top: imgInsets.top,
                                         left: imgInsets.left,
                                         bottom: drawSize.height-imgInsets.top,
                                         right: drawSize.width-imgInsets.left)
        
        if drawInsets.top*2 >= orignDrawRect.height {
            drawInHorizial(image, orignDrawRect: orignDrawRect, visibleRect: visibleRect, fraction: fraction, insets: insets)
            return
        }
        if drawInsets.left*2 >= orignDrawRect.width {
            drawInVertical(image, orignDrawRect: orignDrawRect, visibleRect: visibleRect, fraction: fraction, insets: insets)
            return
        }
        
        var imgRt: NSRect = NSZeroRect
        var drawRt: NSRect = NSZeroRect
        
        
        //顺序：由下到上，由左到右
        // 6 7 8
        // 3 4 5
        // 0 1 2
        
        //----------------下-----------------
        //左
        imgRt.origin = NSMakePoint(0, 0)
        imgRt.size = NSMakeSize(imgInsets.left, imgSize.height-imgInsets.bottom)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x, orignDrawRect.origin.y)
        drawRt.size = NSMakeSize(drawInsets.left, drawSize.height-drawInsets.bottom)
        image.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
        
        //中
        imgRt.origin = NSMakePoint(imgInsets.left, 0)
        imgRt.size = NSMakeSize(imgInsets.right-imgInsets.left, imgSize.height-imgInsets.bottom)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x+drawInsets.left, orignDrawRect.origin.y)
        drawRt.size = NSMakeSize(drawInsets.right-drawInsets.left, drawSize.height-drawInsets.bottom)
        image.draw(in: NSIntersectionRect(drawRt, visibleRect), from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
        
        //右
        imgRt.origin = NSMakePoint(imgInsets.right, 0)
        imgRt.size = NSMakeSize(imgSize.width-imgInsets.right, imgSize.height-imgInsets.bottom)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x+drawInsets.right, orignDrawRect.origin.y)
        drawRt.size = NSMakeSize(drawSize.width-drawInsets.right, drawSize.height-drawInsets.bottom)
        image.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
        
        //----------------中--------------------
        //左
        imgRt.origin = NSMakePoint(0, imgSize.height-imgInsets.bottom)
        imgRt.size = NSMakeSize(imgInsets.left, imgInsets.bottom-imgInsets.top)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x, orignDrawRect.origin.y+drawSize.height-drawInsets.bottom)
        drawRt.size = NSMakeSize(drawInsets.left, drawInsets.bottom-drawInsets.top)
        image.draw(in: NSIntersectionRect(drawRt, visibleRect), from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
        
        //中
        imgRt.origin = NSMakePoint(imgInsets.left, imgSize.height-imgInsets.bottom)
        imgRt.size = NSMakeSize(imgInsets.right-imgInsets.left, imgInsets.bottom-imgInsets.top)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x+drawInsets.left, orignDrawRect.origin.y+drawSize.height-drawInsets.bottom)
        drawRt.size = NSMakeSize(drawInsets.right-drawInsets.left, drawInsets.bottom-drawInsets.top)
        image.draw(in: NSIntersectionRect(drawRt, visibleRect), from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
        
        //右
        imgRt.origin = NSMakePoint(imgInsets.right, imgSize.height-imgInsets.bottom)
        imgRt.size = NSMakeSize(imgSize.width-imgInsets.right, imgInsets.bottom-imgInsets.top)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x+drawInsets.right, orignDrawRect.origin.y+drawSize.height-drawInsets.bottom)
        drawRt.size = NSMakeSize(drawSize.width-drawInsets.right, drawInsets.bottom-drawInsets.top)
        image.draw(in: NSIntersectionRect(drawRt, visibleRect), from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
        
        //----------------上---------------------
        //左
        imgRt.origin = NSMakePoint(0, imgSize.height-imgInsets.top)
        imgRt.size = NSMakeSize(imgInsets.left, imgInsets.top)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x, orignDrawRect.origin.y+drawSize.height-drawInsets.top)
        drawRt.size = NSMakeSize(drawInsets.left, drawInsets.top)
        image.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
        
        //中
        imgRt.origin = NSMakePoint(imgInsets.left, imgSize.height-imgInsets.top)
        imgRt.size = NSMakeSize(imgInsets.right-imgInsets.left, imgInsets.top)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x+drawInsets.left, orignDrawRect.origin.y+drawSize.height-drawInsets.top)
        drawRt.size = NSMakeSize(drawInsets.right-drawInsets.left, drawInsets.top)
        image.draw(in: NSIntersectionRect(drawRt, visibleRect), from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
        
        //右
        imgRt.origin = NSMakePoint(imgInsets.right, imgSize.height-imgInsets.top)
        imgRt.size = NSMakeSize(imgSize.width-imgInsets.right, imgInsets.top)
        drawRt.origin = NSMakePoint(orignDrawRect.origin.x+drawInsets.right, orignDrawRect.origin.y+drawSize.height-drawInsets.top)
        drawRt.size = NSMakeSize(drawSize.width-drawInsets.right, drawInsets.top)
        image.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: fraction)
    }

}


extension NSImage {
    /*!
     @method draw9Part(in visibleRect: ofViewBounds：withImage:）
     @abstract
     @discussion
     @params visibleRect 可见区域Rect，它是ViewBound中的小部分，也是需要绘制的部分
     @params viewBounds 整个View大小
     @params image 用于绘制的图片
     */
    class func draw9Part(in visibleRect: NSRect , ofViewBounds viewBounds: NSRect , withImage image: NSImage)
    {
        let imgSize: NSSize = image.size
        
        if viewBounds.size.width <= imgSize.width || viewBounds.size.height <= imgSize.height{
            image.draw(in: viewBounds, from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            return
        }
        
        //九宫格编号：
        //6  7  8
        //3  4  5
        //0  1  2
        
        var arrImageRt: [NSRect] =  [NSRect]()
        let midWidth: Int = 1
        var rt0: NSRect = NSZeroRect
        rt0.size.width = CGFloat((Int(imgSize.width) - midWidth)/2)
        rt0.size.height = CGFloat((Int(imgSize.height) - midWidth)/2)
        arrImageRt.append(rt0)
        
        var rt1: NSRect = NSZeroRect
        rt1.origin.x = rt0.origin.x + rt0.size.width
        rt1.origin.y = rt0.origin.y
        rt1.size.width = 1
        rt1.size.height = rt0.size.height
        arrImageRt.append(rt1)
        
        var rt2: NSRect = NSZeroRect
        rt2.origin.x = rt1.origin.x + rt1.size.width
        rt2.size.width = imgSize.width - rt0.size.width - rt1.size.width
        rt2.origin.y = rt1.origin.y
        rt2.size.height = rt1.size.height
        arrImageRt.append(rt2)
        
        var rt3: NSRect = NSZeroRect
        rt3.origin.x = rt0.origin.x
        rt3.origin.y = rt0.origin.y + rt0.size.height
        rt3.size.width = rt0.size.width
        rt3.size.height = CGFloat(midWidth)
        arrImageRt.append(rt3)
        
        var rt4: NSRect = NSZeroRect
        rt4.origin.x = rt3.origin.x + rt3.size.width
        rt4.origin.y = rt3.origin.y
        rt4.size.width = CGFloat(midWidth)
        rt4.size.height = CGFloat(midWidth)
        arrImageRt.append(rt4)
        
        var rt5: NSRect = NSZeroRect
        rt5.origin.x = rt4.origin.x + rt4.size.width
        rt5.origin.y = rt4.origin.y
        rt5.size.width = imgSize.width - rt3.size.width - rt4.size.width
        rt5.size.height = CGFloat(midWidth)
        arrImageRt.append(rt5)
        
        var rt6: NSRect = NSZeroRect
        rt6.origin.x = rt3.origin.x
        rt6.origin.y = rt3.origin.y + rt3.size.height
        rt6.size.width = rt3.size.width
        rt6.size.height = imgSize.height - rt3.size.height - rt0.size.height
        arrImageRt.append(rt6)
        
        var rt7: NSRect = NSZeroRect
        rt7.origin.x = rt6.origin.x + rt6.size.width
        rt7.origin.y = rt6.origin.y
        rt7.size.width = CGFloat(midWidth)
        rt7.size.height = rt6.size.height
        arrImageRt.append(rt7)
        
        var rt8: NSRect = NSZeroRect
        rt8.origin.x = rt7.origin.x + rt7.size.width
        rt8.origin.y = rt7.origin.y
        rt8.size.width = imgSize.width - rt6.size.width - rt7.size.width
        rt8.size.height = rt7.size.height
        arrImageRt.append(rt8)
        
        //draw rect array
        var arrDrawRt: [NSRect] = [NSRect]()
        var drawRt0: NSRect = rt0
        drawRt0.origin = viewBounds.origin
        arrDrawRt.append(drawRt0)
        
        var drawRt1: NSRect = rt1
        drawRt1.origin.x = drawRt1.origin.x + drawRt1.size.width
       // drawRt1.origin.y = drawRt1.origin.y
        drawRt1.size.width = viewBounds.size.width - rt0.size.width - rt2.size.width
        arrDrawRt.append(drawRt1)
        
        var drawRt2: NSRect = rt2
        drawRt2.origin.x = drawRt1.origin.x + drawRt1.size.width
        drawRt2.origin.y = drawRt1.origin.y
        arrDrawRt.append(drawRt2)
        
        var drawRt3: NSRect = NSZeroRect
        drawRt3.origin.x = drawRt0.origin.x
        drawRt3.origin.y = drawRt0.origin.y + drawRt0.size.height
        drawRt3.size.width = drawRt0.size.width
        drawRt3.size.height = viewBounds.size.height - rt0.size.height - rt6.size.height
        arrDrawRt.append(drawRt3)
        
        var drawRt4: NSRect = NSZeroRect
        drawRt4.origin.x = drawRt3.origin.x + drawRt3.size.width
        drawRt4.origin.y = drawRt3.origin.y
        drawRt4.size.width = viewBounds.size.width - rt3.size.width - rt5.size.width
        drawRt4.size.height = drawRt3.size.height
        arrDrawRt.append(drawRt4)
        
        var drawRt5: NSRect = NSZeroRect
        drawRt5.origin.x = drawRt4.origin.x + drawRt4.size.width
        drawRt5.origin.y = drawRt4.origin.y
        drawRt5.size.width = rt5.size.width
        drawRt5.size.height = viewBounds.size.height - rt2.size.height - rt8.size.height
        arrDrawRt.append(drawRt5)
        
        var drawR6: NSRect = NSZeroRect
        drawR6.origin.x = drawRt3.origin.x
        drawR6.origin.y = drawRt3.origin.y + drawRt3.size.height
        drawR6.size.width = drawRt3.size.width
        drawR6.size.height = rt6.size.height
        arrDrawRt.append(drawR6)
        
        var drawRt7: NSRect = NSZeroRect
        drawRt7.origin.x = drawR6.origin.x + drawR6.size.width
        drawRt7.origin.y = drawR6.origin.y
        drawRt7.size.width = viewBounds.size.width - rt6.size.width - rt8.size.width
        drawRt7.size.height = drawR6.size.height
        arrDrawRt.append(drawRt7)
        
        var drawRt8: NSRect = NSZeroRect
        drawRt8.origin.x = drawRt7.origin.x + drawRt7.size.width
        drawRt8.origin.y = drawRt7.origin.y
        drawRt8.size.width = rt8.size.width
        drawRt8.size.height = drawRt7.size.height
        arrDrawRt.append(drawRt8)
        
        for index in 0...8 {
            if index%2 == 0 {
                if index == 4 {
                    let needDrawRt : NSRect = NSIntersectionRect(visibleRect, arrDrawRt[index])
                    if !NSEqualRects(needDrawRt, NSZeroRect) {
                        image.draw(in: needDrawRt, from: arrImageRt[index], operation: NSCompositingOperation.sourceOver, fraction: 1.0)
                    }
                }
                else {
                    image.draw(in: arrDrawRt[index], from: arrImageRt[index], operation: NSCompositingOperation.sourceOver, fraction: 1.0)
                }
                
            }
            else {
                var needDrawRt : NSRect = arrDrawRt[index]
                if index == 1 || index == 7 {
                    needDrawRt.origin.x = max(visibleRect.origin.x, arrDrawRt[index].origin.x)
                    needDrawRt.size.width = min(visibleRect.origin.x+visibleRect.size.width-needDrawRt.origin.x, arrDrawRt[index].origin.x + arrDrawRt[index].size.width - needDrawRt.origin.x)
                    
                    image.draw(in: needDrawRt, from: arrImageRt[index], operation: NSCompositingOperation.sourceOver, fraction: 1.0)
                }
                else {
                    needDrawRt.origin.y = max(visibleRect.origin.y, arrDrawRt[index].origin.y)
                    needDrawRt.size.height = min(visibleRect.origin.y+visibleRect.size.height-needDrawRt.origin.y, arrDrawRt[index].origin.y + arrDrawRt[index].size.height - needDrawRt.origin.y)
                    
                    image.draw(in: needDrawRt, from: arrImageRt[index], operation: NSCompositingOperation.sourceOver, fraction: 1.0)
                }
            }
        }
    }

    /*!
     @method draw3Part(in visibleRect: ofViewBounds：withImage: isHorizial:）
     @abstract
     @discussion
     @params visibleRect 可见区域Rect，它是ViewBound中的小部分，也是需要绘制的部分
     @params viewBounds 整个View大小
     @params image 用于绘制的图片
     @params horizial 是否在垂直方向上绘制可见区域
     */
    class func draw3Part(in visibleRect: NSRect , ofViewBounds viewBounds: NSRect , withImage image: NSImage, isHorizial horizial: Bool)
    {
        let imgSize: NSSize = image.size
        var arrImageRt: [NSRect] =  [NSRect]()
        var arrDrawRt: [NSRect] = [NSRect]()
        
        if horizial {
            if viewBounds.size.width <= imgSize.width {
                image.draw(in: viewBounds, from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
                return
            }
            
            
            let midWidth: Int = 1
            
            var rt0: NSRect = NSZeroRect
            rt0.size.width = CGFloat((Int(imgSize.width) - midWidth)/2)
            rt0.size.height = imgSize.height
            arrImageRt.append(rt0)
            
            var rt1: NSRect = NSZeroRect
            rt1.origin.x = rt0.origin.x + rt0.size.width
            rt1.origin.y = rt0.origin.y
            rt1.size.width = 1
            rt1.size.height = rt0.size.height
            arrImageRt.append(rt1)
            
            var rt2: NSRect = NSZeroRect
            rt2.origin.x = rt1.origin.x + rt1.size.width
            rt2.size.width = imgSize.width - rt0.size.width - rt1.size.width
            rt2.origin.y = rt1.origin.y
            rt2.size.height = rt1.size.height
            arrImageRt.append(rt2)
            
            //draw rect array
            var drawRt0: NSRect = rt0
            drawRt0.origin = viewBounds.origin
            arrDrawRt.append(drawRt0)
            
            var drawRt1: NSRect = rt1
            drawRt1.origin.x = drawRt1.origin.x + drawRt1.size.width
            //drawRt1.origin.y = drawRt1.origin.y
            drawRt1.size.width = viewBounds.size.width - rt0.size.width - rt2.size.width
            arrDrawRt.append(drawRt1)
            
            var drawRt2: NSRect = rt2
            drawRt2.origin.x = drawRt1.origin.x + drawRt1.size.width
            drawRt2.origin.y = drawRt1.origin.y
            arrDrawRt.append(drawRt2)
        }
        else {
            if viewBounds.size.height <= imgSize.height {
                image.draw(in: viewBounds, from: NSZeroRect, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
                return
            }
            
            let midWidth: Int = 1
            var rt0: NSRect = NSZeroRect
            rt0.size.width = imgSize.width
            rt0.size.height = CGFloat((Int(imgSize.height) - midWidth)/2)
            arrImageRt.append(rt0)
            
            var rt3: NSRect = NSZeroRect
            rt3.origin.x = rt0.origin.x
            rt3.origin.y = rt0.origin.y + rt0.size.height
            rt3.size.width = rt0.size.width
            rt3.size.height = CGFloat(midWidth)
            arrImageRt.append(rt3)
            
            var rt6: NSRect = NSZeroRect
            rt6.origin.x = rt3.origin.x
            rt6.origin.y = rt3.origin.y + rt3.size.height
            rt6.size.width = rt3.size.width
            rt6.size.height = imgSize.height - rt3.size.height - rt0.size.height
            arrImageRt.append(rt6)
            
            //draw rect array
            
            var drawRt0: NSRect = rt0
            drawRt0.origin = viewBounds.origin
            arrDrawRt.append(drawRt0)
            
            var drawRt3: NSRect = NSZeroRect
            drawRt3.origin.x = drawRt0.origin.x
            drawRt3.origin.y = drawRt0.origin.y + drawRt0.size.height
            drawRt3.size.width = drawRt0.size.width
            drawRt3.size.height = viewBounds.size.height - rt0.size.height - rt6.size.height
            arrDrawRt.append(drawRt3)
            
            var drawR6: NSRect = NSZeroRect
            drawR6.origin.x = drawRt3.origin.x
            drawR6.origin.y = drawRt3.origin.y + drawRt3.size.height
            drawR6.size.width = drawRt3.size.width
            drawR6.size.height = rt6.size.height
            arrDrawRt.append(drawR6)
        }
        
        for index in 0...2 {
            if index == 1 {
                var needDrawRt : NSRect = NSIntersectionRect(visibleRect, arrDrawRt[index])
                if horizial {
                    needDrawRt.origin.y = arrDrawRt[index].origin.y
                    needDrawRt.size.height = arrDrawRt[index].size.height
                }
                else {
                    needDrawRt.origin.x = arrDrawRt[index].origin.x
                    needDrawRt.size.width = arrDrawRt[index].size.width
                }
                image.draw(in: needDrawRt, from: arrImageRt[index], operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            }
            else {
                image.draw(in: arrDrawRt[index], from: arrImageRt[index], operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            }
        }
    }
}

#endif
