//
//  CGImage+Conversion.swift
//  VideoMatte
//
//  Created by ws on 2020/9/8.
//  Copyright © 2020 ws. All rights reserved.
//

import Foundation
import CoreGraphics
import CoreVideo

extension CGImage {
    
    /// Pixel 二进制数据布局信息
    struct PixelLayout {
        var bitsPerComponent: Int = 8
        var bitsPerPixel: Int = 32
        var alphaInfo: CGImageAlphaInfo
        var bitmapInfo: CGBitmapInfo
        
        var combinedBitmapInfo: CGBitmapInfo {
            return CGBitmapInfo(rawValue: alphaInfo.rawValue | bitmapInfo.rawValue)
        }
    }
    
    /// 从给定的 pixel 二进制数据创建图片
    static func make(from data: Data, width: Int, height: Int, layout: PixelLayout) throws -> CGImage {
        guard let dataProvider = CGDataProvider(data: data as CFData) else {
            throw ImageError.errorWithReason("Create CGDataProvider from data failed")
        }
        
        guard let image = CGImage(
            width: width,
            height: height,
            bitsPerComponent: layout.bitsPerComponent,
            bitsPerPixel: layout.bitsPerPixel,
            bytesPerRow: layout.bitsPerPixel / layout.bitsPerComponent * width,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: layout.combinedBitmapInfo,
            provider: dataProvider,
            decode: nil,
            shouldInterpolate: false,
            intent: .defaultIntent) else {
                throw ImageError.errorWithReason("Create CGImage from CGDataProvider failed")
        }
        
        return image
    }
    
    /// 将 CGImage 转换成 CVPixelBuffer
    func toPixelBuffer () throws -> CVPixelBuffer {
        var pixelBuffer = try CVPixelBuffer.make(width: width, height: height, pixelFormat: kCVPixelFormatType_32BGRA)
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        }
        
        let data = CVPixelBufferGetBaseAddress(pixelBuffer)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        
        let context = CGContext(data: data, width: width, height: height, bitsPerComponent: 8,
                                bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(self, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        return pixelBuffer
    }
}
