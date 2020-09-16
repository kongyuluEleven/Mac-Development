//
//  GDivideFilter.swift
//  MetalImageFilter
//
//  Created by LEE CHUL HYUN on 4/17/19.
//  Copyright © 2019 LEE CHUL HYUN. All rights reserved.
//

import Foundation
import Metal

struct DivideUniforms {
    var divider: Int32
}

class GDivideFilter: GImageFilter {

    var _divider: Int32 = 1
    var divider: Int32 {
        get {
            return _divider
        }
        set {
            self.isDirty = true
            _divider = newValue
        }
    }
    
    var uniforms: UnsafeMutablePointer<DivideUniforms>
    
    override init?(context: GContext, filterType: GImageFilterType) {
        
        guard let buffer = context.device.makeBuffer(length: MemoryLayout<PixellationUniforms>.size, options: [MTLResourceOptions.init(rawValue: 0)]) else { return nil }
        uniforms = UnsafeMutableRawPointer(buffer.contents()).bindMemory(to:DivideUniforms.self, capacity:1)
        super.init(functionName: "divide", context: context, filterType: filterType)
        uniformBuffer = buffer
    }
    
    override func configureArgumentTable(commandEncoder: MTLComputeCommandEncoder) {
        
        uniforms[0].divider = divider
        commandEncoder.setBuffer(self.uniformBuffer, offset: 0, index: 0)
    }
    
    override func setValue(_ value: Float) {
        divider = Int32(value)
    }
}
