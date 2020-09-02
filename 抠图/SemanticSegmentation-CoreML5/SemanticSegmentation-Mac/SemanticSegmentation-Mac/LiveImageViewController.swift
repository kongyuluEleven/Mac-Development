//
//  LiveImageViewController.swift
//  SemanticSegmentation-Mac
//
//  Created by ws on 22/08/2020.
//  Copyright © 2020 Wondershare. All rights reserved.
//

import Cocoa
import Vision

class LiveImageViewController: NSViewController {

        // MARK: - UI Properties
        @IBOutlet weak var videoPreview: NSView!
        @IBOutlet weak var drawingView: DrawingSegmentationView!
        
        @IBOutlet weak var inferenceLabel: NSTextField!
        @IBOutlet weak var etimeLabel: NSTextField!
        @IBOutlet weak var fpsLabel: NSTextField!
        
        // MARK: - AV Properties
        var videoCapture: VideoCapture!
        
        // MARK - Core ML model
        // DeepLabV3(iOS12+), DeepLabV3FP16(iOS12+), DeepLabV3Int8LUT(iOS12+)
        let segmentationModel = DeepLabV3Int8LUT()

        
    //    11 Pro
    //    DeepLabV3        : 37 465 1
    //    DeepLabV3FP16    : 40 511 1
    //    DeepLabV3Int8LUT : 40 520 1
    //
    //    XS
    //    DeepLabV3        : 135 409 2
    //    DeepLabV3FP16    : 136 403 2
    //    DeepLabV3Int8LUT : 135 412 2
    //
    //    X
    //    DeepLabV3        : 177 531 1
    //    DeepLabV3FP16    : 177 530 1
    //    DeepLabV3Int8LUT : 177 517 1
        
        // MARK: - Vision Properties
        var request: VNCoreMLRequest?
        var visionModel: VNCoreMLModel?
        
        var isInferencing = false
        
        // MARK: - Performance Measurement Property
        private let 👨‍🔧 = 📏()
        
        let maf1 = MovingAverageFilter()
        let maf2 = MovingAverageFilter()
        let maf3 = MovingAverageFilter()
        
        // MARK: - View Controller Life Cycle
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // setup ml model
            setUpModel()
            
            // setup camera
            setUpCamera()
            
            // setup delegate for performance measurement
            👨‍🔧.delegate = self
        }
        
//        override func didReceiveMemoryWarning() {
//            super.didReceiveMemoryWarning()
//            // Dispose of any resources that can be recreated.
//        }
//        
//        override func viewWillAppear(_ animated: Bool) {
//            super.viewWillAppear(animated)
//            self.videoCapture.start()
//        }
//        
//        override func viewWillDisappear(_ animated: Bool) {
//            super.viewWillDisappear(animated)
//            self.videoCapture.stop()
//        }
        
        // MARK: - Setup Core ML
        func setUpModel() {
            if let visionModel = try? VNCoreMLModel(for: segmentationModel.model) {
                self.visionModel = visionModel
                request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
                request?.imageCropAndScaleOption = .scaleFill
            } else {
                fatalError()
            }
        }
        
        // MARK: - Setup camera
        func setUpCamera() {
            videoCapture = VideoCapture()
            videoCapture.delegate = self
            videoCapture.fps = 50
            videoCapture.setUp(sessionPreset: .vga640x480) { success in
                
                if success {
                    // UI에 비디오 미리보기 뷰 넣기
                    if let previewLayer = self.videoCapture.previewLayer {
                        self.videoPreview.layer?.addSublayer(previewLayer)
                        self.resizePreviewLayer()
                    }
                    
                    // 초기설정이 끝나면 라이브 비디오를 시작할 수 있음
                    self.videoCapture.start()
                }
            }
        }
        
//        override func viewDidLayoutSubviews() {
//            super.viewDidLayoutSubviews()
//            resizePreviewLayer()
//        }
        
        func resizePreviewLayer() {
            videoCapture.previewLayer?.frame = videoPreview.bounds
        }
    }

    // MARK: - VideoCaptureDelegate
    extension LiveImageViewController: VideoCaptureDelegate {
        func videoCapture(_ capture: VideoCapture, didCaptureVideoFrame pixelBuffer: CVPixelBuffer?/*, timestamp: CMTime*/) {
            
            // the captured image from camera is contained on pixelBuffer
            if let pixelBuffer = pixelBuffer, !isInferencing {
                isInferencing = true
                
                // start of measure
                self.👨‍🔧.🎬👏()
                
                // predict!
                predict(with: pixelBuffer)
            }
        }
    }

    // MARK: - Inference
    extension LiveImageViewController {
        // prediction
        func predict(with pixelBuffer: CVPixelBuffer) {
            guard let request = request else { fatalError() }
            
            // vision framework configures the input size of image following our model's input configuration automatically
            let handler = VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:])
            try? handler.perform([request])
        }
        
        // post-processing
        func visionRequestDidComplete(request: VNRequest, error: Error?) {
            self.👨‍🔧.🏷(with: "endInference")
            
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
                let segmentationmap = observations.first?.featureValue.multiArrayValue {
                
                let segmentationResultMLMultiArray = SegmentationResultMLMultiArray(mlMultiArray: segmentationmap)
                DispatchQueue.main.async { [weak self] in
                    // update result
                    self?.drawingView.segmentationmap = segmentationResultMLMultiArray
                    
                    // end of measure
                    self?.👨‍🔧.🎬🤚()
                    self?.isInferencing = false
                }
            } else {
                // end of measure
                self.👨‍🔧.🎬🤚()
                isInferencing = false
            }
        }
    }

    // MARK: - 📏(Performance Measurement) Delegate
    extension LiveImageViewController: 📏Delegate {
        func updateMeasure(inferenceTime: Double, executionTime: Double, fps: Int) {
            self.maf1.append(element: Int(inferenceTime*1000.0))
            self.maf2.append(element: Int(executionTime*1000.0))
            self.maf3.append(element: fps)
            
            self.inferenceLabel.stringValue = "inference: \(self.maf1.averageValue) ms"
            self.etimeLabel.stringValue = "execution: \(self.maf2.averageValue) ms"
            self.fpsLabel.stringValue = "fps: \(self.maf3.averageValue)"
        }
    }

    class MovingAverageFilter {
        private var arr: [Int] = []
        private let maxCount = 10
        
        public func append(element: Int) {
            arr.append(element)
            if arr.count > maxCount {
                arr.removeFirst()
            }
        }
        
        public var averageValue: Int {
            guard !arr.isEmpty else { return 0 }
            let sum = arr.reduce(0) { $0 + $1 }
            return Int(Double(sum) / Double(arr.count))
        }
    }
