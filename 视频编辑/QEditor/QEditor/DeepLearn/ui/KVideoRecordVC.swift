//
//  KVideoRecordVC.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/12.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import MetalPetal
import AVKit

class KVideoRecordVC: UIViewController {

    @IBOutlet weak var btnSwitchCamera: UIButton!
    @IBOutlet weak var btnRecord: KRecordButton!
    @IBOutlet weak var renderView: MTIImageView!
    let context = try! MTIContext(device: MTLCreateSystemDefaultDevice()!)
    
    private let folderName = "videos"
    
    private var camera: Camera?
    private let videoQueue = DispatchQueue(label: "com.metalpetal.MetalPetalDemo.videoCallback")
    
    private var recorder: MovieRecorder?
    private var isRecording = false
    
    private var pixelBufferPool: MTICVPixelBufferPool?
    private var currentVideoURL: URL?
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
        
        self.view.bringSubviewToFront(btnRecord)
        self.view.bringSubviewToFront(btnSwitchCamera)
        btnRecord.setTitle("长按录像", for: .normal)

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
    
    @IBAction func btnRecordTouchDown(_ sender: Any) {
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

    @IBAction func btnRecordTouchUp(_ sender: Any) {
        self.recorder?.finishRecording()
    }
    

    private func recordingStopped() {
        self.recorder = nil
        self.isRecording = false
    }
    
    private func showPlayerViewController(url: URL) {
        let vc = KMedaiFileMattingVC()
        navigationController?.pushViewController(vc, animated: true)
        vc.videoAsset = AVURLAsset(url: url)
    }
}

//MARK: - 视频帧输出

extension KVideoRecordVC: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let formatDescription = CMSampleBufferGetFormatDescription(sampleBuffer), CMFormatDescriptionGetMediaType(formatDescription) == kCMMediaType_Video, let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        var outputSampleBuffer = sampleBuffer
        let inputImage = MTIImage(cvPixelBuffer: pixelBuffer, alphaType: .alphaIsOne)
        let outputImage = inputImage
        
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



extension KVideoRecordVC: MovieRecorderDelegate {
    
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
