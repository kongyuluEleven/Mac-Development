//
//  KPhotoMattingVC.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/11.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import Vision
import MetalPetal

class KPhotoMattingVC: KBaseRenderController {
    
    fileprivate var startTimestamp: CFAbsoluteTime = 0
    
    let imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePickerController.delegate = self
        backgroundPicker.isHidden = false
        backgroundPicker.showSelectionBorder = true
        backgroundPicker.onSelect = { [weak self] image in
            guard let cgImage = image.cgImage else { return }
            self?.mattingFilter.inputBackgroundImage = MTIImage(cgImage: cgImage, isOpaque: true)
            self?.mtiImageView.image = self?.mattingFilter.outputImage
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        backgroundPicker.frame = CGRect(x: 0, y: view.bounds.height - 60, width: view.bounds.width, height: 60)
        backgroundPicker.setupLayout(itemSize: CGSize(width: 50, height: 50), direction: .horizontal)
    }
    
    @IBAction func tapCamera(_ sender: Any) {
        self.present(imagePickerController, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension KPhotoMattingVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage,
            let url = info[.imageURL] as? URL else {
                return
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.processImage(at: url, image: image)
        }
    
        dismiss(animated: true) { [unowned self] in
            let inputImage = MTIImage(contentsOf: url)
            self.mattingFilter.inputImage = inputImage
            self.mtiImageView.image = self.mattingFilter.outputImage
        }
    }
    
    func processImage(at url: URL, image: UIImage) {
        switch self.algorithm {
        case .deeplab:
            guard let mask = deepLabCenter.predict(imageURL: url) else { return }
            let maskImage = MTIImage(cvPixelBuffer: mask, alphaType: .alphaIsOne)
            self.mattingFilter.inputMask = MTIMask(content: maskImage, component: .red, mode: .normal)
            
        case .segment:
            
            guard let mask = segmentor.process(image: image) else { return }
            let maskImage = MTIImage(cgImage: mask, isOpaque: true)
            self.mattingFilter.inputMask = MTIMask(content: maskImage, component: .red, mode: .normal)
            
        case .saliency:
            guard let mask = saliencyCenter.process(imageURL: url) else { return }
            let maskImage = MTIImage(ciImage: mask, isOpaque: true)
            self.mattingFilter.inputMask = MTIMask(content: maskImage, component: .red, mode: .normal)
        }
    }
}
