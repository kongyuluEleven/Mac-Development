//
//  CameraViewController.swift
//  RealtimeMatte
//
//  Created by ws on 2020/9/9.
//  Copyright © 2020 ws. All rights reserved.
//

import UIKit
import MetalPetal
import AVKit

class CameraViewController: RenderViewController {
    
    private let folderName = "videos"
    
    private var camera: Camera?
    private let videoQueue = DispatchQueue(label: "com.metalpetal.MetalPetalDemo.videoCallback")
    
    private var recorder: MovieRecorder?
    private var isRecording = false
    
    private var pixelBufferPool: MTICVPixelBufferPool?
    private var currentVideoURL: URL?
    private var isFilterEnabled = false
    private var isFrontCamera = true

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        let path = "\(NSTemporaryDirectory())/\(folderName)"
        let fileManager = FileManager()
        try? fileManager.removeItem(atPath: path)
        
        do {
            try fileManager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("\(error)")
        }
        
        camera = Camera(captureSessionPreset: .vga640x480, defaultCameraPosition: .front, configurator: .portraitFrontMirroredVideoOutput)
        try? camera?.enableVideoDataOutput(on: self.videoQueue, delegate: self)
        camera?.videoDataOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        camera?.startRunningCaptureSession()
    }
   
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camera?.stopRunningCaptureSession()
    }
    
    @IBAction func rotateCamera(_ sender: Any) {
        camera?.stopRunningCaptureSession()
        pixelBufferPool = nil
        
        if isFrontCamera {
            camera = Camera(captureSessionPreset: .medium, configurator: .portraitFrontMirroredVideoOutput)
        } else {
            camera = Camera(captureSessionPreset: .vga640x480, defaultCameraPosition: .front, configurator: .portraitFrontMirroredVideoOutput)
        }
        isFrontCamera = !isFrontCamera
        
        try? camera?.enableVideoDataOutput(on: self.videoQueue, delegate: self)
        camera?.videoDataOutput?.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
        camera?.startRunningCaptureSession()
    }

    func currentPixelBufferBool(for pixelBuffer: CVPixelBuffer) -> MTICVPixelBufferPool? {
        if pixelBufferPool != nil {
            return pixelBufferPool
        }
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        pixelBufferPool = try? MTICVPixelBufferPool(pixelBufferWidth: width,
                                                    pixelBufferHeight: height,
                                                    pixelFormatType: kCVPixelFormatType_32BGRA,
                                                    minimumBufferCount: 30)
        return pixelBufferPool
    }
    
    @IBAction func recordButtonTouchDown(_ sender: Any) {
        if isRecording {
            return
        }

        let url = URL(fileURLWithPath: "\(NSTemporaryDirectory())/\(folderName)/\(UUID().uuidString).mp4")
        self.currentVideoURL = url
        
        var configuration = MovieRecorder.Configuration()
        configuration.isAudioEnabled = false
        let recorder = MovieRecorder(url: url, configuration: configuration, delegate: self)
        self.recorder = recorder
        recorder.prepareToRecord()
        
        self.isRecording = true
    }
    
    @IBAction func recordButtonTouchUp(_ sender: Any) {
        self.recorder?.finishRecording()
    }
    
    @IBAction func filterSwitchValueChanged(_ sender: UISwitch) {
        self.isFilterEnabled = sender.isOn
    }

    private func recordingStopped() {
        self.recorder = nil
        self.isRecording = false
    }
    
    private func showPlayerViewController(url: URL) {
        let playerViewController = AVPlayerViewController()
        let player = AVPlayer(url: url)
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            player.play()
        }
    }
}

//MARK: - 视频帧输出

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer), CMFormatDescriptionGetMediaType(formatDescription) == kCMMediaType_Video, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        var outputSampleBuffer = sampleBuffer
        let inputImage = MTIImage(cvPixelBuffer: pixelBuffer, alphaType: .alphaIsOne)
        var outputImage = inputImage
        if self.isFilterEnabled {
            self.mattingFilter.inputImage = inputImage
            self.generateMask(from: pixelBuffer)
            if let image = self.mattingFilter.outputImage?.withCachePolicy(.persistent) {
                outputImage = image
            }
        }
        
        
        DispatchQueue.main.async {
            if self.isRecording {
                let bufferPool = self.currentPixelBufferBool(for: pixelBuffer)
                if let pixelBuffer = try? bufferPool?.makePixelBuffer(allocationThreshold: 30) {
                    do {
                        try self.context.render(outputImage, to: pixelBuffer)
                        if let smbf = SampleBufferUtilities.makeSampleBufferByReplacingImageBuffer(of: sampleBuffer, with: pixelBuffer) {
                            outputSampleBuffer = smbf
                        }
                    } catch {
                        print("\(error)")
                    }
                }
                self.recorder?.append(sampleBuffer: outputSampleBuffer)
            }
            self.renderView.image = outputImage
        }
    }
    
}



extension CameraViewController: MovieRecorderDelegate {
    
    func movieRecorderDidFinishPreparing(_ recorder: MovieRecorder) {
        
    }
    
    func movieRecorderDidCancelRecording(_ recorder: MovieRecorder) {
        recordingStopped()
    }
    
    func movieRecorder(_ recorder: MovieRecorder, didFailWithError error: Error) {
        recordingStopped()
    }
    
    func movieRecorderDidFinishRecording(_ recorder: MovieRecorder) {
        recordingStopped()
        if let url = self.currentVideoURL {
            showPlayerViewController(url: url)
        }
    }
    
    func movieRecorder(_ recorder: MovieRecorder, didUpdateWithTotalDuration totalDuration: TimeInterval) {
        print(totalDuration)
    }
}
