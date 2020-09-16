//
//  Image+texture.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/16.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import UIKit
import Metal
import Accelerate

extension UIImage {
    
    convenience init?(texture: MTLTexture?) {
        
        guard let texture = texture else {
            return nil
        }
        let imageSize = CGSize.init(width: texture.width, height: texture.height)
        let imageByteCount = imageSize.width * imageSize.height * 4
        let imageBytes = UnsafeMutablePointer<UInt8>.allocate(capacity: Int(imageSize.width * imageSize.height * 4))
        let bytesPerRow = UInt(imageSize.width) * 4
        let region = MTLRegionMake2D(0, 0, Int(imageSize.width), Int(imageSize.height))
        texture.getBytes(imageBytes, bytesPerRow: Int(bytesPerRow), from: region, mipmapLevel: 0)
        let provider = CGDataProvider.init(dataInfo: nil, data: imageBytes, size: Int(imageByteCount)) { (raw1, raw2, val) in
            raw2.deallocate()
        }
        let bitsPerComponent = 8
        let bitsPerPixel = 32
        let space = CGColorSpaceCreateDeviceRGB()
        let renderingIntent: CGColorRenderingIntent = .defaultIntent

        let imageRef = CGImage.init(width: Int(imageSize.width),
                                    height: Int(imageSize.height),
                                    bitsPerComponent: bitsPerComponent,
                                    bitsPerPixel: bitsPerPixel,
                                    bytesPerRow: Int(bytesPerRow),
                                    space: space,
                                    bitmapInfo: CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue),
                                    provider: provider!,
                                    decode: nil,
                                    shouldInterpolate: false,
                                    intent: renderingIntent)
        self.init(cgImage: imageRef!)
    }
}


extension UIImage {

    func fixedOrientation() -> UIImage {
        
        guard imageOrientation != UIImage.Orientation.up else {
            //This is default orientation, don't need to do anything
            return self
        }
        
        guard let cgImage = self.cgImage else {
            //CGImage is not available
            return self
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return self //Not able to create CGContext
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        }
        
        //Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: size.width, y: 0)
            transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: size.height, y: 0)
            transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else { return self }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
    
    public convenience init(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        color.setFill()
        UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: (image?.cgImage)!)
    }

}

extension UIImage {
    /**
     Converts an MTLTexture into a UIImage. This is useful for debugging.
     - TODO: This was not necessarily designed for speed. For more speed,
     look into using the vImage functions from Accelerate.framework or
     maybe CIImage.
     - Note: For `.float16` textures the pixels are expected to be in the range
     0...1; if you're using a different range (e.g. 0...255) then you have
     to specify a `scale` factor and possibly an `offset`. Alternatively, you
     can use an `MPSNeuronLinear` to scale the pixels down first.
     */
    @nonobjc public class func image(texture: MTLTexture,
                                     scale: Float = 1,
                                     offset: Float = 0) -> UIImage? {
        switch texture.pixelFormat {
        case .rgba16Float:
            return image(textureRGBA16Float: texture, scale: scale, offset: offset)
        case .r16Float:
            return image(textureR16Float: texture, scale: scale, offset: offset)
        case .rgba8Unorm:
            return image(textureRGBA8Unorm: texture)
        case .bgra8Unorm:
            return image(textureBGRA8Unorm: texture)
        case .r8Unorm:
            return image(textureR8Unorm: texture)
        default:
            debugPrint("Unsupported pixel format \(texture.pixelFormat.rawValue)")
            return nil
        }
    }
    
    @nonobjc class func image(textureRGBA16Float texture: MTLTexture,
                              scale: Float = 1,
                              offset: Float = 0) -> UIImage {
        
        // The texture must be `.float16` format. This means every RGBA pixel is
        // a 16-bit float, so one pixel takes up 64 bits.
        assert(texture.pixelFormat == .rgba16Float)
        
        let w = texture.width
        let h = texture.height
        
        // First get the bytes from the texture.
        var outputFloat16 = texture.toFloat16Array(width: w, height: h, featureChannels: 4)
        
        // Convert 16-bit floats to 32-bit floats.
        let outputFloat32 = float16to32(&outputFloat16, count: w * h * 4)
        
        // Convert the floats to bytes. The floats can go outside the range 0...1,
        // so we need to clamp the values when we turn them back into bytes.
        var outputRGBA = [UInt8](repeating: 0, count: w * h * 4)
        for i in 0..<outputFloat32.count {
            let value = outputFloat32[i] * scale + offset
            outputRGBA[i] = UInt8(max(min(255, value * 255), 0))
        }
        
        // Finally, turn the byte array into a UIImage.
        return UIImage.fromByteArray(&outputRGBA, width: w, height: h)
    }
    
    @nonobjc class func image(textureR16Float texture: MTLTexture,
                              scale: Float = 1,
                              offset: Float = 0) -> UIImage {
        
        assert(texture.pixelFormat == .r16Float)
        
        let w = texture.width
        let h = texture.height
        
        var outputFloat16 = texture.toFloat16Array(width: w, height: h, featureChannels: 1)
        let outputFloat32 = float16to32(&outputFloat16, count: w * h)
        
        var outputRGBA = [UInt8](repeating: 0, count: w * h * 4)
        for i in 0..<outputFloat32.count {
            let value = outputFloat32[i] * scale + offset
            let color = UInt8(max(min(255, value * 255), 0))
            outputRGBA[i*4 + 0] = color
            outputRGBA[i*4 + 1] = color
            outputRGBA[i*4 + 2] = color
            outputRGBA[i*4 + 3] = 255
        }
        
        return UIImage.fromByteArray(&outputRGBA, width: w, height: h)
    }
    
    @nonobjc class func image(textureRGBA8Unorm texture: MTLTexture) -> UIImage {
        assert(texture.pixelFormat == .rgba8Unorm)
        
        let w = texture.width
        let h = texture.height
        var bytes = texture.toUInt8Array(width: w, height: h, featureChannels: 4)
        return UIImage.fromByteArray(&bytes, width: w, height: h)
    }
    
    @nonobjc class func image(textureBGRA8Unorm texture: MTLTexture) -> UIImage {
        assert(texture.pixelFormat == .bgra8Unorm)
        
        let w = texture.width
        let h = texture.height
        var bytes = texture.toUInt8Array(width: w, height: h, featureChannels: 4)
        
        // gzonelee, laplacian일 경우 alpha값이 항상 0이라서 강제로 255로 해준다.
        for i in 0..<bytes.count/4 {
            bytes[i * 4 + 3] = 255
            bytes.swapAt(i*4 + 0, i*4 + 2)
        }
        
        return UIImage.fromByteArray(&bytes, width: w, height: h)
    }
    
    @nonobjc class func image(textureR8Unorm texture: MTLTexture) -> UIImage {
        assert(texture.pixelFormat == .r8Unorm)
        
        let w = texture.width
        let h = texture.height
        var bytes = texture.toUInt8Array(width: w, height: h, featureChannels: 1)
        
        var rgbaBytes = [UInt8](repeating: 0, count: w * h * 4)
        for i in 0..<bytes.count {
            rgbaBytes[i*4 + 0] = bytes[i]
            rgbaBytes[i*4 + 1] = bytes[i]
            rgbaBytes[i*4 + 2] = bytes[i]
            rgbaBytes[i*4 + 3] = 255
        }
        
        return UIImage.fromByteArray(&rgbaBytes, width: w, height: h)
    }
}

extension UIImage {
    /**
     Converts the image into an array of RGBA bytes.
     */
    @nonobjc public func toByteArray() -> [UInt8] {
        let width = Int(size.width)
        let height = Int(size.height)
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        
        bytes.withUnsafeMutableBytes { ptr in
            if let context = CGContext(
                data: ptr.baseAddress,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: width * 4,
                space: CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
                
                if let image = self.cgImage {
                    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
                    context.draw(image, in: rect)
                }
            }
        }
        return bytes
    }
    
    /**
     Creates a new UIImage from an array of RGBA bytes.
     */
    @nonobjc public class func fromByteArray(_ bytes: UnsafeMutableRawPointer,
                                             width: Int,
                                             height: Int) -> UIImage {
        
        if let context = CGContext(data: bytes, width: width, height: height,
                                   bitsPerComponent: 8, bytesPerRow: width * 4,
                                   space: CGColorSpaceCreateDeviceRGB(),
                                   bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue),
            let cgImage = context.makeImage() {
            return UIImage(cgImage: cgImage, scale: 0, orientation: .up)
        } else {
            return UIImage()
        }
    }
}

extension MTLTexture {
    /**
     Creates a new array of `Float`s and copies the texture's pixels into it.
     */
    public func toFloatArray(width: Int, height: Int, featureChannels: Int) -> [Float] {
        return toArray(width: width, height: height,
                       featureChannels: featureChannels, initial: Float(0))
    }
    
    /**
     Creates a new array of `Float16`s and copies the texture's pixels into it.
     */
    public func toFloat16Array(width: Int, height: Int, featureChannels: Int) -> [Float16] {
        return toArray(width: width, height: height,
                       featureChannels: featureChannels, initial: Float16(0))
    }
    
    /**
     Creates a new array of `UInt8`s and copies the texture's pixels into it.
     */
    public func toUInt8Array(width: Int, height: Int, featureChannels: Int) -> [UInt8] {
        return toArray(width: width, height: height,
                       featureChannels: featureChannels, initial: UInt8(0))
    }
    
    /**
     Convenience function that copies the texture's pixel data to a Swift array.
     The type of `initial` determines the type of the output array. In the
     following example, the type of bytes is `[UInt8]`.
     let bytes = texture.toArray(width: 100, height: 100, featureChannels: 4, initial: UInt8(0))
     - Parameters:
     - featureChannels: The number of color components per pixel: must be 1, 2, or 4.
     - initial: This parameter is necessary because we need to give the array
     an initial value. Unfortunately, we can't do `[T](repeating: T(0), ...)`
     since `T` could be anything and may not have an init that takes a literal
     value.
     */
    func toArray<T>(width: Int, height: Int, featureChannels: Int, initial: T) -> [T] {
        assert(featureChannels != 3 && featureChannels <= 4, "channels must be 1, 2, or 4")
        
        var bytes = [T](repeating: initial, count: width * height * featureChannels)
        let region = MTLRegionMake2D(0, 0, width, height)
        getBytes(&bytes, bytesPerRow: width * featureChannels * MemoryLayout<T>.stride,
                 from: region, mipmapLevel: 0)
        return bytes
    }
}

/* Utility functions for dealing with 16-bit floating point values in Swift. */

/**
 Since Swift has no datatype for a 16-bit float we use `UInt16`s instead,
 which take up the same amount of memory. (Note: The simd framework does
 have "half" types but only for 2, 3, or 4-element vectors, not scalars.)
 */
public typealias Float16 = UInt16

/**
 Creates a new array of Swift `Float` values from a buffer of float-16s.
 */
public func float16to32(_ input: UnsafeMutablePointer<Float16>, count: Int) -> [Float] {
    var output = [Float](repeating: 0, count: count)
    float16to32(input: input, output: &output, count: count)
    return output
}

/**
 Converts a buffer of float-16s into a buffer of `Float`s, in-place.
 */
public func float16to32(input: UnsafeMutablePointer<Float16>, output: UnsafeMutableRawPointer, count: Int) {
    var bufferFloat16 = vImage_Buffer(data: input,  height: 1, width: UInt(count), rowBytes: count * 2)
    var bufferFloat32 = vImage_Buffer(data: output, height: 1, width: UInt(count), rowBytes: count * 4)
    
    if vImageConvert_Planar16FtoPlanarF(&bufferFloat16, &bufferFloat32, 0) != kvImageNoError {
        print("Error converting float16 to float32")
    }
}

/**
 Creates a new array of float-16 values from a buffer of `Float`s.
 */
public func float32to16(_ input: UnsafeMutablePointer<Float>, count: Int) -> [Float16] {
    var output = [Float16](repeating: 0, count: count)
    float32to16(input: input, output: &output, count: count)
    return output
}

/**
 Converts a buffer of `Float`s into a buffer of float-16s, in-place.
 */
public func float32to16(input: UnsafeMutablePointer<Float>, output: UnsafeMutableRawPointer, count: Int) {
    var bufferFloat32 = vImage_Buffer(data: input,  height: 1, width: UInt(count), rowBytes: count * 4)
    var bufferFloat16 = vImage_Buffer(data: output, height: 1, width: UInt(count), rowBytes: count * 2)
    
    if vImageConvert_PlanarFtoPlanar16F(&bufferFloat32, &bufferFloat16, 0) != kvImageNoError {
        print("Error converting float32 to float16")
    }
}
