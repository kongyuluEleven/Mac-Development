//
//  GImageFilter.swift
//  imageprocessing01
//
//  Created by chlee on 11/05/2018.
//  Copyright © 2018 LEE CHUL HYUN. All rights reserved.
//

import Foundation
import Metal
import MetalPerformanceShaders
import UIKit

protocol GFilterValueSetter {
    
    func setValue(_ value: Float)
}

class GImageFilter: GTextureProvider, GTextureConsumer, GFilterValueSetter {
    
    var context: GContext
    var uniformBuffer: MTLBuffer?
    var pipeline: MTLComputePipelineState!
    var isDirty: Bool = true
    var kernelFunction: MTLFunction?
    var texture: MTLTexture? {
        if self.isDirty {
            self.applyFilter()
        }
        return self.internalTexture
    }
    
    var image: UIImage? {
        
        guard let texture = self.texture else {
            return nil
        }
        let mipmapLevel = 0
        let divider = pow(2, Double(mipmapLevel))
        let width = Int(max(1, floor(Double(texture.width) / divider)))
        let height = Int(max(1, floor(Double(texture.height) / divider)))
        GZLogFunc(width)
        GZLogFunc(height)
        
        let rawData = UnsafeMutableRawPointer.allocate(byteCount: width * height * 4, alignment: 1)// UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        texture.getBytes(rawData, bytesPerRow: bytesPerRow, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: mipmapLevel)
        
        let textureDescriptor: MTLTextureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .rgba8Unorm, width: width, height: height, mipmapped: false)
        textureDescriptor.usage = .shaderRead
        
        let t = context.device.makeTexture(descriptor: textureDescriptor)
        let region = MTLRegionMake2D(0, 0, width, height)
        t?.replace(region: region, mipmapLevel: 0, withBytes: rawData, bytesPerRow: bytesPerRow)
        rawData.deallocate()
        
        return UIImage(texture: t!)
    }
    var provider0: GTextureProvider!
    var provider1: GTextureProvider!
    var internalTexture: MTLTexture?
    var internalTexture2: MTLTexture?
    let filterType: GImageFilterType

    init(functionName: String, context: GContext, filterType: GImageFilterType) {
        self.context = context
        self.filterType = filterType
        self.kernelFunction = self.context.library.makeFunction(name: functionName)
        self.pipeline = try! self.context.device.makeComputePipelineState(function: self.kernelFunction!)
    }

    init?(context: GContext, filterType: GImageFilterType) {
        self.context = context
        self.filterType = filterType
    }

    func configureArgumentTable(commandEncoder: MTLComputeCommandEncoder) {
    }
    
    func setValue(_ value: Float) {
    }
    
    func applyFilter() {
        
        guard var inputTexture = self.provider0.texture else {
            return
        }
//        GZLogFunc(inputTexture)
        if self.filterType.inPlaceTexture == false {
            if self.internalTexture == nil ||
                self.internalTexture!.width != inputTexture.width ||
                self.internalTexture!.height != inputTexture.height {
                GZLogFunc("pixel format : \(inputTexture.pixelFormat.rawValue)")
                GZLogFunc("width : \(inputTexture.width)")
                GZLogFunc("height : \(inputTexture.height)")
                let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: inputTexture.pixelFormat, width: inputTexture.width, height: inputTexture.height, mipmapped: self.filterType.outputMipmapped)
                textureDescriptor.usage = [.shaderRead, .shaderWrite, .pixelFormatView]
                self.internalTexture = self.context.device.makeTexture(descriptor: textureDescriptor)
                
//                let width = inputTexture.width
//                let height = inputTexture.height
//                let rawData = UnsafeMutableRawPointer.allocate(byteCount: width * height * 4, alignment: 1)// UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * 4)
//                let bytesPerPixel = 4
//                let bytesPerRow = bytesPerPixel * width
//                inputTexture.getBytes(rawData, bytesPerRow: bytesPerRow, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
//                
//                let region = MTLRegionMake2D(0, 0, width, height)
//                internalTexture?.replace(region: region, mipmapLevel: 0, withBytes: rawData, bytesPerRow: bytesPerRow)
//                let aa = internalTexture
//                GZLogFunc(aa)
//                rawData.deallocate()

            }
        }
        else {
            internalTexture = inputTexture
        }
        
        if self.filterType.output2Required == true {
            if self.internalTexture2 == nil ||
                self.internalTexture2!.width != inputTexture.width ||
                self.internalTexture2!.height != inputTexture.height {
                GZLogFunc("pixel format : \(inputTexture.pixelFormat.rawValue)")
                GZLogFunc("width : \(inputTexture.width)")
                GZLogFunc("height : \(inputTexture.height)")
                let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: inputTexture.pixelFormat, width: inputTexture.width, height: inputTexture.height, mipmapped: self.filterType.outputMipmapped)
                textureDescriptor.usage = [.shaderRead, .shaderWrite, .pixelFormatView]
                self.internalTexture2 = self.context.device.makeTexture(descriptor: textureDescriptor)
            }
        }
        
        if let commandBuffer = self.context.commandQueue.makeCommandBuffer(), let _ = internalTexture {
            
            let output: MTLTexture = internalTexture!
            let output2: MTLTexture? = internalTexture2

            if case GImageFilterType.binaryImageKernel = filterType {
                if let input1 = self.provider1.texture {
                    GZLogFunc("\(inputTexture.width) x \(inputTexture.height)")
                    GZLogFunc("\(input1.width) x \(input1.height)")
                    encode(input0: inputTexture, input1: input1, finalOutput: output, commandBuffer: commandBuffer)
                }
            }
            else {
                encode(input: &inputTexture, tempOutput: output2, finalOutput: output, commandBuffer: commandBuffer)
            }

            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
            if self.filterType.inPlaceTexture == true {
                GZLogFunc("\(inputTexture.width) x \(inputTexture.height)")
                internalTexture = inputTexture
            }
//            GZLogFunc()
        }
//        GZLogFunc()
    }

    func encode(input0: MTLTexture, input1: MTLTexture, finalOutput: MTLTexture, commandBuffer: MTLCommandBuffer) {
        GZLogFunc("threadExecutionWidth: \(pipeline.threadExecutionWidth)")
        GZLogFunc("maxTotalThreadsPerThreadgroup: \(pipeline.maxTotalThreadsPerThreadgroup)")
        
        let threadgroupCounts = MTLSizeMake(pipeline.threadExecutionWidth, pipeline.maxTotalThreadsPerThreadgroup/pipeline.threadExecutionWidth, 1)
        //        let threadgroupCounts = MTLSizeMake(8, 8, 1)
        var width: Int = input0.width / threadgroupCounts.width
        var height: Int = input0.height / threadgroupCounts.height
        if input0.width % threadgroupCounts.width != 0 {
            width += 1
        }
        if input0.height % threadgroupCounts.height != 0 {
            height += 1
        }
        let threadgroups = MTLSizeMake(width, height, 1)
        

        let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        commandEncoder?.setComputePipelineState(self.pipeline)
        commandEncoder?.setTexture(input0, index: 0)
        commandEncoder?.setTexture(input1, index: 1)
        commandEncoder?.setTexture(finalOutput, index: 2)
        GZLogFunc("\(input0.width), \(input0.height)")
        GZLogFunc("\(finalOutput.width), \(finalOutput.height)")
        self.configureArgumentTable(commandEncoder: commandEncoder!)
        commandEncoder?.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupCounts)
        commandEncoder?.endEncoding()
    }

    func encode(input: inout MTLTexture, tempOutput: MTLTexture?, finalOutput: MTLTexture, commandBuffer: MTLCommandBuffer) {
//        GZLogFunc("threadExecutionWidth: \(pipeline.threadExecutionWidth)")
//        GZLogFunc("maxTotalThreadsPerThreadgroup: \(pipeline.maxTotalThreadsPerThreadgroup)")
        
        let threadgroupCounts = MTLSizeMake(pipeline.threadExecutionWidth, pipeline.maxTotalThreadsPerThreadgroup/pipeline.threadExecutionWidth, 1)
        //        let threadgroupCounts = MTLSizeMake(8, 8, 1)
        
        var width: Int = input.width / threadgroupCounts.width
        var height: Int = input.height / threadgroupCounts.height
        if input.width % threadgroupCounts.width != 0 {
            width += 1
        }
        if input.height % threadgroupCounts.height != 0 {
            height += 1
        }
        let threadgroups = MTLSizeMake(width, height, 1)
        
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()
        commandEncoder?.setComputePipelineState(self.pipeline)
        commandEncoder?.setTexture(input, index: 0)
        commandEncoder?.setTexture(finalOutput, index: 1)
//        GZLogFunc("\(input.width), \(input.height)")
//        GZLogFunc("\(finalOutput.width), \(finalOutput.height)")
        self.configureArgumentTable(commandEncoder: commandEncoder!)
        //        if #available(iOS 11.0, *) {
        //            commandEncoder?.dispatchThreads(MTLSizeMake(inputTexture.width, inputTexture.height, 1), threadsPerThreadgroup: threadgroupCounts)
        //        } else {
        commandEncoder?.dispatchThreadgroups(threadgroups, threadsPerThreadgroup: threadgroupCounts)
        //        }
        commandEncoder?.endEncoding()
    }
    
}
