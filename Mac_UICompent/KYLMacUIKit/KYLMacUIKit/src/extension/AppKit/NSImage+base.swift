//
//  NSImage+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit


// MARK: - 获取图片
public extension NSImage {
    /// 获取一张空图片对象
    static var empty: NSImage { NSImage(size: .zero) }
    
    /// 根据颜色，生成一种图片
    /// - Parameters:
    ///   - size: 图片尺寸大小
    ///   - color: 背景颜色
    ///   - radius: 圆角
    /// - Returns: 返回背景色为color的一张图片
    static func image(size:CGSize, color:NSColor, radius:CGFloat) -> NSImage {
        let image = NSImage(size: NSSize(width: size.width, height: size.height),
                            flipped: true) { (rect) -> Bool in
            let path = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: size.width, height: size.height),
                                    xRadius: radius,
                                    yRadius: radius)
            color.setFill()
            path.fill()
            return true
        }
        return image
    }
    
    
    /// 获取cgImage
    @objc var cGImage: CGImage? {
      get {
        guard let imageData = self.tiffRepresentation else { return nil }
        guard let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) else { return nil }
        return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
      }
    }
}


// MARK: - 图片保存

public extension NSImage {
    /// Write NSImage to url.
    ///
    /// - Parameters:
    ///   - url: Desired file URL.
    ///   - type: Type of image (default is .jpeg).
    ///   - compressionFactor: used only for JPEG files. The value is a float between 0.0 and 1.0, with 1.0 resulting in no compression and 0.0 resulting in the maximum compression possible.
    func write(to url: URL, fileType type: NSBitmapImageRep.FileType = .jpeg, compressionFactor: NSNumber = 1.0) {
        // https://stackoverflow.com/a/45042611/3882644

        guard let data = tiffRepresentation else { return }
        guard let imageRep = NSBitmapImageRep(data: data) else { return }

        guard let imageData = imageRep.representation(using: type, properties: [.compressionFactor: compressionFactor]) else { return }
        try? imageData.write(to: url)
    }
}


public extension NSImage {
    
    /// 获取png图片的二进制数据
    /// - Returns: 返回二进制字节数据
    func pngRepresentation() -> Data? {
        guard let cgRef = self.cgImage(forProposedRect: nil, context: nil, hints: nil) else {return nil}
        let newRep = NSBitmapImageRep(cgImage: cgRef)
        newRep.size = self.size
        return newRep.representation(using: .png, properties: [NSBitmapImageRep.PropertyKey:Any]())
    }
    
    
    /// 根据颜色生成一张图片
    /// - Parameters:
    ///   - color: 颜色值
    ///   - operation: 复合操作符的操作类型
    /// - Returns: 返回一张图片
    func tintedImage(color:NSColor, operation:NSCompositingOperation = .sourceAtop ) -> NSImage {
        let bounds = NSMakeRect(0.0, 0.0, self.size.width, self.size.height)
        let image = NSImage(size: self.size)
        
        image.lockFocus()
        self.draw(at: .zero, from: bounds, operation: .sourceOver, fraction: 1.0)
        color.set()
        bounds.fill(using: operation)
        image.unlockFocus()
        
        return image
    }
    
}


#endif
