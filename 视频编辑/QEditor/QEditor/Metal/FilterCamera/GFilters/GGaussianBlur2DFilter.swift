//
//  GGaussianBlur2DFilter.swift
//  imageprocessing01
//
//  Created by chlee on 11/05/2018.
//  Copyright © 2018 LEE CHUL HYUN. All rights reserved.
//

import Foundation
import Metal

class GGaussianBlur2DFilter : GImageFilter {

    var _radius: Float = 0
    var radius: Float {
        get {
            return _radius
        }
        set {
            self.isDirty = true
            _radius = newValue;
            _sigma = newValue / 2.0
            self.blurWeightTexture = nil
        }
    }
    
    var _sigma: Float = 0
    var sigma: Float {
        get {
            return _sigma
        }
        set {
            self.isDirty = true
            _sigma = newValue
            self.blurWeightTexture = nil
        }
    }
    
    var blurWeightTexture: MTLTexture?

    override init?(context: GContext, filterType: GImageFilterType) {
        super.init(functionName: "gaussian_blur_2d", context: context, filterType: filterType)
    }
    
    func generateBlurWeightTexture() {
        assert(self.radius >= 0, "Blur radius must be non-negative")
        
        let radius = self.radius
        let sigma = self.sigma
        let size: Int = Int(round(radius) * 2) + 1
        
        var delta: Float = 0
        var expScale: Float = 0
        if radius > 0.0 {
            delta = (radius * 2) / Float(size - 1)
            expScale = -1 / (2 * sigma * sigma)
        }
        
        let weights = UnsafeMutablePointer<Float>.allocate(capacity: size * size)
        
        var weightSum: Float = 0
        var y: Float = -radius
        for j in 0..<size {
            var x: Float = -radius
            for i in 0..<size {
                let weight: Float = expf((x * x + y * y) * expScale);
                weights[j * size + i] = weight
                weightSum += weight
                x += delta
            }
            y += delta
        }
        
        let weightScale: Float = 1.0 / weightSum
        for j in 0..<size {
            for i in 0..<size {
                weights[j * size + i] *= weightScale
            }
        }
        
        let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .r32Float, width: size, height: size, mipmapped: false)
        textureDescriptor.usage = .shaderRead
        self.blurWeightTexture = self.context.device.makeTexture(descriptor: textureDescriptor)
        
        let region = MTLRegionMake2D(0, 0, size, size)
        self.blurWeightTexture?.replace(region: region, mipmapLevel: 0, withBytes: weights, bytesPerRow: MemoryLayout<Float>.size * size)
        
        weights.deallocate()
    }
        
    
    override func configureArgumentTable(commandEncoder: MTLComputeCommandEncoder) {
        if self.blurWeightTexture == nil {
            generateBlurWeightTexture()
        }
        
        commandEncoder.setTexture(self.blurWeightTexture!, index: 2)
    }
    
    override func setValue(_ value: Float) {
        radius = value
    }
}
