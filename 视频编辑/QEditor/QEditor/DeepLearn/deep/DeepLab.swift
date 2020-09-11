//
//  DeepLab.swift
//  RealtimeMatte
//
//  Created by ws on 2020/9/9.
//  Copyright © 2020 ws. All rights reserved.
//

import Foundation
import Vision

class DeepLab: Task {
    
    // DeepLabV3(iOS12+), DeepLabV3FP16(iOS12+), DeepLabV3Int8LUT(iOS12+)

    
    /**
     11 Pro
     DeepLabV3        : 37 465 1
     DeepLabV3FP16    : 40 511 1
     DeepLabV3Int8LUT : 40 520 1
     
     XS
     DeepLabV3        : 135 409 2
     DeepLabV3FP16    : 136 403 2
     DeepLabV3Int8LUT : 135 412 2
     
     X
     DeepLabV3        : 177 531 1
     DeepLabV3FP16    : 177 530 1
     DeepLabV3Int8LUT : 177 517 1
     */
    fileprivate var request: VNCoreMLRequest?
    fileprivate var visionModel: VNCoreMLModel?
    
    override init(name: String) {
        super.init(name: name)
        setUpModel()
    }
    
    func setUpModel() {
        
        if #available(iOS 12, *) {
            let segmentationModel = DeepLabV3Int8LUT()
            if let visionModel = try? VNCoreMLModel(for: segmentationModel.model) {
                self.visionModel = visionModel
                request = VNCoreMLRequest(model: visionModel)
                request?.imageCropAndScaleOption = .scaleFill
            } else {
                fatalError()
            }
        }

    }
    
    func predict(imageURL: URL) -> CVPixelBuffer? {
        
        guard !isBusy else { return nil }
        transitToBusy(true)
        defer {
            transitToBusy(false)
        }
        
        let handler = VNImageRequestHandler(url: imageURL, options: [:])
        return perform(handler: handler)
    }
    
    
    func predict(with pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        
        guard !isBusy else { return nil }
        transitToBusy(true)
        defer {
            transitToBusy(false)
        }
        let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
        return perform(handler: handler)
    }
    
    private func perform(handler: VNImageRequestHandler) -> CVPixelBuffer? {
        guard let request = request else {
            return nil
        }
        
        try? handler.perform([request])
        guard let observations = request.results as? [VNCoreMLFeatureValueObservation],
            let segmentationmap = observations.first?.featureValue.multiArrayValue else {
                return nil
        }
        
        do {
            let segmentations = SegmentationResultMLMultiArray(mlMultiArray: segmentationmap)
            return try createMask(from: segmentations)
        } catch {
            print(error)
            return nil
        }
    }
    
    private func createMask(from segmentations: SegmentationResultMLMultiArray) throws -> CVPixelBuffer {
        let width = segmentations.segmentationmapWidthSize
        let height = segmentations.segmentationmapHeightSize
        
        let pixelBuffer = try CVPixelBuffer.make(width: width, height: height, pixelFormat: kCVPixelFormatType_32BGRA)
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        defer {
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        }
        
        let classBaseAddress = segmentations.mlMultiArray.dataPointer.bindMemory(to: Int32.self, capacity: segmentations.mlMultiArray.count)
        let bufferBaseAddress: UnsafeMutablePointer<UInt8> = CVPixelBufferGetBaseAddress(pixelBuffer)!.assumingMemoryBound(to: UInt8.self)
        
        let bufferWidth = CVPixelBufferGetWidth(pixelBuffer)
        let bufferHeight = CVPixelBufferGetHeight(pixelBuffer)
        let bytesPerRow = CVPixelBufferGetBytesPerRow(pixelBuffer)
        let bytesPerPixel: Int = 4
        
        for row in 0..<bufferHeight {
            // 每一行的像素个数, 并不一定等于 with * bytesPerPixel(4)
            let rowBaseAddress = bufferBaseAddress.advanced(by: row * bytesPerRow)
            for col in 0..<bufferWidth {
                let classValue = classBaseAddress[row * width + col]
                let colorComponent: UInt8 = classValue == 15 ? 255 : 0
                let pixel = rowBaseAddress.advanced(by: col * bytesPerPixel)
                pixel[0] = colorComponent
                pixel[1] = colorComponent
                pixel[2] = colorComponent
                pixel[3] = 255
            }
        }
        
        return pixelBuffer
    }
}
