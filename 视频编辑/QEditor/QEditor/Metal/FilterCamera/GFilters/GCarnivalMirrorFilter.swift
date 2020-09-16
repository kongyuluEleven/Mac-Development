//
//  GDivideFilter.swift
//  MetalImageFilter
//
//  Created by LEE CHUL HYUN on 4/17/19.
//  Copyright © 2019 LEE CHUL HYUN. All rights reserved.
//

import Foundation
import Metal

struct CarnivalMirrorUniforms {
    var wavelength: Int32
    var amount: Int32
}

class GCarnivalMirrorFilter: GImageFilter {

    var _wavelength: Int32 = 1
    var wavelength: Int32 {
        get {
            return _wavelength
        }
        set {
            self.isDirty = true
            _wavelength = newValue
        }
    }
    
    var uniforms: UnsafeMutablePointer<CarnivalMirrorUniforms>
    
    override init?(context: GContext, filterType: GImageFilterType) {
        
        guard let buffer = context.device.makeBuffer(length: MemoryLayout<CarnivalMirrorUniforms>.size, options: [MTLResourceOptions.init(rawValue: 0)]) else { return nil }
        uniforms = UnsafeMutableRawPointer(buffer.contents()).bindMemory(to:CarnivalMirrorUniforms.self, capacity:1)
        super.init(functionName: "carnivalMirror", context: context, filterType: filterType)
        uniformBuffer = buffer
    }
    
    override func configureArgumentTable(commandEncoder: MTLComputeCommandEncoder) {
        
        uniforms[0].wavelength = wavelength
        uniforms[0].amount = 25
        commandEncoder.setBuffer(self.uniformBuffer, offset: 0, index: 0)
    }
    
    override func setValue(_ value: Float) {
        wavelength = Int32(value)
    }
}
