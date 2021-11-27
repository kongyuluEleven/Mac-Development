//
//  CALayer+Extension.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if !os(watchOS) && !os(Linux) && canImport(QuartzCore)
import QuartzCore

#if canImport(AppKit)
import AppKit
#endif

// MARK: - 获取图层图片
public extension CALayer {
    
    /// 获取layer层的截图，默认大小为layer的尺寸bounds大小
    /// - Returns: 返回截图NSImage
    func image() -> NSImage? {
        return self.image(by: self.bounds.size)
    }
    
    
    /// 获取Layer层截图
    /// - Parameter size: 需要裁减的图片大小
    /// - Returns: 返回截图NSImage
    func image(by size:NSSize) -> NSImage? {
        let width = Int(size.width * self.contentsScale)
        let height = Int(size.height * self.contentsScale)
        
        if width <= 0 || height <= 0 {
            return NSImage(size: NSSize(width: width, height: height))
        }
        
        guard let imageRepresentation = NSBitmapImageRep(bitmapDataPlanes: nil,
                                                   pixelsWide: width,
                                                   pixelsHigh: height,
                                                   bitsPerSample: 8,
                                                   samplesPerPixel: 4,
                                                   hasAlpha: true,
                                                   isPlanar: false,
                                                   colorSpaceName: NSColorSpaceName.deviceRGB,
                                                   bytesPerRow: 0,
                                                   bitsPerPixel: 0) else {
            return nil
        }
        
        imageRepresentation.size = NSSize(width: width, height: height)
        let context = NSGraphicsContext(bitmapImageRep: imageRepresentation)!
        render(in: context.cgContext)
        
        return NSImage(cgImage: imageRepresentation.cgImage!, size: NSSize(width: width, height: height))
    }
}


// MARK: - 打印图层信息
public extension CALayer {
  
    /// 打印图层数信息，递归打印所有图层信息
    /// - Parameter withIndent: 空格符个数
  func logLayerTree(withIndent: Int = 0) {
    var string = ""
    for _ in 0...withIndent {
      string = string + "  "
    }
    string = string + "|_" + String(describing: self)
    print(string)
    if let sublayers = sublayers {
      for sublayer in sublayers {
        sublayer.logLayerTree(withIndent: withIndent + 1)
      }
    }
  }

}

#endif
