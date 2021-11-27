//
//  NSImage+color.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - 获取图片中的颜色

public extension NSImage {
    
    /// 找出图像的平均颜色
    /// - Returns: 返回图片的平均颜色
    @objc func averageColor() -> NSColor {
        //1. 设置一个单像素的图像
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmap = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue
                                    | CGBitmapInfo.byteOrder32Big.rawValue)
        
        guard let bitmapData = malloc(4),
              let context = CGContext(data: bitmapData,
                                      width: 1,
                                      height: 1,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 4,
                                      space: colorSpace,
                                      bitmapInfo: bitmap.rawValue),
              let cgImage = self.cgImage(forProposedRect: nil,
                                         context: NSGraphicsContext(cgContext: context, flipped: false),
                                         hints: nil) else {
            //没有符合条件，则返回默认的白色
            return .white
        }
        
        //2. 绘制一张1个像素的图片
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        
        //3. 从单像素图像中提取字节颜色
        let r = bitmapData.load(fromByteOffset: 0, as: UInt8.self)
        let g = bitmapData.load(fromByteOffset: 1, as: UInt8.self)
        let b = bitmapData.load(fromByteOffset: 2, as: UInt8.self)
        let a = bitmapData.load(fromByteOffset: 3, as: UInt8.self)
        
        //4. 生成一个平均颜色值对象
        let modifier = a > 0 ? CGFloat(a) / 255.0 : 1.0
        let red = CGFloat(r) * modifier / 255.0
        let green = CGFloat(g) * modifier / 255.0
        let blue = CGFloat(b) * modifier / 255.0
        let alpha = CGFloat(a) / 255.0
    
        return NSColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

#endif
