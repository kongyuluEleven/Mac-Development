//
//  KGPUImageCamera.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/11.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import Foundation
import UIKit
import GPUImage
import AVKit
import AssetsLibrary

/*
class KGPUImageCameraVC: UIViewController {
    
    @IBOutlet weak var beautyLive: NSLayoutConstraint!
    
    //创建视频源
    fileprivate lazy var Camera : GPUImageVideoCamera? = GPUImageVideoCamera(sessionPreset: AVCaptureSessionPresetHigh, cameraPosition: .front)
    
    //创建预览图层
    fileprivate lazy var preview : GPUImageView = GPUImageView(frame: self.view.bounds)
    
    // 初始化滤镜
    let BrightnessFilter = GPUImageBrightnessFilter()  //美白
    let SaturationFilter = GPUImageSaturationFilter() //饱和度
    let ExposureFilter = GPUImageExposureFilter() //曝光
    let BilateralFilter = GPUImageBilateralFilter() // 磨皮
    
    
    // 创建写入对象
    
    fileprivate lazy var MovieWrite : GPUImageMovieWriter = {[unowned self] in
        
        let writer = GPUImageMovieWriter(movieURL: self.fileURL, size: self.view.bounds.size)
        
        return writer!
    }()
    
    
    // 计算属性
    
    var fileURL : URL {
    
    
            return URL(fileURLWithPath: "\(NSTemporaryDirectory())test123.mp4")
    }
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置摄像头的方向
        Camera?.outputImageOrientation = .portrait
        // 水平前置摄像头
        Camera?.horizontallyMirrorFrontFacingCamera = true
        
        // 设置预览图层
        view.insertSubview(preview, at: 0)
        
        // 获取滤镜组
        let FilterGroup = getGroupFilters()
        
        // 设置GPUImage采集视频响应链
        Camera?.addTarget(FilterGroup)
        FilterGroup.addTarget(preview)
        
        
        
        // 开始采集
        Camera?.startCapture()
       let fileM = FileManager.default
        if fileM.fileExists(atPath: "test123.mp4")  {
            
            _ = try! FileManager.default.removeItem(at: fileURL)
        
            // 写入文件设置
            //是否对视频进行编码
            MovieWrite.encodingLiveVideo = true
            // 将MovieWrit设置成滤镜的target
            FilterGroup.addTarget(MovieWrite)
            
            Camera?.delegate = self
            //摄像头的音频文件写入
            Camera?.audioEncodingTarget = MovieWrite
            
            // 开始写入
            MovieWrite.startRecording()
        
        }
        
    }
    
    //滤镜组
    fileprivate func getGroupFilters() -> GPUImageFilterGroup{
        
        // 1.创建滤镜组（用于存放各种滤镜：美白、磨皮等等）
        let GroupFilter = GPUImageFilterGroup()
        
        // 2.创建滤镜(设置滤镜的引来关系)
        BilateralFilter.addTarget(BrightnessFilter)
        BrightnessFilter.addTarget(ExposureFilter)
        ExposureFilter.addTarget(SaturationFilter)
        
        // 3.设置滤镜组链初始&终点的filter
        GroupFilter.initialFilters = [BilateralFilter]
        GroupFilter.terminalFilter = SaturationFilter
        
        return GroupFilter
    }

  
    
    //结束直播
    @IBAction func FinishLive() {
        
    preview.removeFromSuperview()
    Camera?.stopCapture()
    MovieWrite.finishRecording()
    
    
    }
    
    
    //调整美颜
    @IBAction func adjustBeauty() {
        
     adjustBeautyView(constant: -250)
       
        
    }
    
    //旋转摄像头
    @IBAction func rotateCamera() {
    
        Camera?.rotateCamera()
    
    }
    
    
    // 是否开启美颜
    @IBAction func SwitchBeauty(_ sender: UISwitch) {
        
        if sender.isOn {
        
            Camera?.removeAllTargets()
            let groupFilter = getGroupFilters()
            Camera?.addTarget(groupFilter)
            groupFilter.addTarget(preview)
            
        }else{
        
            Camera?.removeAllTargets()
            Camera?.addTarget(preview)
            
        }
        
        
    }
    
    // 完成
    @IBAction func FinishBeauty() {
        
        adjustBeautyView(constant: 0)
        
    }
    
    
    //饱和度
    @IBAction func BeautySatureation(_ sender: UISlider) {
        
        // 0~2 默认是 1
        SaturationFilter.saturation = CGFloat(sender.value * 2)
    }
    
    //美白
    @IBAction func BeautyBrightness(_ sender: UISlider) {
        // -1~1 默认为0
       BrightnessFilter.brightness = CGFloat(sender.value) * 2 - 1
    }
    
    //曝光
    @IBAction func BeautyExposure(_ sender: UISlider) {
        // -10~10 默认为0
        ExposureFilter.exposure = CGFloat(sender.value)
        
    }

    //磨皮
    @IBAction func BeautyBilateral(_ sender: UISlider) {
        
       BilateralFilter.distanceNormalizationFactor = CGFloat(sender.value) * 8
    }
    
    //播放视频
    @IBAction func PlayLive() {
       
        let playVC = AVPlayerViewController()
        playVC.player = AVPlayer(url:fileURL)
        present(playVC, animated: true, completion: nil)
        
        
    }

    fileprivate func adjustBeautyView(constant:CGFloat){
        
        beautyLive.constant = constant
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    
    }
    
    
}

extension KGPUImageCameraVC : GPUImageVideoCameraDelegate {
    func willOutputSampleBuffer(_ sampleBuffer: CMSampleBuffer!) {
        print("采集到画面")
    }
}

 */
