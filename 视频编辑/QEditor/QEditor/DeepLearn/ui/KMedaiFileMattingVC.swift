//
//  KMedaiFileMattingVC.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/12.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation
import MetalPetal
import Speech

class KMedaiFileMattingVC: UIViewController {

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var outputButton: UIButton!
    
    @IBOutlet weak var playerContainerView: UIView!
    @IBOutlet weak var backgroundPicker: ImagePicker!
    
    fileprivate let player = AVPlayer()
    fileprivate let previewView = PlayerPreviewView()
    fileprivate var currentVideoOutput: AVPlayerItemVideoOutput?
    fileprivate var currentMattingFrameIndex: Int64 = 0
    
    fileprivate var videoComposition: VideoComposition<BlockBasedVideoCompositor>?
    fileprivate let context = try! MTIContext(device: MTLCreateSystemDefaultDevice()!)
    fileprivate var exporter: AssetExportSession?
    fileprivate var compositionHandler: KVideoMattingOutputHandler?
    
    public var recordFile:URL?
    public var language:String?
    
    @IBOutlet weak var lrcTextView: UITextView!
    
    @IBOutlet weak var btnFetchLrc: UIButton!
    
    fileprivate lazy var algorithmSegmentControl: UISegmentedControl = {
        let segmentControl = UISegmentedControl()
        segmentControl.insertSegment(withTitle: "显著算法", at: 0, animated: false)
        segmentControl.insertSegment(withTitle: "分割算法", at: 1, animated: false)
        //segmentControl.selectedSegmentTintColor = .systemPink
        segmentControl.sizeToFit()
        return segmentControl
    }()
    
    var videoAsset: AVURLAsset? {
        didSet {
            configVideoPlayer(videoAsset)
        }
    }
    
    deinit {
        player.removeObserver(self, forKeyPath: "timeControlStatus")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        previewView.videoGravity = .resizeAspectFill
        previewView.player = player
        playerContainerView.addSubview(previewView)
        playerContainerView.bringSubviewToFront(playButton)
        player.addObserver(self, forKeyPath: "timeControlStatus", options: [.new], context: nil)
        
        setupBackgroundPicker()
        setupAlgorithmSegmentControl()
        
        self.view.bringSubviewToFront(playButton)
        
        backgroundPicker.selectItem(at: IndexPath(row: 0, section: 0))
        
        lrcTextView.text = ""
//        lrcTextView.backgroundColor = .clear
//        lrcTextView.textColor = .white
    }
    
    private func setupBackgroundPicker() {
        backgroundPicker.isHidden = false
        backgroundPicker.showSelectionBorder = true
        backgroundPicker.dataProvider = ImageDataProvider()
        backgroundPicker.setupLayout(itemSize: CGSize(width: 50, height: 50), direction: .horizontal)
        backgroundPicker.onSelect = { [weak self] image in
            guard let cgImage = image.cgImage else { return }
            let image = MTIImage(cgImage: cgImage, isOpaque: true)
            self?.compositionHandler?.setBackgroundImage(image)
        }
    }
    
    private func setupAlgorithmSegmentControl() {
        algorithmSegmentControl.addTarget(self, action: #selector(switchAlgorithm), for: .valueChanged)
        algorithmSegmentControl.selectedSegmentIndex = 0
        self.navigationItem.titleView = algorithmSegmentControl
    }
    
    @objc private func switchAlgorithm(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            compositionHandler?.matteAlgorithm = .saliency
        } else {
            compositionHandler?.matteAlgorithm = .segment
        }
    }
    
    @IBAction func playVideo(_ sender: Any) {
        player.play()
    }
    
    public func play() {
        player.play()
    }
    
    
    @IBAction func btnFetchLrcClicked(_ sender: Any) {
        print("\(#function)")
        handleTranscribeButtonTapped()
    }
    
    @IBAction func startMattingAndOutput(_ sender: UIButton) {
        exportMattedVideo()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //backgroundPicker.selectItem(at: IndexPath(item: 0, section: 0))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewView.frame = playerContainerView.bounds
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "timeControlStatus" {
            if player.timeControlStatus == .paused {
                playButton.isHidden = false
            } else if player.timeControlStatus == .playing {
                playButton.isHidden = true
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    
}

fileprivate extension KMedaiFileMattingVC {
    
    func configVideoPlayer(_ videoAsset: AVURLAsset?) {
        guard let asset = videoAsset else {
            player.replaceCurrentItem(with: nil)
            return
        }
        
        compositionHandler = KVideoMattingOutputHandler(context: context,
                                                        tracks: asset.tracks(withMediaType: .video))
        let composition = VideoComposition(propertiesOf: asset,
                                           compositionRequestHandler: compositionHandler!.handle(request:))
        
        let playerItem = AVPlayerItem(asset: asset)
        playerItem.videoComposition = composition.makeAVVideoComposition()
        self.player.replaceCurrentItem(with: playerItem)
        self.previewView.player = self.player
        self.videoComposition = composition
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem, queue: nil) { [weak self] (_) in
            self?.player.seek(to: CMTime.zero)
        }
    }
    
    func exportMattedVideo() {
        guard let asset = videoAsset, let composition = self.videoComposition else {
            return
        }
        player.pause()
        
        var textField: UITextField!
        let alertController = UIAlertController(title: NSLocalizedString("抠图并导出视频...", comment: ""), message: nil, preferredStyle: .alert)
        alertController.addTextField { tf in
            tf.isEnabled = false
            textField = tf
        }
        present(alertController, animated: true)
        
        let fileManager = FileManager()
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("temp.mp4")
        try? fileManager.removeItem(at: outputURL)
        
        var configuration = AssetExportSession.Configuration(fileType: AssetExportSession.fileType(for: outputURL)!,
                                                             videoSettings: .h264(videoSize: composition.renderSize),
                                                             audioSettings: .aac(channels: 2, sampleRate: 44100, bitRate: 128 * 1000))
        configuration.videoComposition = composition.makeAVVideoComposition()
        let exporter = try! AssetExportSession(asset: asset, outputURL: outputURL, configuration: configuration)
        
        exporter.export(progress: { p in
            textField.text = p.localizedDescription
        }, completion: { error in
    
            self.dismiss(animated: true, completion: {
                if let error = error {
                    Alert(error: error, confirmActionTitle: "OK").show(in: self)
                } else {
                    if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.phone {
                        let activityViewController = UIActivityViewController(activityItems: [outputURL], applicationActivities: nil)
                        activityViewController.modalPresentationStyle = .popover
                        self.present(activityViewController, animated: true, completion: nil)
                    } else {
                        let activityViewController = UIActivityViewController(activityItems: [outputURL], applicationActivities: nil)
                        activityViewController.modalPresentationStyle = .popover
                        
                        activityViewController.popoverPresentationController?.sourceView = self.backgroundPicker
                        activityViewController.popoverPresentationController?.sourceRect = self.backgroundPicker.bounds
                        self.present(activityViewController, animated: true, completion: nil)
                    }
                    
                }
            })
        })
        self.exporter = exporter
    }
    
    func composeVideoByCoreImage() {
        
        guard let playerItem = player.currentItem, let asset = videoAsset else { return }
        
        let filter = CIFilter(name: "CIGaussianBlur")!
        let composition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: { request in
            
            // Clamp to avoid blurring transparent pixels at the image edges
            let source = request.sourceImage.clampedToExtent()
            filter.setValue(source, forKey: kCIInputImageKey)
            
            // Vary filter parameters based on video timing
            let seconds = CMTimeGetSeconds(request.compositionTime)
            filter.setValue(seconds * 10.0, forKey: kCIInputRadiusKey)
            
            // Crop the blurred output to the bounds of the original image
            guard let output = filter.outputImage?.cropped(to: request.sourceImage.extent) else {return}
            
            // Provide the filter output to the composition
            request.finish(with: output, context: nil)
        })
        
        playerItem.videoComposition = composition
        
    }
    
    func composeVideoByCustomRendering() {
        
    }
}


// MARK: - Transcription management
extension KMedaiFileMattingVC {
  fileprivate func transcribeFile(url: URL, locale: Locale?) {
    let locale = locale ?? Locale.current

    guard let recognizer = SFSpeechRecognizer(locale: locale) else {
      print("Speech recognition not available for specified locale")
      return
    }

    if !recognizer.isAvailable {
      print("Speech recognition not currently available")
      //return
    }

    // 2
    updateUIForTranscriptionInProgress()
    let request = SFSpeechURLRecognitionRequest(url: url)
    request.shouldReportPartialResults = true
    
    // Keep speech recognition data on device
    if #available(iOS 13, *) {
        request.requiresOnDeviceRecognition = true
    }
    
    //request.requiresOnDeviceRecognition = true
    
    // 3
    recognizer.recognitionTask(with: request) {
      [unowned self] (result, error) in
      guard let result = result else {
        print("There was an error transcribing that file")
        return
      }
    
      let str = result.bestTranscription.formattedString
      print("\(str)\n")
        
        if let err = error {
            print("\(err)")
        }

      // 4
      if result.isFinal {
        self.updateUIWithCompletedTranscription(str)
      }
    }
  }

  private func handleTranscribeButtonTapped() {
    SFSpeechRecognizer.requestAuthorization {
      [unowned self] (authStatus) in
      switch authStatus {
      case .authorized:
        if let url = self.recordFile {
            self.transcribeFile(url: url, locale: Locale(identifier: self.language ?? "en-US"))
        }
      case .denied:
        print("Speech recognition authorization denied")
      case .restricted:
        print("Not available on this device")
      case .notDetermined:
        print("Not determined")
      }
    }
  }
  
  fileprivate func updateUIForTranscriptionInProgress() {
    DispatchQueue.main.async { [unowned self] in
//      self.transcribeButton.isEnabled = false
//      self.activityIndicator.startAnimating()
//      UIView.animate(withDuration: 0.5) {
//        self.activityIndicator.isHidden = false
//      }
    }
  }
  
  fileprivate func updateUIWithCompletedTranscription(_ transcription: String) {
    DispatchQueue.main.async { [unowned self] in
      self.lrcTextView.text = transcription
        self.view.bringSubviewToFront(self.lrcTextView)
        print("transcription = \(transcription)")
//      UIView.animate(withDuration: 0.5, animations: {
//        self.activityIndicator.isHidden = true
//        self.transcriptionTextView.isHidden = false
//        }, completion: { _ in
//          self.activityIndicator.stopAnimating()
//          self.transcribeButton.isEnabled = true
//      })
    }
  }
}
