//
//  KGPUImageCameraController.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/14.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

import GPUImage

class KGPUImageCameraController: UIViewController {

//    @IBOutlet weak var effectViewTopCons: NSLayoutConstraint!
//
//    @IBOutlet weak var bilateraSlider: UISlider!
//    @IBOutlet weak var exposureSlider: UISlider!
//    @IBOutlet weak var brightnessSlider: UISlider!
//    @IBOutlet weak var saturationSlider: UISlider!
//
//    private lazy var camera: GPUImageVideoCamera = {
//        let cm = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.high.rawValue, cameraPosition: .front)
//        cm?.outputImageOrientation = .portrait
//        cm?.horizontallyMirrorFrontFacingCamera = true
//        return cm!
//    }()
//
//    private lazy var previewLayer = GPUImageView(frame: view.bounds)
//
//    // 存储路径 计算属性
//    var path: URL {
//        return URL(fileURLWithPath: "\(NSTemporaryDirectory())movie.mp4")
//    }
//
//    private lazy var moveWriter: GPUImageMovieWriter = {
//        let mw = GPUImageMovieWriter(movieURL: self.path, size: view.bounds.size)
//        mw?.encodingLiveVideo = true
//        return mw!
//    }()
//
//    // 滤镜
//    private let bilateralFilter = GPUImageBilateralFilter()// 磨皮
//    private let exposureFilter = GPUImageExposureFilter()// 曝光
//    private let brightnessFilter = GPUImageBrightnessFilter()// 美白
//    private let saturationFilter = GPUImageSaturationFilter()// 饱和
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setup()
//    }
//
//
}

extension KGPUImageCameraController {
    private func setup(){
//        let filterGroup = getGroupFiler()
//        camera.addTarget(filterGroup)
//        filterGroup.addTarget(previewLayer)
//        view.insertSubview(previewLayer, at: 0)
//        camera.startCapture()
//        
//        // 录制
//        filterGroup.addTarget(moveWriter)
//        camera.audioEncodingTarget = moveWriter
//        moveWriter.startRecording()
    }
}

extension KGPUImageCameraController {
//    private func getGroupFiler() -> GPUImageFilterGroup {
//        let filterGroup = GPUImageFilterGroup()
//
//        // 滤镜链条
//        bilateralFilter.addTarget(brightnessFilter)
//        brightnessFilter.addTarget(saturationFilter)
//        saturationFilter.addTarget(exposureFilter)
//
//        filterGroup.initialFilters = [bilateralFilter]
//        filterGroup.terminalFilter = exposureFilter
//
//        return filterGroup
//    }
}

extension KGPUImageCameraController {
//    // 转换摄像头
//    @IBAction func rotateCamera(_ sender: Any) {
//        camera.rotateCamera()
//    }
//    
//    // 调整滤镜
//    @IBAction func adjustEffect(_ sender: Any) {
//        effectViewTopCons.constant = 250
//        UIView.animate(withDuration: 0.25) {
//            self.view.layoutIfNeeded()
//        }
//    }
//    // 完成调整
//    @IBAction func finishedAdjustEffect(_ sender: Any) {
//        effectViewTopCons.constant = 0
//        UIView.animate(withDuration: 0.25) {
//            self.view.layoutIfNeeded()
//        }
//    }
//    
//    // 重置滤镜
//    @IBAction func resetFilter(_ sender: Any) {
//        bilateraSlider.setValue(0.5, animated: true)
//        changeBilateral(bilateraSlider)
//        exposureSlider.setValue(0.5, animated: true)
//        changeExposure(exposureSlider)
//        brightnessSlider.setValue(0.5, animated: true)
//        changeBrightness(brightnessSlider)
//        saturationSlider.setValue(0.5, animated: true)
//        changeSatureation(saturationSlider)
//    }
//    
//    // 开启关闭美颜
//    @IBAction func turnOnOffEffect(_ sender: UISwitch) {
//        if sender.isOn {
//            camera.removeAllTargets()
//            let filterGroup = getGroupFiler()
//            camera.addTarget(filterGroup)
//            filterGroup.addTarget(previewLayer)
//        }else {
//            camera.removeAllTargets()
//            camera.addTarget(previewLayer)
//        }
//    }
//    
//    // 磨皮
//    @IBAction func changeBilateral(_ sender: UISlider) {
//        bilateralFilter.distanceNormalizationFactor = CGFloat(sender.value * 8)
//    }
//    // 曝光
//    @IBAction func changeExposure(_ sender: UISlider) {
//        exposureFilter.exposure =  CGFloat(sender.value * 20) - 10
//    }
//    // 美白
//    @IBAction func changeBrightness(_ sender: UISlider) {
//        brightnessFilter.brightness = CGFloat(sender.value) * 2 - 1
//    }
//    // 饱和
//    @IBAction func changeSatureation(_ sender: UISlider) {
//        saturationFilter.saturation = CGFloat(sender.value) * 2
//    }
}
