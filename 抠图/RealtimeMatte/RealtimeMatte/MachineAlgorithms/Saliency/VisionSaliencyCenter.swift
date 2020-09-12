//
//  VisionSaliencyCenter.swift
//  RealtimeMatte
//
//  Created by ws on 2020/9/11.
//  Copyright © 2020 ws. All rights reserved.
//

import Foundation
import CoreVideo
import CoreGraphics
import CoreImage

class VisionSaliencyCenter {
    
    let saliencies: [VisonSaliency]
    
    init() {
        let saliency1 = VisonSaliency(name: "saliency1")
        let saliency2 = VisonSaliency(name: "saliency2")
        let saliency3 = VisonSaliency(name: "saliency3")
        saliencies = [saliency1, saliency2, saliency3]
    }
    
    private func idleVisonSaliency() -> VisonSaliency? {
        return saliencies.filter { !$0.isBusy }.first
    }
    
    func process(pixelBuffer: CVPixelBuffer, orientation: CGImagePropertyOrientation) -> CIImage? {
        guard let saliency = idleVisonSaliency() else {
            return nil
        }
        return saliency.process(pixelBuffer: pixelBuffer, orientation: orientation)
    }

    func process(image: CGImage, orientation: CGImagePropertyOrientation) -> CIImage? {
        guard let saliency = idleVisonSaliency() else {
            return nil
        }
        return saliency.process(image: image, orientation: orientation)
    }
    
    func process(imageURL: URL) -> CIImage? {
        guard let saliency = idleVisonSaliency() else {
            return nil
        }
        return saliency.process(imageURL: imageURL)
    }
}
