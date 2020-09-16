//
//  GKuwaharaFilter.swift
//  MetalImageFilter
//
//  Created by LEE CHUL HYUN on 4/17/19.
//  Copyright © 2019 LEE CHUL HYUN. All rights reserved.
//

import Foundation
import Metal

struct KuwaharaUniforms {
    var radius: Int32
}

class GKuwaharaFilter: GImageFilter {

    var _radius: Int32 = 1
    var radius: Int32 {
        get {
            return _radius
        }
        set {
            self.isDirty = true
            _radius = newValue
        }
    }
    
    var uniforms: UnsafeMutablePointer<KuwaharaUniforms>
    
    override init?(context: GContext, filterType: GImageFilterType) {
        
        guard let buffer = context.device.makeBuffer(length: MemoryLayout<KuwaharaUniforms>.size, options: [MTLResourceOptions.init(rawValue: 0)]) else { return nil }
        uniforms = UnsafeMutableRawPointer(buffer.contents()).bindMemory(to:KuwaharaUniforms.self, capacity:1)
        super.init(functionName: "kuwahara", context: context, filterType: filterType)
        uniformBuffer = buffer
    }
    
    override func configureArgumentTable(commandEncoder: MTLComputeCommandEncoder) {
        
        uniforms[0].radius = radius
        commandEncoder.setBuffer(self.uniformBuffer, offset: 0, index: 0)
    }
    
    override func setValue(_ value: Float) {
        radius = Int32(value)
    }
}
