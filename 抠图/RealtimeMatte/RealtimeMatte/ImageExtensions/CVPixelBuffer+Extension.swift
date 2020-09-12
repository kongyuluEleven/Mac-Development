//
//  CVPixelBuffer+Extension.swift
//
//  Created by Evan Xie on 2019/5/30.
//

import CoreVideo
import CoreMedia
import UIKit

public extension CVPixelBuffer {
    
    /// 设置 CVPixelBuffer 是否适用于特定的渲染库
    ///
    /// - kCVPixelBufferCGBitmapContextCompatibilityKey
    /// - kCVPixelBufferMetalCompatibilityKey
    /// - kCVPixelBufferOpenGLCompatibilityKey
    /// - kCVPixelBufferOpenGLESCompatibilityKey
    /// - none
    enum CompatibilityType: Int {
        case bitmap
        case metal
        case openGL
        case openGLES
        case none
        
        public var attribute: [String: Any] {
            switch self {
            case .bitmap:
                return [kCVPixelBufferCGBitmapContextCompatibilityKey: true] as [String: Any]
            case .metal:
                return [kCVPixelBufferMetalCompatibilityKey: true] as [String: Any]
            case .openGL:
                return [kCVPixelBufferOpenGLCompatibilityKey: true] as [String: Any]
            case .openGLES:
                return [kCVPixelBufferOpenGLESCompatibilityKey: true] as [String: Any]
            case .none:
                return [:]
            }
        }
    }
    
    /// 创建指定大小与像素格式的空图像buffer.
    ///
    /// ```
    /// let width = CVPixelBufferGetWidth(pixelBuffer)
    /// let height = CVPixelBufferGetHeight(pixelBuffer)
    /// let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
    /// let bytesPerPixel: Int = 4
    ///
    /// for row in 0..<height {
    ///     let rowBaseAddress = bufferBaseAddress.advanced(by: row * bytesPerRow)
    ///     for col in 0..<width {
    ///         let pixel = rowBaseAddress.advanced(by: col * bytesPerPixel)
    ///         pixel[0] = 255
    ///         pixel[1] = 0
    ///         pixel[2] = 0
    ///         pixel[3] = 255
    ///     }
    /// }
    /// ```
    static func make(width: Int, height: Int, pixelFormat: OSType, compatibility: CompatibilityType = .none) throws -> CVPixelBuffer {
        var pixelBuffer: CVPixelBuffer?
        var attributes = [
            kCVPixelBufferWidthKey: width,
            kCVPixelBufferHeightKey: height,
            kCVPixelBufferIOSurfacePropertiesKey: [:]
            ] as [String: Any]
        
        for (key, value) in compatibility.attribute {
            attributes[key] = value
        }
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, width, height, pixelFormat, attributes as CFDictionary, &pixelBuffer)
        guard status == kCVReturnSuccess else {
            print("Make pixel buffer failed: \(status), \(status.fourCharCodeString)")
            throw ImageError.errorWithReason("Make pixel buffer failed: \(status.fourCharCodeString)")
        }
        
        return pixelBuffer!
    }
    
    func toUIImage() -> UIImage? {
        let ciImage = CIImage(cvImageBuffer: self)
        let context = CIContext()
        let width = CVPixelBufferGetWidth(self)
        let height = CVPixelBufferGetHeight(self)
        let imageRect = CGRect(x: 0, y: 0, width: width, height: height)
        guard let cgImage = context.createCGImage(ciImage, from: imageRect) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    /// 深拷贝 CVPixelBuffer
    /// http://stackoverflow.com/questions/38335365/pulling-data-from-a-cmsamplebuffer-in-order-to-create-a-deep-copy
    func copy() throws -> CVPixelBuffer {
        
        var copiedPixelBuffer: CVPixelBuffer?
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         CVPixelBufferGetWidth(self),
                                         CVPixelBufferGetHeight(self),
                                         CVPixelBufferGetPixelFormatType(self),
                                         nil,
                                         &copiedPixelBuffer)
        guard status == kCVReturnSuccess, let copied = copiedPixelBuffer else {
            throw ImageError.coreVideoError(CVReturnWrapper(status))
        }

        CVPixelBufferLockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
        CVPixelBufferLockBaseAddress(copied, CVPixelBufferLockFlags(rawValue: 0))
        defer {
            CVPixelBufferUnlockBaseAddress(self, CVPixelBufferLockFlags(rawValue: 0))
            CVPixelBufferUnlockBaseAddress(copied, CVPixelBufferLockFlags(rawValue: 0))
        }

        let dest = CVPixelBufferGetBaseAddress(copied)
        let src = CVPixelBufferGetBaseAddress(self)
        let height = CVPixelBufferGetHeight(self)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(self)
        memcpy(dest, src, height * bytesPerRow)

        return copied
    }
}

public extension CVPixelBuffer {
    
    /// 从 `CVPixelBuffer` 中提取图像格式信息
    var formatDescription: CMVideoFormatDescription? {
        var format: CMVideoFormatDescription?
        let status = CMVideoFormatDescriptionCreateForImageBuffer(allocator: kCFAllocatorDefault, imageBuffer: self, formatDescriptionOut: &format)
        guard status == noErr else {
            print("Create video format description failed: \(status.fourCharCodeString)")
            return nil
        }
        return format
    }
}
