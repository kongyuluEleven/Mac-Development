//
//  NSImage+stretch.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - 拉伸图片

public extension NSImage {
    
    /// 已左右不变，中间拉伸的方式拉伸图片，得到一张拉伸后的新图片
    /// - Parameters:
    ///   - originImage: 需要拉伸的图片
    ///   - size: 拉伸后图片大小
    ///   - horizial: 是否是水平拉伸
    ///   - middleWidth: 图片拉伸中间段，左右两段保持不拉伸
    /// - Returns: 返回以左中右三段方式拉伸后的图片
    class func stretch(for3part originImage:NSImage , size: NSSize, horizial: Bool, _ middleFixedWidth: CGFloat = 1.0) -> NSImage?{
        if NSEqualSizes(size, NSZeroSize) {
            return nil
        }
        
        let image: NSImage? = NSImage(size:size)
        
        if horizial {
            let midW: Int = Int(middleFixedWidth)
            
            let orignImgWidth: Int = Int(originImage.size.width)
            let dstImgWidth: Int = Int(size.width)
            
            var imgRt: NSRect = NSZeroRect
            var drawRt: NSRect = NSZeroRect
            imgRt.size.height = originImage.size.height
            drawRt.size.height = size.height
            
            image?.lockFocus()
            
            //left
            imgRt.size.width = CGFloat((orignImgWidth - midW)/2)
            drawRt.size.width = imgRt.size.width
            originImage.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            
            //middle
            imgRt.origin.x += imgRt.size.width
            imgRt.size.width = CGFloat(midW)
            drawRt.origin.x += drawRt.size.width
            drawRt.size.width = size.width - 2 * CGFloat((orignImgWidth - midW)/2)
            originImage.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            
            //right
            imgRt.origin.x += imgRt.size.width
            imgRt.size.width = CGFloat(orignImgWidth) - imgRt.origin.x
            drawRt.origin.x += drawRt.size.width
            drawRt.size.width = CGFloat(dstImgWidth) - drawRt.origin.x
            originImage.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            
            image?.unlockFocus()
        }
        else {
            let midH: Int = Int(middleFixedWidth)
            
            let orignImgHeight: Int = Int(originImage.size.height)
            let dstImgHeight: Int = Int(size.height)
            
            var imgRt: NSRect = NSZeroRect
            var drawRt: NSRect = NSZeroRect
            imgRt.size.width = originImage.size.width
            drawRt.size.width = size.width
            
            image?.lockFocus()
            
            //bottom
            imgRt.size.height = CGFloat((orignImgHeight - midH)/2)
            drawRt.size.height = CGFloat((dstImgHeight - midH)/2)
            image?.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            
            //middle
            imgRt.origin.y += imgRt.size.height
            imgRt.size.height = CGFloat(midH)
            drawRt.origin.y += drawRt.size.height
            drawRt.size.height = size.height - 2 * CGFloat((orignImgHeight - midH)/2)
            image?.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            
            //top
            imgRt.origin.y += imgRt.size.height
            imgRt.size.height = CGFloat((orignImgHeight - midH)/2)
            drawRt.origin.y += drawRt.size.height
            drawRt.size.height = CGFloat((dstImgHeight - midH)/2)
            image?.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
            
            image?.unlockFocus()
        }
        
        return image
    }


    /// 按九宫格方式拉伸图片，返回一张拉伸后的图片
    /// - Parameters:
    ///   - originImage: 需要拉伸的原始图片
    ///   - size: 拉伸后图片的大小
    /// - Returns: 返回以九宫方式拉伸后的图片
    class func stretch(for9Part originImage: NSImage, size: NSSize) -> NSImage? {
        let edg = NSEdgeInsets(top: CGFloat((originImage.size.width - 1)/2),
                               left: CGFloat((originImage.size.height - 1)/2),
                               bottom: CGFloat((originImage.size.width - 1)/2 + 1),
                               right: CGFloat((originImage.size.height - 1)/2 + 1))
        return stretch(for9Part: originImage, size: size, edgeInsets: edg)
    }

    
    /// 按九宫格方式拉伸图片，返回一张拉伸后的图片
    /// - Parameters:
    ///   - originImage: 需要拉伸的原始图片
    ///   - size: 九宫方式拉伸后图片的大小
    ///   - edgeInsets: 九宫方式拉伸时，确定具体拉伸的区域
    /// - Returns: 返回以九宫方式拉伸后的图片
    class func stretch(for9Part originImage: NSImage, size: NSSize , edgeInsets: NSEdgeInsets = NSEdgeInsets.zero) -> NSImage? {
        if NSEqualSizes(size, NSZeroSize) {
            return nil
        }
        
        let image : NSImage? = NSImage(size:size)
        var imgRt : NSRect = NSZeroRect
        var drawRt : NSRect = NSZeroRect
        let imgSize : NSSize = originImage.size
        
        image?.lockFocus()
        
        // top left(上左)
        imgRt.origin.x = 0
        imgRt.origin.y = imgSize.height - edgeInsets.top
        imgRt.size.width = edgeInsets.left
        imgRt.size.height = edgeInsets.top
        
        drawRt.origin.x = 0
        drawRt.origin.y = size.height - edgeInsets.top
        drawRt.size = imgRt.size
        
        originImage.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        //top middle（上中）
        imgRt.origin.x += imgRt.size.width
        imgRt.size.width = edgeInsets.right - edgeInsets.bottom
        
        drawRt.origin.x += drawRt.size.width
        drawRt.size.width = size.width - (imgSize.width - imgRt.size.width)
        
        originImage.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        //top right（上右）
        imgRt.origin.x += imgRt.size.width
        imgRt.size.width = imgSize.width - edgeInsets.right
        drawRt.origin.x += drawRt.size.width
        drawRt.size = imgRt.size
        
        originImage.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        //middle left（中左）
        imgRt.origin.x = 0
        imgRt.origin.y = edgeInsets.bottom
        imgRt.size.width = edgeInsets.left
        imgRt.size.height = edgeInsets.bottom - edgeInsets.top
        
        drawRt.origin.x = 0
        drawRt.origin.y = edgeInsets.bottom
        drawRt.size.width = edgeInsets.left
        drawRt.size.height = size.height - (imgSize.height - imgRt.size.height)
        
        originImage.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        //middle middle (中中)
        imgRt.origin.x += imgRt.size.width
        imgRt.size.width = edgeInsets.right - edgeInsets.left
        drawRt.origin.x += drawRt.size.width
        drawRt.size.width = size.width - (imgSize.width - imgRt.size.width)
        
        originImage.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        //middle right (中右)
        imgRt.origin.x += imgRt.size.width
        imgRt.size.width = imgSize.width - edgeInsets.right
        drawRt.origin.x += drawRt.size.width
        drawRt.size.width = imgSize.width - edgeInsets.right
        
        originImage.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        //bottom left（下左）
        imgRt.origin.x = 0
        imgRt.origin.y = 0
        imgRt.size.width = edgeInsets.left
        imgRt.size.height = imgSize.height - edgeInsets.bottom
        
        drawRt.origin.x = 0
        drawRt.origin.y = 0
        drawRt.size = imgRt.size
        
        originImage.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        //bottom middle（下中）
        imgRt.origin.x += imgRt.size.width
        imgRt.size.width = edgeInsets.right - edgeInsets.bottom
        
        drawRt.origin.x += drawRt.size.width
        drawRt.size.width = size.width - (imgSize.width - imgRt.size.width)
        originImage.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        //bottom right（下右）
        imgRt.origin.x += imgRt.size.width
        imgRt.size.width = imgSize.width - edgeInsets.right
        drawRt.origin.x += drawRt.size.width
        drawRt.size = imgRt.size
        
        originImage.draw(in: drawRt, from: imgRt, operation: NSCompositingOperation.sourceOver, fraction: 1.0)
        
        image?.unlockFocus()
        
        return image
    }
}

#endif
