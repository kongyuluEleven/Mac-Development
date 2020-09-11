/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This code provides the Vision routines for saliency analysis on an image or buffer.
*/

import Foundation
import Vision
import CoreVideo
import CoreImage
import UIKit

class VisonSaliency: Task {
    
    func process(pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) -> CIImage? {
        guard !isBusy else { return nil }
        transitToBusy(true)
        defer {
            transitToBusy(false)
        }
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, orientation: orientation, options: [:])
        return perform(requestHandler)
    }

    func process(image: CGImage, orientation: CGImagePropertyOrientation) -> CIImage? {
        guard !isBusy else { return nil }
        transitToBusy(true)
        defer {
            transitToBusy(false)
        }
        let requestHandler = VNImageRequestHandler(cgImage: image, orientation: orientation, options: [:])
        return perform(requestHandler)
    }
    
    func process(imageURL: URL) -> CIImage? {
        guard !isBusy else { return nil }
        transitToBusy(true)
        defer {
            transitToBusy(false)
        }
        
        let requestHandler = VNImageRequestHandler(url: imageURL, options: [:])
        return perform(requestHandler)
    }
    
    private func perform(_ requestHandler: VNImageRequestHandler) -> CIImage? {
        
        if #available(iOS 13, *) {
            //        var start = CFAbsoluteTimeGetCurrent()
            let request: VNRequest = VNGenerateObjectnessBasedSaliencyImageRequest()
            try? requestHandler.perform([request])
            
            //        print("VisonSaliency predict one frame time cost: \(CFAbsoluteTimeGetCurrent() - start)")
            guard let observation = request.results?.first as? VNSaliencyImageObservation else {
                return nil
            }
            let srcBuffer = observation.pixelBuffer
            let ciImage = CIImage(cvPixelBuffer: srcBuffer)
            let vector = CIVector(x: 0, y: 0, z: 0, w: 1)
            let saliencyImage = ciImage.applyingFilter("CIColorMatrix", parameters: ["inputBVector": vector])
            return saliencyImage
        }

        return nil
        
//        let width = CVPixelBufferGetWidth(srcBuffer)
//        let height = CVPixelBufferGetHeight(srcBuffer)
//        let srcBytesPerRow = CVPixelBufferGetBytesPerRow(srcBuffer)
//
//        do {
//            let destBuffer = try CVPixelBuffer.make(width: width, height: height, pixelFormat: kCVPixelFormatType_32BGRA)
//            CVPixelBufferLockBaseAddress(destBuffer, CVPixelBufferLockFlags(rawValue: 0))
//            CVPixelBufferLockBaseAddress(srcBuffer, CVPixelBufferLockFlags(rawValue: 0))
//            defer {
//                CVPixelBufferUnlockBaseAddress(destBuffer, CVPixelBufferLockFlags(rawValue: 0))
//                CVPixelBufferUnlockBaseAddress(srcBuffer, CVPixelBufferLockFlags(rawValue: 0))
//            }
//
//            let destBytesPerRow = CVPixelBufferGetBytesPerRow(destBuffer)
//            let bytesPerPixel: Int = 4
//
//            let srcBaseAddress: UnsafeMutablePointer<Float32> = CVPixelBufferGetBaseAddress(srcBuffer)!.assumingMemoryBound(to: Float32.self)
//            let destBaseAddress: UnsafeMutablePointer<UInt8> = CVPixelBufferGetBaseAddress(destBuffer)!.assumingMemoryBound(to: UInt8.self)
//
//
//
//            for row in 0..<height {
//                // 每一行的像素个数, 并不一定等于 with * bytesPerPixel(4)
//                let srcAddress = srcBaseAddress.advanced(by: row * srcBytesPerRow)
//                let desAddress = destBaseAddress.advanced(by: row * destBytesPerRow)
//                for col in 0..<width {
//                    let maskPixel = srcAddress.advanced(by: col)[0]
//                    let value = UInt8(min(1.0, max(0.0, maskPixel)) * 255)
//                    print(value)
//                    let destPixel = desAddress.advanced(by: col * bytesPerPixel)
//                    destPixel[0] = value
//                    destPixel[1] = value
//                    destPixel[2] = value
//                    destPixel[3] = 255
//                }
//            }
//
//            return destBuffer
//        } catch {
//            return nil
//        }
    }
    
}


