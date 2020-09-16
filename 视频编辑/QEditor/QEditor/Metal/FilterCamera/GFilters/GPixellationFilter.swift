//
//  GPixellationFilter.swift
//  MetalImageFilter
//
//  Created by LEE CHUL HYUN on 4/17/19.
//  Copyright © 2019 LEE CHUL HYUN. All rights reserved.
//

import Foundation
import Metal

struct PixellationUniforms {
    var width: Int32
    var height: Int32
}

class GPixellationFilter: GImageFilter {

    var _blockWidth: Int32 = 1
    var blockWidth: Int32 {
        get {
            return _blockWidth
        }
        set {
            self.isDirty = true
            _blockWidth = newValue
        }
    }
    
    var uniforms: UnsafeMutablePointer<PixellationUniforms>
    
    override init?(context: GContext, filterType: GImageFilterType) {
        
        guard let buffer = context.device.makeBuffer(length: MemoryLayout<PixellationUniforms>.size, options: [MTLResourceOptions.init(rawValue: 0)]) else { return nil }
        uniforms = UnsafeMutableRawPointer(buffer.contents()).bindMemory(to:PixellationUniforms.self, capacity:1)
        super.init(functionName: "pixellate", context: context, filterType: filterType)
        uniformBuffer = buffer
    }
    
    override func configureArgumentTable(commandEncoder: MTLComputeCommandEncoder) {
        
        uniforms[0].width = blockWidth
        uniforms[0].height = blockWidth
        commandEncoder.setBuffer(self.uniformBuffer, offset: 0, index: 0)
    }
    
    override func setValue(_ value: Float) {
        blockWidth = Int32(value)
    }
}
