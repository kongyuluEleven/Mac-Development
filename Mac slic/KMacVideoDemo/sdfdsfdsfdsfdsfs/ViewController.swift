//
//  ViewController.swift
//  sdfdsfdsfdsfdsfs
//
//  Created by ws on 10/09/2020.
//  Copyright © 2020 nenhall. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController {

    
    let captureSession = AVCaptureSession.init()
    public var videoDeviceInput: AVCaptureDeviceInput?
    public var audioDeviceInput: AVCaptureDeviceInput?
    public var videoDataOutput: AVCaptureVideoDataOutput?
    public var audioDataOutput: AVCaptureAudioDataOutput?
    public var encodeQueue = DispatchQueue.init(label: "com.nenhall.capture")
    @IBOutlet weak var preview: NSImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()


        configCaptureSession()

    }
    override func mouseUp(with event: NSEvent) {
        captureSession.startRunning()
    }
    
       /// 配置会话
        func configCaptureSession() {
            
            #if targetEnvironment(macCatalyst)
            do { // 视频输入
                if let device = AVCaptureDevice.default(for: .metadata) {
                    videoDeviceInput = try AVCaptureDeviceInput.init(device:device)
                    guard let vDeviceInput = videoDeviceInput else {
                        print("add Video Input failed!")
                        return
                    }
                    if captureSession.canAddInput(vDeviceInput) {
                        captureSession.addInput(vDeviceInput)
                    }
                } else {
                    print("AVCaptureDevice: failed")
                }
            } catch let error {
                print("AVCaptureDevice:",error)
            }
            
            #else
            do { // 视频输入
                if let device = AVCaptureDevice.default(for: .video) {
                    
                videoDeviceInput = try AVCaptureDeviceInput.init(device:device)
                guard let vDeviceInput = videoDeviceInput else {
                    print("add Video Input failed!")
                    return
                }
                if captureSession.canAddInput(vDeviceInput) {
                    captureSession.addInput(vDeviceInput)
                }
                    }

            } catch let error {
                print(error)
            }
            #endif

    //        do { // 音频输入
    //            let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
    //            if let ad = audioDevice {
    //                audioDeviceInput = try AVCaptureDeviceInput.init(device: ad)
    //            }
    //            guard let aDeviceInput = audioDeviceInput else {
    //                print("add Audio Input failed!")
    //                return
    //            }
    //            if captureSession.canAddInput(aDeviceInput) {
    //                captureSession.addInput(aDeviceInput)
    //            }
    //        } catch let error {
    //            print(error)
    //        }

            do { // 视频输出
                videoDataOutput = AVCaptureVideoDataOutput.init()
                guard let _videoDataOutput = videoDataOutput else {
                    print("AVCaptureVideoDataOutput.init() Failed")
                    return
                }
                _videoDataOutput.alwaysDiscardsLateVideoFrames = true
                var settings = [String : Any]()
                let formatValue = kCVPixelFormatType_32BGRA
                settings.updateValue(formatValue, forKey: String(kCVPixelBufferPixelFormatTypeKey))
                _videoDataOutput.videoSettings = settings
                _videoDataOutput.setSampleBufferDelegate(self, queue: encodeQueue)
                if captureSession.canAddOutput(_videoDataOutput) {
                    captureSession.addOutput(_videoDataOutput)
                }
            }
            
            do { // 音频输出
                audioDataOutput = AVCaptureAudioDataOutput.init()
                guard let _audioDataOutput = audioDataOutput else {
                    print("AVCaptureAudioDataOutput.init() Failed")
                    return
                }
                _audioDataOutput.setSampleBufferDelegate(self, queue: encodeQueue)
                if captureSession.canAddOutput(_audioDataOutput) {
                    captureSession.addOutput(_audioDataOutput)
                }
            }
            
            captureSession.sessionPreset = AVCaptureSession.Preset.hd1280x720
            
            
            let  previewLayer = AVCaptureVideoPreviewLayer.init(session: captureSession)
            
            previewLayer.session = captureSession
            previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            previewLayer.frame = preview.bounds
            preview.wantsLayer = true
            preview.layer?.addSublayer(previewLayer)
        }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate , AVCaptureAudioDataOutputSampleBufferDelegate {
    
}
