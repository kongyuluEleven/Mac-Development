//
//  ViewController.swift
//  imageSegmentationML
//
//  Created by Muhammad Osama Naeem on 4/1/20.
//  Copyright © 2020 Muhammad Osama Naeem. All rights reserved.
//

import UIKit
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
   

    let imageView: UIImageView = {
       let img = UIImageView()
        img.image = UIImage(systemName: "hare.fill")
        img.contentMode = .scaleToFill
        img.translatesAutoresizingMaskIntoConstraints = false
        img.tintColor = .black
        return img
    }()
    
    let segmentedDrawingView: DrawingSegmentationView = {
       let img = DrawingSegmentationView()
        img.backgroundColor = .clear
        img.contentMode = .scaleToFill
        img.translatesAutoresizingMaskIntoConstraints = false
       return img
    }()
    
    let startSegmentationButton : UIButton = {
        let btn = UIButton(type: .system)
        btn.addTarget(self, action: #selector(handleStartSegmentationButton), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = .gray
        btn.layer.cornerRadius = 5
        btn.tintColor = .white
        btn.layer.masksToBounds  = true
        btn.setTitle("Begin", for: .normal)
        btn.isHidden = true
        return btn
    }()
    let imagePickerController = UIImagePickerController()
    var imageSegmentationModel = DeepLabV3()
    
    var request :  VNCoreMLRequest?
    
    
    
    var imageURL : URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .white
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "camera.circle.fill"), style: .done, target: self, action: #selector(handleCameraButtonTapped))
        self.title = "Image Segmentation"
        imagePickerController.delegate = self
        setupViews()
        layoutViews()
        setUpModel()
    }

    func setupViews() {
        view.addSubview(imageView)
        view.addSubview(segmentedDrawingView)
        view.addSubview(startSegmentationButton)
    }
    
    func layoutViews() {
        view.bringSubviewToFront(segmentedDrawingView)
        segmentedDrawingView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        segmentedDrawingView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        segmentedDrawingView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        segmentedDrawingView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        startSegmentationButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 250).isActive = true
        startSegmentationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40).isActive = true
        startSegmentationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40).isActive = true
        startSegmentationButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
    }

    
    func setUpModel() {
        if let visionModel = try? VNCoreMLModel(for: imageSegmentationModel.model) {
            request = VNCoreMLRequest(model: visionModel, completionHandler: visionRequestDidComplete)
            
            request?.imageCropAndScaleOption = .scaleFill
        
        } else {
            fatalError()
        }
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         if let image = info[.originalImage] as? UIImage,
           let url = info[.imageURL] as? URL {
           imageView.image = image
            self.imageURL = url
           self.startSegmentationButton.isHidden = false
       }
           dismiss(animated: true, completion: nil)
   }
    
    
    func predict(with url: URL) {
    DispatchQueue.global(qos: .userInitiated).async {
        guard let request = self.request else { fatalError() }
        let handler = VNImageRequestHandler(url: url, options: [:])
        do {
            try handler.perform([request])
        }catch {
            print(error)
        }
        
        }
   }
    
    func visionRequestDidComplete(request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            if let observations = request.results as? [VNCoreMLFeatureValueObservation],
                let segmentationmap = observations.first?.featureValue.multiArrayValue {
                self.segmentedDrawingView.segmentationmap = SegmentationResultMLMultiArray(mlMultiArray: segmentationmap)
                self.startSegmentationButton.setTitle("Done", for: .normal)
            }
        }
            
    }
    

    
    
    // MARK: - Handlers
    
    @objc func handleCameraButtonTapped() {
        self.present(imagePickerController, animated: true, completion: nil)
        self.segmentedDrawingView.segmentationmap = nil
        self.imageView.image = UIImage(systemName: "hare.fill")
        self.startSegmentationButton.isHidden = true
        self.startSegmentationButton.setTitle("Begin", for: .normal)
      
    }
    
    @objc func handleStartSegmentationButton() {
        self.startSegmentationButton.setTitle("In Progress...", for: .normal)
        guard let url = self.imageURL else { return }
        self.predict(with: url)
        
    }
}
    
    
