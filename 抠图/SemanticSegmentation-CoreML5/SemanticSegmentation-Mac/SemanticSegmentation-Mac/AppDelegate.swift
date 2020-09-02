//
//  AppDelegate.swift
//  SemanticSegmentation-Mac
//
//  Created by ws on 22/08/2020.
//  Copyright © 2020 Wondershare. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
//    func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame: CVPixelBuffer?) {
//
//    }
    @IBOutlet weak var livePreviewBox: NSBox!
    @IBOutlet weak var window: NSWindow!
//    var videoCapture: VideoCapture!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        //setUpCamera()
        let aliveImageViewController = LiveImageViewController.init(nibName: NSNib.Name.init("LiveImageViewController"), bundle: nil)
        livePreviewBox.contentView = aliveImageViewController.view
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    
//    // MARK: - Setup camera
//    func setUpCamera() {
//        videoCapture = VideoCapture()
//        videoCapture.delegate = self
//        videoCapture.fps = 50
//        videoCapture.setUp(sessionPreset: .vga640x480) { success in
//
//            if success {
//                // UI에 비디오 미리보기 뷰 넣기
//                if let previewLayer = self.videoCapture.previewLayer {
//                    self.videoPreview.layer?.addSublayer(previewLayer)
//                    self.resizePreviewLayer()
//                }
//
//                // 초기설정이 끝나면 라이브 비디오를 시작할 수 있음
//                self.videoCapture.start()
//            }
//        }
//    }
//
//    func resizePreviewLayer() {
//        videoCapture.previewLayer?.frame = videoPreview.bounds
//    }

}

