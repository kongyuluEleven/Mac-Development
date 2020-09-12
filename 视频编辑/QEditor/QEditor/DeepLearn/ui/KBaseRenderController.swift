//
//  KBaseRenderController.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/11.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//


import UIKit
import MetalPetal


class KBaseRenderController: UIViewController {
    
    enum MatteAlgorithm: Int {
        case saliency = 0
        case segment
        case deeplab
    }
    
    lazy var mtiImageView: MTIImageView = {
        let view = MTIImageView(frame: CGRect.zero)
        return view
    }()
    
    lazy var btnPicker: UIButton = {
        let button = UIButton(frame: CGRect.zero)
        button.addTarget(self, action: #selector(showPicker), for: .touchUpInside)
        return button
    }()
    
    lazy var algorithmSegment: UISegmentedControl? = {
        return self.navigationItem.rightBarButtonItem?.customView as? UISegmentedControl
    }()
    
    let context = try! MTIContext(device: MTLCreateSystemDefaultDevice()!)
    
    
    var algorithm: MatteAlgorithm = .saliency
    var segmentor = Segmentor(name: "segmentor")
    let deepLabCenter = DeepLabCenter()
    let saliencyCenter = VisionSaliencyCenter()
    
    /// 抠图滤镜
    lazy var mattingFilter: MTIBlendWithMaskFilter = {
        let filter = MTIBlendWithMaskFilter()
        let maskImage = MTIImage(color: .black, sRGB: false, size: CGSize(width: 100, height: 100))
        filter.inputMask = MTIMask(content: maskImage, component: .red, mode: .oneMinusMaskValue)
        filter.inputBackgroundImage = MTIImage(image: UIImage(named: "material_0.jpg")!)
        return filter
    }()
    
    /// 背景选择器
    lazy var backgroundPicker: ImagePicker = {
        let picker = ImagePicker()
        picker.dataProvider = ImageDataProvider()
        picker.setupLayout(itemSize: CGSize(width: 100, height: 50), direction: .vertical)
        picker.isHidden = true
        return picker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupBackgroundPicker()
        algorithmSegment?.addTarget(self, action: #selector(switchAlgorithm), for: .valueChanged)
        
        mtiImageView.contentMode = .scaleAspectFit
        mtiImageView.context = self.context
    }
    
    func setupUI() {
        
        view.addSubview(mtiImageView)
        view.addSubview(btnPicker)
        
        mtiImageView.frame = self.view.frame
        btnPicker.frame = CGRect(x: view.bounds.width - btnPicker.width, y: view.bounds.height - btnPicker.height-60, width: 60, height: 60)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        mtiImageView.frame = self.view.frame
        btnPicker.frame = CGRect(x: view.bounds.width - btnPicker.width, y: view.bounds.height - btnPicker.height-60, width: 60, height: 60)
        
        let buttonFrame = btnPicker.frame
        var pickerFrame = CGRect(x: 0, y: 0, width: 80, height: view.bounds.height * 0.5)
        pickerFrame.origin.x = view.bounds.width - pickerFrame.width
        pickerFrame.origin.y = buttonFrame.minY - pickerFrame.height - 20
        backgroundPicker.frame = pickerFrame
    }
    
    func setupBackgroundPicker() {
        
        guard let initialBackgroundImage = backgroundPicker.dataProvider?.image(at: 0) else {return}
        btnPicker.setBackgroundImage(initialBackgroundImage, for: .normal)
        btnPicker.layer.cornerRadius = 25
        btnPicker.layer.masksToBounds = true
        btnPicker.layer.borderWidth = 2
        btnPicker.layer.borderColor = UIColor.red.cgColor
        btnPicker.adjustsImageWhenHighlighted = false
        btnPicker.showsTouchWhenHighlighted = false
        
        backgroundPicker.onSelect = { [weak self] image in
            self?.backgroundPicker.isHidden = true
            self?.btnPicker.isSelected = false
            self?.btnPicker.setBackgroundImage(image, for: .normal)
            guard let cgImage = image.cgImage else { return }
            self?.mattingFilter.inputBackgroundImage = MTIImage(cgImage: cgImage, isOpaque: true)
        }
        view.addSubview(backgroundPicker)
    }
    
    @objc func showPicker(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            backgroundPicker.isHidden = false
        } else {
            backgroundPicker.isHidden = true
            self.view.bringSubviewToFront(backgroundPicker)
        }
    }
}

//MARK: - 扣图算法设置

extension KBaseRenderController {
    
    @objc func switchAlgorithm(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            algorithm = .saliency
        case 1:
            algorithm = .segment
        case 2:
            algorithm = .deeplab
        default:
            break
        }
    }
    
    func generateMask(from pixelBuffer: CVPixelBuffer) {
        
        DispatchQueue.global(qos: .userInteractive).async {
            switch self.algorithm {
            case .deeplab:
                self.generateMaskUsingDeeplab(from: pixelBuffer)
            case .segment:
                self.generateMaskUsingSegment(from: pixelBuffer)
            case .saliency:
                self.generateMaskUsingSaliency(from: pixelBuffer)
            }
        }
        
    }
    
    func generateMaskUsingSaliency(from pixelBuffer: CVPixelBuffer, imageOrientation: CGImagePropertyOrientation = .up) {
        guard let mask = saliencyCenter.process(pixelBuffer: pixelBuffer, orientation: imageOrientation) else {
            return
        }
        DispatchQueue.main.async {
            let maskImage = MTIImage(ciImage: mask, isOpaque: true)
            self.mattingFilter.inputMask = MTIMask(content: maskImage, component: .red, mode: .normal)
        }
    }
    
    func generateMaskUsingDeeplab(from pixelBuffer: CVPixelBuffer) {
        guard let mask = deepLabCenter.predict(with: pixelBuffer) else {
            return
        }
        DispatchQueue.main.async {
            let maskImage = MTIImage(cvPixelBuffer: mask, alphaType: .alphaIsOne)
            self.mattingFilter.inputMask = MTIMask(content: maskImage, component: .red, mode: .normal)
        }
    }
    
    func generateMaskUsingSegment(from pixelBuffer: CVPixelBuffer) {
        
        guard !segmentor.isBusy else { return }
        
        DispatchQueue.global().async {
            guard let inputImage = pixelBuffer.toUIImage() else {
                print("Pixel buffer to image failed")
                return
            }
            
            guard let mask = self.segmentor.process(image: inputImage) else {
                return
            }
            
            DispatchQueue.main.async {
                let maskImage = MTIImage(cgImage: mask, isOpaque: true)
                self.mattingFilter.inputMask = MTIMask(content: maskImage, component: .red, mode: .normal)
            }
        }
    }
}

