//
//  KSiriVC.swift
//  KLrcCamera
//
//  Created by kongyulu on 2020/9/9.
//

import UIKit
import Speech

let TEST_URL = "http://m.kekenet.com/menu/201206/185740.shtml"

let HOLDE_PLACE_TEXT = "请在此处输入你想要跟踪失败的文字，然后点击《拷贝》按钮"

let TEXT_COPY_DEFAULT = """
 Passage 37. Life Lessons
 Sometimes people come into your life and you know right away that they were meant to be there,
 to serve some sort of purpose,teach you a lesson, or to help you figure out who you are or who you want to become. You never know who these people may be—a roommate, a neighbor, a professor, a friend, a lover, or even a complete stranger—but when you lock eyes with them,you know at that very moment they will affect your life in some profound way. Sometimes things happen to you that may seem horrible,painful, and unfair at first,but in reflection you find that without overcoming those obstacles you would have never realized your potential, strength,willpower, or heart. Everything happens for a reason. Nothing happens by chance or by means of good or bad luck. Illness,injury, love, lost moments of true greatness, and sheer stupidity all occur to test the limits of your soul. Without these small tests, whatever they may be, life would be like a smoothly paved straight flat road to nowhere. It would be safe and comfortable,but dull and utterly pointless.
 The people you meet who affect your life, and the success and downfalls you experience, help to create who you are and who you become. Even the bad experiences can be learned from. In fact, they are sometimes the most important ones. If someone loves you, give love back to them in whatever way you can, not only because they love you, but because in a way, they are teaching you to love and how to open your heart and eyes to things. If someone hurts you, betrays you, or breaks your heart,forgive them, for they have helped you learn about trust and the importance of being cautious to whom you open your heart. Make every day count. Appreciate every moment and take from those moments everything that you possibly can for you may never be able to experience it again. Talk to people that you have never talked to before, and listen to what they have to say. Let yourself fall in love, break free, and set your sights high. Hold your head up because you have every right to. Tell yourself you are a great individual and believe in yourself, for if you don’t believe in yourself, it will be hard for others to believe in you.
"""

class KSiriVC: UIViewController {

    @IBOutlet weak var btnRecoginition: UIButton!
    @IBOutlet weak var btnSelectLanguage: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var labelTitile1: UILabel!
    
    @IBOutlet weak var labelTitle2: UILabel!
    @IBOutlet weak var textView2: UITextView!
    private var speechRecognizer:SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var lock = NSLock.init()
    private var originText:String = TEXT_COPY_DEFAULT
    private var matchRange:NSRange?
    private var lastMatchRange:NSRange?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        btnRecoginition.setTitle("开始识别", for: .normal)
        textView.text = ""
        textView2.text = originText
        labelTitile1.text = "识别到结果:"
        labelTitle2.text = "识别匹配文字:"
        
        updateTextRange()
    }


    @IBAction func btnSelectLanguageClicked(_ sender: Any) {
        self.navigationController?.pushViewController(KLanguageTableVC(), animated: true)
    }
    
    @IBAction func btnRecoginitionClicked(_ sender: Any) {
        print("\(#function)")
        recordButtonTapped()
    }
    
}

extension KSiriVC {
    
    func recordButtonTapped() {
        if audioEngine.isRunning {
            stopRecording()
        } else {
            do {
                try startRecording()
                btnRecoginition.setTitle("Stop Recording", for: .normal)
            } catch {
                btnRecoginition.setTitle("Recording Not Available", for: .normal)
            }
        }
    }
    
    private func setupSiri() {
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        //speechRecognizer?.delegate = self
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
        textView.attributedText = attrTitle
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
                    self.btnRecoginition.isEnabled = true
                    
                case .denied:
                    self.btnRecoginition.isEnabled = false
                    self.btnRecoginition.setTitle("User denied access to speech recognition", for: .normal)
                    
                    
                case .restricted:
                    self.btnRecoginition.isEnabled = false
                    self.btnRecoginition.setTitle("Speech recognition restricted on this device", for: .normal)
                    
                    
                case .notDetermined:
                    self.btnRecoginition.isEnabled = false
                    self.btnRecoginition.setTitle("Speech recognition not yet authorized", for: .normal)
                    
                default:
                    self.btnRecoginition.isEnabled = false
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
            recognitionRequest.requiresOnDeviceRecognition = false
        }
        
        recognitionRequest.requiresOnDeviceRecognition = true
        
        guard let speechRecognizer = speechRecognizer else {return}
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                //NotificationCenter.default.post(name: NSNotification.Name.init("ReconitionResultNotification"), object: result)
                
                //                self.lrcVC.match(recognitionRes: result)
                self.textView.text = result.bestTranscription.formattedString
                print("识别到：\(result.bestTranscription.formattedString)")
                
                DispatchQueue.global().async {
                    self.match(result: result)
                }
                
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.btnRecoginition.isEnabled = true
                self.btnRecoginition.setTitle("Start Recording", for: .normal)
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
        textView.text = "(Go ahead, I'm listening)"
    }
       
       // MARK: SFSpeechRecognizerDelegate
       
       public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
           if available {
            btnRecoginition.isEnabled = true
            btnRecoginition.setTitle("Start Recording", for: .normal)
           } else {
            btnRecoginition.isEnabled = false
            btnRecoginition.setTitle("Recognition Not Available", for: .normal)
           }
       }
       

    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        btnRecoginition.isEnabled = false
        btnRecoginition.setTitle("Stopping", for: .normal)
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
 
                       
        //                print("**** formattedString = \(best.formattedString), transcriptions = \(result.transcriptions.count),segments=\(best.segments.count),speakingRate=\(best.speakingRate),averagePauseDuration=\(best.averagePauseDuration)")
        //
        //                best.segments.forEach { (seg) in
        //                    print("\n\t\t\t sub=\(seg.substring), range=\(seg.substringRange)  \n")
        //                    let kmp = GMatcherExpression(pattern:seg.substring, option: .KMP)
        //                    if let matchArr = kmp?.matches(in: TEXT_COPY) {
        //                        print("\n\t\t\t\t matchArr count=\(matchArr.count), first = \(String(describing: matchArr.first))")
        //                        //self.lrcVC.match(subString: seg.substring)
        //                    }
        //                }
        //
        //
        //                let kmp = GMatcherExpression(pattern: result.bestTranscription.formattedString, option: .KMP)
        //                if let matchArr = kmp?.matches(in: TEXT_COPY) {
        //                    print("\n\t\t\t\t matchArr count=\(matchArr.count), first = \(String(describing: matchArr.first))")
        //                    if let first = matchArr.first {
        //
        //                    }
        //                }
                        
    }
}
