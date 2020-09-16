//
//  GRotationFilter.swift
//  imageprocessing02
//
//  Created by C.H Lee on 13/05/2018.
//  Copyright © 2018 LEE CHUL HYUN. All rights reserved.
//

import Foundation
import Metal

struct RotationUniforms {
    var width: Float
    var height: Float
    var factor: Float
}

class GRotationFilter: GImageFilter {

    var _factor: Float = 0
    var factor: Float {
        get {
            return _factor
        }
        set {
            self.isDirty = true
            _factor = newValue
        }
    }
    
    var uniforms: UnsafeMutablePointer<RotationUniforms>

    override init?(context: GContext, filterType: GImageFilterType) {
        
        guard let buffer = context.device.makeBuffer(length: MemoryLayout<RotationUniforms>.size, options: [MTLResourceOptions.init(rawValue: 0)]) else { return nil }
        uniforms = UnsafeMutableRawPointer(buffer.contents()).bindMemory(to:RotationUniforms.self, capacity:1)
        super.init(functionName: "rotation_around_center", context: context, filterType: filterType)
        uniformBuffer = buffer
    }
    
    override func configureArgumentTable(commandEncoder: MTLComputeCommandEncoder) {
        
        uniforms[0].width = Float(self.provider0.texture!.width)
        uniforms[0].height = Float(self.provider0.texture!.height)
        uniforms[0].factor = _factor
        commandEncoder.setBuffer(self.uniformBuffer, offset: 0, index: 0)
    }
    
    override func setValue(_ value: Float) {
        factor = value
    }
}
