//
//  KSwiftyCameraVC.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/9.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

let TEST_URL = "http://m.kekenet.com/menu/201206/185740.shtml"

let HOLDE_PLACE_TEXT = "请在此处输入你想要跟踪失败的文字，然后点击《拷贝》按钮"

let TEXT_COPY_DEFAULT = """
 Passage 37. Life Lessons
 Sometimes people come into your life and you know right away that they were meant to be there,
 to serve some sort of purpose,teach you a lesson, or to help you figure out who you are or who you want to become. You never know who these people may be—a roommate, a neighbor, a professor, a friend, a lover, or even a complete stranger—but when you lock eyes with them,you know at that very moment they will affect your life in some profound way. Sometimes things happen to you that may seem horrible,painful, and unfair at first,but in reflection you find that without overcoming those obstacles you would have never realized your potential, strength,willpower, or heart. Everything happens for a reason. Nothing happens by chance or by means of good or bad luck. Illness,injury, love, lost moments of true greatness, and sheer stupidity all occur to test the limits of your soul. Without these small tests, whatever they may be, life would be like a smoothly paved straight flat road to nowhere. It would be safe and comfortable,but dull and utterly pointless.
 The people you meet who affect your life, and the success and downfalls you experience, help to create who you are and who you become. Even the bad experiences can be learned from. In fact, they are sometimes the most important ones. If someone loves you, give love back to them in whatever way you can, not only because they love you, but because in a way, they are teaching you to love and how to open your heart and eyes to things. If someone hurts you, betrays you, or breaks your heart,forgive them, for they have helped you learn about trust and the importance of being cautious to whom you open your heart. Make every day count. Appreciate every moment and take from those moments everything that you possibly can for you may never be able to experience it again. Talk to people that you have never talked to before, and listen to what they have to say. Let yourself fall in love, break free, and set your sights high. Hold your head up because you have every right to. Tell yourself you are a great individual and believe in yourself, for if you don’t believe in yourself, it will be hard for others to believe in you.
"""

class KSwiftyCameraVC: SwiftyCamViewController {

    @IBOutlet weak var captureButton    : KRecordButton!
    @IBOutlet weak var flipCameraButton : UIButton!
    @IBOutlet weak var flashButton      : UIButton!
    @IBOutlet weak var btnSpeak: UIButton!
    @IBOutlet weak var lrcTextView: UITextView!
    @IBOutlet weak var titleLable: UILabel!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var btnLanguage: UIButton!
    
    private var speechRecognizer:SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var lock = NSLock.init()
    private var originText:String = TEXT_COPY_DEFAULT
    private var matchRange:NSRange?
    private var lastMatchRange:NSRange?
    
    private var language:String = "en-US"
    private var languageTitle:String = "English"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        checkAuthor()
    }
    
    private func setupUI() {
        shouldPrompToAppSettings = true
        cameraDelegate = self
        maximumVideoDuration = 10.0
        shouldUseDeviceOrientation = true
        allowAutoRotate = true
        audioEnabled = true
        flashMode = .auto
        flashButton.setImage(#imageLiteral(resourceName: "flashauto"), for: UIControl.State())
        captureButton.buttonEnabled = false
        titleLable.text = ""
        //lrcTextView.text = ""
        lrcTextView.backgroundColor = .clear
        lrcTextView.font = UIFont.systemFont(ofSize: 20)
        
        self.navigationController?.navigationBar.isHidden = true
        btnStart.setImage(UIImage(named: "microphone-icon"), for: .normal)
        
        updateTextRange()
    }
    
    private func updateUI() {
        btnLanguage.setTitle(languageTitle, for: .normal)
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.navigationBar.isHidden = false
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureButton.delegate = self
    }
    
    @IBAction func cameraSwitchTapped(_ sender: Any) {
        switchCamera()
    }
    
    @IBAction func toggleFlashTapped(_ sender: Any) {
        //flashEnabled = !flashEnabled
        toggleFlashAnimation()
    }

    @IBAction func btnCancelClicked(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSpeakClicked(_ sender: Any) {
        //OSSSpeech.shared.recordVoice()
        
    }
    
    @IBAction func btnStartClicked(_ sender: Any) {
        recordButtonTapped()
    }
    
    @IBAction func btnLanguageClicked(_ sender: Any) {
        let vc = KLanguageListTableVC()
        vc.delegate = self
        let nav = NavigationController(rootViewController: vc)
        present(nav, animated: true, completion: nil)
    }
    
    
}

// MARK: -选择语言
extension KSwiftyCameraVC:KLanguageListTableVCDelegate {
    func KLanguageListTableVCDidSelectLanguage(_ language: OSSVoiceEnum) {
        self.language = language.rawValue
        self.languageTitle = language.title
        updateUI()
        stopSpeech()
    }
}

// MARK: SFSpeechRecognizerDelegate
extension KSwiftyCameraVC:SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if available {
            btnStart.isEnabled = true
            changeTip(text: "Start Recording")
        } else {
            btnStart.isEnabled = false
            changeTip(text: "Recognition Not Available")
        }
    }
}

// MARK: -语音识别
extension KSwiftyCameraVC {
    
    private func changeTip(text:String) {
        //titleLable.text = text
        btnStart.setTitle(text, for: .normal)
    }
    
    func recordButtonTapped() {
        if audioEngine.isRunning {
            stopRecording()
        } else {
            restartRecord()
        }
    }
    
    private func restartRecord() {
        do {
            try startRecording()
            //btnRecoginition.setTitle("Stop Recording", for: .normal)
            changeTip(text: "Stop Recording")
            
        } catch {
            //btnRecoginition.setTitle("Recording Not Available", for: .normal)
            changeTip(text: "Recording Not Available")
        }
    }
    
    private func setupSiri() {
        print("重新初始化speechRecognizer：\(language)")
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: language))
        speechRecognizer?.delegate = self
        speechRecognizer?.defaultTaskHint = .dictation
    }
    
    private func updateTextRange() {
        
        let atrStr = NSAttributedString(string: originText)
        let attrTitle = NSMutableAttributedString.init(attributedString: atrStr)
        //let paraStyle = NSMutableParagraphStyle.init()
        //paraStyle.setParagraphStyle(NSParagraphStyle.default)
        //paraStyle.alignment = .center
        //let range = NSMakeRange(0, attrTitle.length)
        //attrTitle.addAttribute(NSAttributedString.Key.paragraphStyle, value: paraStyle, range: range)
        if let matchRange = matchRange {
            attrTitle.addAttribute(.foregroundColor, value: UIColor.red, range: matchRange)
        }
        lrcTextView.attributedText = attrTitle
    }
    
    private func checkAuthor() {
        // Configure the SFSpeechRecognizer object already
        // stored in a local member variable.
        
        // Asynchronously make the authorization request.
        SFSpeechRecognizer.requestAuthorization { authStatus in

            // Divert to the app's main thread so that the UI
            // can be updated.
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.btnStart.isEnabled = true
                    
                case .denied:
                    self.btnStart.isEnabled = false
                    self.changeTip(text: "User denied access to speech recognition")
                    
                case .restricted:
                    self.btnStart.isEnabled = false
                    self.changeTip(text: "Speech recognition restricted on this device")
                    
                case .notDetermined:
                    self.btnStart.isEnabled = false
                    self.changeTip(text: "Speech recognition not yet authorized")
                    
                default:
                    self.btnStart.isEnabled = false
                }
            }
        }
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session for the app.
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        let inputNode = audioEngine.inputNode
        
        // Create and configure the speech recognition request.
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }
        recognitionRequest.shouldReportPartialResults = true
        
        // Keep speech recognition data on device
        if #available(iOS 13, *) {
            recognitionRequest.requiresOnDeviceRecognition = true
        }
        
        //recognitionRequest.requiresOnDeviceRecognition = true
        if speechRecognizer == nil {
            setupSiri()
        }
        
        guard let speechRecognizer = speechRecognizer else {return}
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            
            guard let self = self else {return}
            var isFinal = false
            
            if let result = result {
                self.titleLable.text = result.bestTranscription.formattedString
                print("识别到：\(result.bestTranscription.formattedString)")
                
                DispatchQueue.global().async {
                    self.match(result: result)
                }
                
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                print("error=\(String(describing: error))")
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.btnStart.isEnabled = true
                self.changeTip(text: "Start Recording")
            }
        }
        
        
        // Configure the microphone input.
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer: AVAudioPCMBuffer, when: AVAudioTime) in
            self.recognitionRequest?.append(buffer)
            //print("*****buffer call back ")
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        // Let the user know to start talking.
        //textView.text = "(Go ahead, I'm listening)"
    }
       
       
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        btnStart.isEnabled = false
        changeTip(text: "Stopping")
        
        self.audioEngine.stop()
    }
    
    private func stopSpeech() {
        stopRecording()
        let inputNode = audioEngine.inputNode
        self.audioEngine.stop()
        inputNode.removeTap(onBus: 0)
        
        self.recognitionRequest = nil
        self.recognitionTask = nil
        
        self.btnStart.isEnabled = true
        self.changeTip(text: "Start Recording")
        
        self.speechRecognizer?.delegate = nil
        self.speechRecognizer = nil
    }
    
    private func match(result:SFSpeechRecognitionResult) {

        lock.lock()
        defer { lock.unlock() }
        
        let best = result.bestTranscription
        var j = best.segments.count - 1
        var list = [SFTranscriptionSegment]()
        list.append(contentsOf: best.segments)
        
        let compareStr = originText.replacingOccurrences(of: ",", with: " ").replacingOccurrences(of: ".", with: " ")
        
        let bestTrasnStr = best.formattedString
        
        if let range = compareStr.nsranges(of: bestTrasnStr).first {
            self.matchRange = range
            if let last = self.lastMatchRange, let jiao = range.intersection(last) {
                self.matchRange = range.union(jiao)
            }
            print("🍺0 匹配到: range=\(String(describing: self.matchRange)), bestTrasnStr = \(bestTrasnStr)")
            DispatchQueue.main.async {
                self.updateTextRange()
            }
            self.lastMatchRange = self.matchRange
            return
        }

        while j >= 0 {
             let translate = list.map({ (item) -> String in
                 return item.substring
             }).joined(separator: " ")
             //print("j = \(j),translate = \(translate)")
             let ranges = compareStr.nsranges(of: translate)
             if ranges.count > 0 {
                 
                 if ranges.count == 1 {
                     
                     self.matchRange = ranges.first
                     if let last = self.lastMatchRange,  let current = ranges.first, let jiao = current.intersection(last) {
                         self.matchRange = current.union(jiao)
                     }
                     print("🍺 匹配到: range=\(String(describing: self.matchRange)), translate = \(translate)")
                     DispatchQueue.main.async {
                         self.updateTextRange()
                     }
                     self.lastMatchRange = self.matchRange
                     return
                 }
                 else {
                     ranges.forEach { (item) in
                         //print("***匹配到多个遍历 : range=\(String(describing: item))")
                         if let last = self.lastMatchRange {
                             if let jiao = item.intersection(last) {
                                 self.matchRange = item.union(jiao)
                                 print("🍺🍺🍺1 匹配到: range=\(String(describing: self.matchRange))")
                                 DispatchQueue.main.async {
                                     self.updateTextRange()
                                 }
                                 self.lastMatchRange = self.matchRange
                                 return
                             } else if item.contains(last.location) {
                                 self.matchRange = item
                                 print("🍺🍺🍺2 匹配到: range=\(String(describing: self.matchRange))")
                                 DispatchQueue.main.async {
                                     self.updateTextRange()
                                 }
                                 self.lastMatchRange = self.matchRange
                                 return
                             }
                         }
                     }
                 }
             }
             
             list.removeFirst()
             j = j - 1
         }
                        
    }
}

// UI Animations
extension KSwiftyCameraVC {
    
    fileprivate func hideButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 0.0
            self.flipCameraButton.alpha = 0.0
        }
    }
    
    fileprivate func showButtons() {
        UIView.animate(withDuration: 0.25) {
            self.flashButton.alpha = 1.0
            self.flipCameraButton.alpha = 1.0
        }
    }
    
    fileprivate func focusAnimationAt(_ point: CGPoint) {
        let focusView = UIImageView(image: #imageLiteral(resourceName: "focus"))
        focusView.center = point
        focusView.alpha = 0.0
        view.addSubview(focusView)
        
        UIView.animate(withDuration: 0.25, delay: 0.0, options: .curveEaseInOut, animations: {
            focusView.alpha = 1.0
            focusView.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
        }) { (success) in
            UIView.animate(withDuration: 0.15, delay: 0.5, options: .curveEaseInOut, animations: {
                focusView.alpha = 0.0
                focusView.transform = CGAffineTransform(translationX: 0.6, y: 0.6)
            }) { (success) in
                focusView.removeFromSuperview()
            }
        }
    }
    
    fileprivate func toggleFlashAnimation() {
        //flashEnabled = !flashEnabled
        if flashMode == .auto{
            flashMode = .on
            flashButton.setImage(#imageLiteral(resourceName: "flash"), for: UIControl.State())
        }else if flashMode == .on{
            flashMode = .off
            flashButton.setImage(#imageLiteral(resourceName: "flashOutline"), for: UIControl.State())
        }else if flashMode == .off{
            flashMode = .auto
            flashButton.setImage(#imageLiteral(resourceName: "flashauto"), for: UIControl.State())
        }
    }
}


// MARK: - SwiftyCamViewControllerDelegate
extension KSwiftyCameraVC:SwiftyCamViewControllerDelegate {
    func swiftyCamSessionDidStartRunning(_ swiftyCam: SwiftyCamViewController) {
        print("Session did start running")
        captureButton.buttonEnabled = true
    }
    
    func swiftyCamSessionDidStopRunning(_ swiftyCam: SwiftyCamViewController) {
        print("Session did stop running")
        captureButton.buttonEnabled = false
    }
    

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didTake photo: UIImage) {
        let newVC = KPictureDisplayVC(image: photo)
        self.present(newVC, animated: true, completion: nil)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didBeginRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did Begin Recording")
        captureButton.growButton()
        hideButtons()
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishRecordingVideo camera: SwiftyCamViewController.CameraSelection) {
        print("Did finish Recording")
        captureButton.shrinkButton()
        showButtons()
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFinishProcessVideoAt url: URL) {
        let newVC = KVideoDisplayVC(videoURL: url)
        self.present(newVC, animated: true, completion: nil)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFocusAtPoint point: CGPoint) {
        print("Did focus at point: \(point)")
        focusAnimationAt(point)
    }
    
    func swiftyCamDidFailToConfigure(_ swiftyCam: SwiftyCamViewController) {
        let message = NSLocalizedString("Unable to capture media", comment: "Alert message when something goes wrong during capture session configuration")
        let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didChangeZoomLevel zoom: CGFloat) {
        print("Zoom level did change. Level: \(zoom)")
        print(zoom)
    }

    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didSwitchCameras camera: SwiftyCamViewController.CameraSelection) {
        print("Camera did change to \(camera.rawValue)")
        print(camera)
    }
    
    func swiftyCam(_ swiftyCam: SwiftyCamViewController, didFailToRecordVideo error: Error) {
        print(error)
    }

}
