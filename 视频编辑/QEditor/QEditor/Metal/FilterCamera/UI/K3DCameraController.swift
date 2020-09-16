//
//  K3DCameraController.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/16.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import MetalKit
import AVFoundation

class K3DCameraController: UIViewController {

    @IBOutlet weak var slider:  UISlider!
    @IBOutlet weak var filterLabel:  UILabel!
    @IBOutlet weak var loading:  UIView!

    var session: MetalCameraSession?
    
    var filterType: GImageFilterType = .mpsUnaryImageKernel(type: .laplacian) {
        didSet {
            filterLabel.text = filterType.name
        }
    }
    var imageFilter: GImageFilter?

    var renderer: KRenderer!
    var mtkView: MTKView!
    let context = GContext()
    var sliderValue: Float = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        loading.isHidden = true
        guard let mtkView = view as? MTKView else {
            print("View of Gameview controller is not an MTKView")
            return
        }

        // Select the device to render with.  We choose the default device
        guard let defaultDevice = MTLCreateSystemDefaultDevice() else {
            print("Metal is not supported")
            return
        }
        
        mtkView.device = defaultDevice
        mtkView.backgroundColor = UIColor.black

        guard let newRenderer = KRenderer(metalKitView: mtkView) else {
            print("Renderer cannot be initialized")
            return
        }

        renderer = newRenderer

        renderer.mtkView(mtkView, drawableSizeWillChange: mtkView.drawableSize)

        mtkView.delegate = renderer
        
        filterType = .kuwahara// .mpsUnaryImageKernel(type: .laplacian)
        imageFilter = filterType.createImageFilter(context: context)
        changeSliderSetting()
        session = MetalCameraSession(delegate: self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        session?.start()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        session?.stop()
    }
    
    
    @IBAction func sliderValueChanged(_ sender: Any) {
        sliderValueChanged()
    }
    
    @IBAction func btnScaleClicked(_ sender: Any) {
    }
    
    @IBAction func btnSnapClicked(_ sender: Any) {
        pictureTaken()
    }
    
    @IBAction func btnFilterClicked(_ sender: Any) {
        filterSelectionClicked()
    }
    
    @IBAction func btnSwitchCameraClicked(_ sender: Any) {
        session?.switchCamera()
    }
    
}

// MARK: - MetalCameraSessionDelegate
extension K3DCameraController: MetalCameraSessionDelegate {
    
    func metalCameraSession(_ session: MetalCameraSession, didReceiveFrameAsTextures textures: [MTLTexture], withTimestamp timestamp: Double) {
        if UIDevice.current.orientation.isValidInterfaceOrientation {
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                renderer.deviceOrientation = UIDevice.current.orientation
            }
            else {
                if UIDevice.current.orientation.rawValue != 2 {
                    renderer.deviceOrientation = UIDevice.current.orientation
                }
            }
        }
        let ttt = textures[0]
        
        
//        let filter = GImageFilterType.mpsUnaryImageKernel(type: .sobel).createImageFilter(context: context)
//        let filter = GImageFilterType.mpsUnaryImageKernel(type: .laplacian).createImageFilter(context: context)
        imageFilter?.setValue(self.sliderValue)
        imageFilter?.provider0 = SimpleTextureProvider(texture: ttt)
        renderer.colorMap = self.imageFilter!.texture!
    }
    
    func metalCameraSession(_ cameraSession: MetalCameraSession, didUpdateState state: MetalCameraSessionState, error: MetalCameraSessionError?) {
        
        if error == .captureSessionRuntimeError {
            /**
             *  In this app we are going to ignore capture session runtime errors
             */
            cameraSession.start()
        }
        NSLog("Session changed state to \(state) with error: \(error?.localizedDescription ?? "None").")
    }
}

extension K3DCameraController{
    
    private func pictureTaken() {
        GZLogFunc()
        
        loading.isHidden = false
        DispatchQueue.global().async {[weak self] in
            guard let welf = self else {
                DispatchQueue.main.async {[weak self] in self?.loading.isHidden = true }
                return
            }
//            guard let t = welf.renderer?.colorMap, let image = UIImage.image(texture: t), let oriented = welf.getImageFrom(image: image) else {
//            DispatchQueue.main.async {[weak self] in self?.loading.isHidden = true }
//                return
//            }
            guard let t = welf.renderer?.colorMap, let image = t.image, let oriented = welf.getImageFrom(image: image) else {
                DispatchQueue.main.async {[weak self] in self?.loading.isHidden = true }
                return
            }
            UIImageWriteToSavedPhotosAlbum(oriented, welf, #selector(welf.finishWriteImage(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    @objc private func finishWriteImage(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        GZLogFunc(error)
        loading.isHidden = true
    }
    
    
    
    private func sliderValueChanged() {
        GZLogFunc()
        
        sliderValue = Float(slider.value)
    }

    private func filterSelectionClicked() {
        GZLogFunc()
        
        let alert = UIAlertController(title: "Filter", message: nil, preferredStyle: .alert)
        var objects = [GImageFilterType]()
//        objects.append(.gaussianBlur2D)
//        objects.append(.saturationAdjustment)
        objects.append(.rotation)
        objects.append(.colorGBR)
        objects.append(.sepia)
        objects.append(.pixellation)
        objects.append(.luminance)
        objects.append(.normalMap)
        objects.append(.invert)
        objects.append(.centerMagnification)
        objects.append(.swellingUp)
        objects.append(.slimming)
        objects.append(.repeat)
        objects.append(.redEmphasis)
        objects.append(.greenEmphasis)
        objects.append(.blueEmphasis)
        objects.append(.rgbEmphasis)
        objects.append(.divide)
        objects.append(.carnivalMirror)
        objects.append(.kuwahara)
        objects.append(.mpsUnaryImageKernel(type: .sobel))
        objects.append(.mpsUnaryImageKernel(type: .laplacian))
        objects.append(.mpsUnaryImageKernel(type: .gaussianBlur))
        objects.append(.mpsUnaryImageKernel(type: .emboss))
//        objects.append(.mpsUnaryImageKernel(type: .gaussianPyramid))
//        objects.append(.mpsUnaryImageKernel(type: .laplacianPyramid))
//        objects.append(.binaryImageKernel(type: .oneStepLaplacianPyramid))


        for x in objects {
            alert.addAction(UIAlertAction(title: x.name, style: .default, handler: { (action) in
                
                self.filterType = x
                self.imageFilter = x.createImageFilter(context: self.context)
                self.changeSliderSetting()
            }))
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        self.present(alert, animated: true, completion: nil)
    }
    
    func changeSliderSetting() {
        slider.isHidden = false
        switch filterType {
        case .gaussianBlur2D:
            self.slider.value = 1
            self.slider.minimumValue = 1
            self.slider.maximumValue = 8
        case .saturationAdjustment:
            self.slider.value = 1
            self.slider.minimumValue = 0
            self.slider.maximumValue = 1
        case .colorGBR:
            self.slider.value = 0
            self.slider.minimumValue = 0
            self.slider.maximumValue = 360
        case .rotation:
            self.slider.value = 0
            self.slider.minimumValue = 0
            self.slider.maximumValue = 1
        case .sepia:
            slider.isHidden = true
        case .pixellation:
            self.slider.value = 1
            self.slider.minimumValue = 1
            self.slider.maximumValue = 300
        case .divide:
            self.slider.minimumValue = 1
            self.slider.maximumValue = 10
            self.slider.value = 5
        case .carnivalMirror:
            self.slider.minimumValue = 20
            self.slider.maximumValue = 50
            self.slider.value = 20
        case .kuwahara:
            self.slider.minimumValue = 1
            self.slider.maximumValue = 20
            self.slider.value = 10
        case .luminance:
            slider.isHidden = true
        case .normalMap:
            slider.isHidden = true
        case .invert:
            slider.isHidden = true
        case .centerMagnification:
            self.slider.value = 0.75
            self.slider.minimumValue = 0.5
            self.slider.maximumValue = 1
        case .swellingUp:
            self.slider.value = 0.75
            self.slider.minimumValue = 0.5
            self.slider.maximumValue = 1
        case .slimming:
            self.slider.value = 0.75
            self.slider.minimumValue = 0
            self.slider.maximumValue = 0.9
        case .mpsUnaryImageKernel(let type):
            switch type {
            case .sobel:
                slider.isHidden = true
            case .laplacian:
                self.slider.value = 0.02
                self.slider.minimumValue = 0.01
                self.slider.maximumValue = 0.1
                slider.isHidden = false
            case .gaussianBlur:
                self.slider.value = 0
                self.slider.minimumValue = 0
                self.slider.maximumValue = 20
                slider.isHidden = false
            case .emboss:
                slider.isHidden = true
            default:
                slider.isHidden = true
            }
        default:
            slider.isHidden = true
        }
        
        sliderValue = Float(slider.value)
    }
    
    func getImageFrom(image: UIImage) ->UIImage? {
        var imageOrientation: UIImage.Orientation = .right
        GZLogFunc(renderer.deviceOrientation.rawValue)

        if renderer.deviceOrientation == .portrait {
            imageOrientation = .right
        }
        else if renderer.deviceOrientation == .portraitUpsideDown {
            imageOrientation = .left
        }
        else if renderer.deviceOrientation == .landscapeLeft {
            imageOrientation = .up
        }
        else if renderer.deviceOrientation == .landscapeRight {
            imageOrientation = .down
        }

        //        let image1 = UIImage(cgImage: cgImage)
        guard let rotatedCgImage = createMatchingBackingDataWithImage1(imageRef: image.cgImage, orienation: imageOrientation) else {
            return nil
        }
        let image = UIImage(cgImage: rotatedCgImage, scale: 1, orientation: .up)
        return image
    }
    
    func createMatchingBackingDataWithImage1(imageRef: CGImage?, orienation: UIImage.Orientation) -> CGImage? {
        return imageRef
        
        
        var orientedImage: CGImage?
        
        if let imageRef = imageRef {
            let originalWidth = imageRef.width
            let originalHeight = imageRef.height
            let bitsPerComponent = imageRef.bitsPerComponent
            let bytesPerRow = imageRef.bytesPerRow
            
            let colorSpace = imageRef.colorSpace
//            let colorSpace = CGColorSpace(name: CGColorSpace.genericRGBLinear)
            GZLogFunc(colorSpace?.name)
            let bitmapInfo = imageRef.bitmapInfo
            
            var degreesToRotate: Double
            var swapWidthHeight: Bool
            var mirrored: Bool
            switch orienation {
            case .up:
                degreesToRotate = 0.0
                swapWidthHeight = false
                mirrored = false
                break
            case .upMirrored:
                degreesToRotate = 0.0
                swapWidthHeight = false
                mirrored = true
                break
            case .right:
                degreesToRotate = -90.0
                swapWidthHeight = true
                mirrored = false
                break
            case .rightMirrored:
                degreesToRotate = -90.0
                swapWidthHeight = true
                mirrored = true
                break
            case .down:
                degreesToRotate = 180.0
                swapWidthHeight = false
                mirrored = false
                break
            case .downMirrored:
                degreesToRotate = 180.0
                swapWidthHeight = false
                mirrored = true
                break
            case .left:
                degreesToRotate = 90.0
                swapWidthHeight = true
                mirrored = false
                break
            case .leftMirrored:
                degreesToRotate = 90.0
                swapWidthHeight = true
                mirrored = true
                break
            }
            let radians = degreesToRotate * Double.pi / 180
            
            var width: Int
            var height: Int
            if swapWidthHeight {
                width = originalHeight
                height = originalWidth
            } else {
                width = originalWidth
                height = originalHeight
            }
            
            if let contextRef = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue) {
                
                contextRef.translateBy(x: CGFloat(width) / 2.0, y: CGFloat(height) / 2.0)
                if mirrored {
                    contextRef.scaleBy(x: -1.0, y: 1.0)
                }
                contextRef.rotate(by: CGFloat(radians))
                if swapWidthHeight {
                    contextRef.translateBy(x: -CGFloat(height) / 2.0, y: -CGFloat(width) / 2.0)
                } else {
                    contextRef.translateBy(x: -CGFloat(width) / 2.0, y: -CGFloat(height) / 2.0)
                }
                contextRef.draw(imageRef, in: CGRect(x: 0, y: 0, width: originalWidth, height: originalHeight))
                
                orientedImage = contextRef.makeImage()
            }
        }
        
        return orientedImage
    }
}


