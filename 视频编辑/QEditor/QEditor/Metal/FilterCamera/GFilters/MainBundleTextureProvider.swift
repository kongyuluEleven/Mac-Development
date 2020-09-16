//
//  MainBundleTextureProvider.swift
//  imageprocessing01
//
//  Created by LEE CHUL HYUN on 5/11/18.
//  Copyright © 2018 LEE CHUL HYUN. All rights reserved.
//

import Foundation
import UIKit
import Metal

class MainBundleTextureProvider: GTextureProvider {
    var texture: MTLTexture?
    
    init(image: UIImage, context: GContext, mipmapped: Bool) {
        texture = self.texture(image: image, context: context, mipmapped: mipmapped)
    }
    
    func texture(image: UIImage, context: GContext, mipmapped: Bool) -> MTLTexture {
        let imageRef = image.cgImage
        let width = imageRef!.width
        let height = imageRef!.height
        let space = CGColorSpaceCreateDeviceRGB()
        let rawData = UnsafeMutableRawPointer.allocate(byteCount: width * height * 4, alignment: 1)// UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        let bitmmapContext = CGContext.init(data: rawData, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGImageByteOrderInfo.order32Big.rawValue)
//        bitmmapContext?.translateBy(x: 0, y: CGFloat(height))
//        bitmmapContext?.scaleBy(x: 1, y: -1)
        bitmmapContext?.draw(imageRef!, in: CGRect.init(x: 0, y: 0, width: CGFloat(width), height: CGFloat(height)))
        let textureDescriptor: MTLTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: mipmapped)
        if mipmapped == true {
            textureDescriptor.usage = [.shaderRead, .shaderWrite, .pixelFormatView]
        }
        else {
            textureDescriptor.usage = .shaderRead
        }
        let texture = context.device.makeTexture(descriptor: textureDescriptor)
        let region = MTLRegionMake2D(0, 0, width, height)
        texture?.replace(region: region, mipmapLevel: 0, withBytes: rawData, bytesPerRow: bytesPerRow)
        rawData.deallocate()

        return texture!
    }
    
    func provideTexture(textureBlock: (_ texture: MTLTexture?) -> Void) {
        textureBlock(self.texture)
    }
}
