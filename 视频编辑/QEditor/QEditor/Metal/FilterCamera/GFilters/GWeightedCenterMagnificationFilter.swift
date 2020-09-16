//
//  GWeightedCenterMagnificationFilter.swift
//  imageprocessing02
//
//  Created by C.H Lee on 13/05/2018.
//  Copyright © 2018 LEE CHUL HYUN. All rights reserved.
//

import Foundation
import Metal

class GWeightedCenterMagnificationFilter: GImageFilter {

    var _radius: Float = 0
    var radius: Float {
        get {
            return _radius
        }
        set {
            self.isDirty = true
            _radius = newValue
        }
    }
    
    var uniforms: UnsafeMutablePointer<CenterMagnificationUniforms>

    override init?(context: GContext, filterType: GImageFilterType) {
        
        guard let buffer = context.device.makeBuffer(length: MemoryLayout<CenterMagnificationUniforms>.size, options: [MTLResourceOptions.init(rawValue: 0)]) else { return nil }
        uniforms = UnsafeMutableRawPointer(buffer.contents()).bindMemory(to:CenterMagnificationUniforms.self, capacity:1)
        super.init(functionName: "magnify_weighted_center", context: context, filterType: filterType)
        uniformBuffer = buffer
    }
    
    override func configureArgumentTable(commandEncoder: MTLComputeCommandEncoder) {
        
        uniforms[0].width = Float(self.provider0.texture!.width)
        uniforms[0].height = Float(self.provider0.texture!.height)
        uniforms[0].radius = radius;
        uniforms[0].minRadius = 0.5;
        commandEncoder.setBuffer(self.uniformBuffer, offset: 0, index: 0)
    }
    
    override func setValue(_ value: Float) {
        radius = value
    }
}
