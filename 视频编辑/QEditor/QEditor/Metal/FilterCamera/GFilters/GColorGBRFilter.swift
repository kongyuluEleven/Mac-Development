//
//  GColorGBRFilter.swift
//  MetalImageFilter
//
//  Created by LEE CHUL HYUN on 4/10/19.
//  Copyright © 2019 LEE CHUL HYUN. All rights reserved.
//

import Foundation
import Metal
import simd

struct RGBUniforms {
    var rotation: matrix_float4x4
}

class GColorGBRFilter: GImageFilter {

    var _rotation: Float = 0
    var rotation: Float {
        get {
            return _rotation
        }
        set {
            self.isDirty = true
            _rotation = newValue
        }
    }
    
    var uniforms: UnsafeMutablePointer<RGBUniforms>

    override init?(context: GContext, filterType: GImageFilterType) {
        
        guard let buffer = context.device.makeBuffer(length: MemoryLayout<RGBUniforms>.size, options: [MTLResourceOptions.init(rawValue: 0)]) else { return nil }
        uniforms = UnsafeMutableRawPointer(buffer.contents()).bindMemory(to:RGBUniforms.self, capacity:1)
        super.init(functionName: "gbr", context: context, filterType: filterType )
        uniformBuffer = buffer
    }
    
    func radians_from_degrees(_ degrees: Float) -> Float {
        return (degrees / 180) * .pi
    }
    
    override func configureArgumentTable(commandEncoder: MTLComputeCommandEncoder) {
        
        let rotationAxis = float3(1, 1, 1)
        uniforms[0].rotation = matrix4x4_rotation(radians: radians_from_degrees(rotation), axis: rotationAxis)
        commandEncoder.setBuffer(self.uniformBuffer, offset: 0, index: 0)
    }
    
    override func setValue(_ value: Float) {
        rotation = value
    }
    
    func matrix4x4_rotation(radians: Float, axis: float3) -> matrix_float4x4 {
        let unitAxis = normalize(axis)
        let ct = cosf(radians)
        let st = sinf(radians)
        let ci = 1 - ct
        let x = unitAxis.x, y = unitAxis.y, z = unitAxis.z
        return matrix_float4x4.init(columns:(vector_float4(    ct + x * x * ci, y * x * ci + z * st, z * x * ci - y * st, 0),
                                             vector_float4(x * y * ci - z * st,     ct + y * y * ci, z * y * ci + x * st, 0),
                                             vector_float4(x * z * ci + y * st, y * z * ci - x * st,     ct + z * z * ci, 0),
                                             vector_float4(                  0,                   0,                   0, 1)))
    }
}
