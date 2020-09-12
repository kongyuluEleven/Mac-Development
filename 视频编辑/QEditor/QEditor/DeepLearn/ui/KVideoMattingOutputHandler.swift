//
//  KVideoMattingOutputHandler.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/12.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import AVFoundation
import MetalPetal

/// 用来逐帧扣图并替换背景
public class KVideoMattingOutputHandler {
    
    enum MatteAlgorithm: Int {
        case saliency
        case segment
    }
    
    public enum Error: Swift.Error {
        case cannotGenerateOutputPixelBuffer
        case noSourceFrame
    }
    
    public struct Request {
        /// The track's preferred transform is applied.
        public let sourceImages: [CMPersistentTrackID: MTIImage]
        public let compositionTime: CMTime
        public let renderSize: CGSize
        
        public var anySourceImage: MTIImage {
            return sourceImages.first!.value
        }
    }
    
    private let tracks: [AVAssetTrack]
    private let context: MTIContext
    private let queue: DispatchQueue
    private let deepLab = DeepLab(name: "DeepLab")
    private let saliency = VisonSaliency(name: "VisonSaliency")
    
    /// 抠图滤镜
    private let mattingFilter = MTIBlendWithMaskFilter()
    
    var matteAlgorithm: MatteAlgorithm = .segment
    
    func setBackgroundImage(_ backgroundImage: MTIImage?) {
        guard let image = backgroundImage else { return }
        mattingFilter.inputBackgroundImage = image
    }
    
    func setInputPixelBuffer(_ inputBuffer: CVPixelBuffer) {
        let inputImage = MTIImage(cvPixelBuffer: inputBuffer, alphaType: .alphaIsOne)
        mattingFilter.inputImage = inputImage
        
        var image: MTIImage? = nil
        
        switch matteAlgorithm {
        case .segment:
            if let mask = deepLab.predict(with: inputBuffer) {
                image = MTIImage(cvPixelBuffer: mask, alphaType: .alphaIsOne)
            }
        case .saliency:
            if let mask = saliency.process(pixelBuffer: inputBuffer, orientation: .up) {
                image = MTIImage(ciImage: mask, isOpaque: true)
            }
        }
        
        if let maskImage = image {
            mattingFilter.inputMask = MTIMask(content: maskImage, component: .red, mode: .normal)
        }
    }
    
    public init(context: MTIContext, tracks: [AVAssetTrack], queue: DispatchQueue = .main) {
        assert(tracks.count > 0)
        self.tracks = tracks
        self.context = context
        self.queue = queue
    }
    
    private let transformFilter = MTITransformFilter()
    
    private func makeTransformedSourceImage(from request: AVAsynchronousVideoCompositionRequest, track: AVAssetTrack) -> MTIImage? {
        guard let pixelBuffer = request.sourceFrame(byTrackID: track.trackID) else {
            return nil
        }
        
        setInputPixelBuffer(pixelBuffer)
  
        assert(request.renderContext.renderTransform.isIdentity == true)
        if track.preferredTransform.isIdentity {
            return mattingFilter.outputImage
        }
        transformFilter.inputImage = mattingFilter.outputImage
        var transform = track.preferredTransform
        transform.tx = 0
        transform.ty = 0
        transformFilter.transform = CATransform3DMakeAffineTransform(transform.inverted())
        transformFilter.viewport = transformFilter.minimumEnclosingViewport
        return transformFilter.outputImage
    }
    
    public func handle(request: AVAsynchronousVideoCompositionRequest) {
        let sourceFrames = self.tracks.reduce(into: [CMPersistentTrackID: MTIImage]()) { (frames, track) in
            if let image = self.makeTransformedSourceImage(from: request, track: track) {
                frames[track.trackID] = image
            }
        }
        if sourceFrames.count == 0 {
            self.queue.async {
                request.finish(with: Error.noSourceFrame)
            }
            return
        }
        if let pixelBuffer = request.renderContext.newPixelBuffer() {
            self.queue.async {
                do {
                    let mtiRequest = Request(sourceImages: sourceFrames, compositionTime: request.compositionTime, renderSize: request.renderContext.size)
                    try self.context.render(mtiRequest.anySourceImage, to: pixelBuffer)
                    request.finish(withComposedVideoFrame: pixelBuffer)
                } catch {
                    request.finish(with: error)
                }
            }
        } else {
            self.queue.async {
                request.finish(with: Error.cannotGenerateOutputPixelBuffer)
            }
        }
    }
}
