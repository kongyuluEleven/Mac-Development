//
//  ViewController.swift
//  KMacSpeechDemo
//
//  Created by kongyulu on 2020/8/21.
//  Copyright © 2020 wondershare. All rights reserved.
//

import Cocoa
import Speech
import AVFoundation

//let TEST_URL = "https://developer.apple.com/videos/play/wwdc2020/10074/"
let TEST_URL = "http://m.kekenet.com/menu/201207/188787.shtml###"

let TEXT_COPY = """
  
 Passage 55. Stress and Relaxation
 It is commonly believed that only rich middle-aged businessmen suffer from stress. In fact anyone may become ill as a result of stress if they experience a lot of worry over a long period and their health is not especially good. Stress can be a friend or an enemy: it can warn you that you are under too much pressure and should change your way of life.
 It can kill you if you don't notice the warning signals. Doctors agree that it is probably the biggest single cause of illness in the Western world. When we are very frightened and worried our bodies produce certain chemicals to help us fight what is troubling us.
 Unfortunately, these chemicals produce the energy needed to run away fast from an object of fear, and in modern life that's often impossible. If we don't use up these chemicals, or if we produce too many of them, they may actually harm us. The parts of the body that are most affected by stress are the stomach, heart,skin, head and back.
 Stress can cause car accidents, heart attacks, and alcoholism, and may even drive people to suicide. Our living and working conditions may put us under stress. Overcrowding in large cities, traffic jams, competition for jobs, worry about the future, any big changes in our lives, may cause stress. Some British doctors have pointed out that one of Britain's worst waves of influenza happened soon after the new coins came into use. Also if you have changed jobs or moved house in recent months you are more likely to fall ill than if you haven't. And more people commit suicide in times of inflation. As with all illnesses, prevention is better than cure. If you find you can't relax, it is a sign of danger. "When you're taking work home, when you can't enjoy an evening with friends, when you haven't time for outdoor exercise—that is the time to stop and ask yourself whether your present life really suits you." Says one family doctor. " Then it's time to join a relaxation class, or take up dancing, painting or gardening."

"""

class ViewController: NSViewController, SFSpeechRecognizerDelegate {
    
    private let speechKit = OSSSpeech.shared
    @IBOutlet weak var microphoneButton: NSButton!
    @IBOutlet weak var lrcButton: NSButton!
    @IBOutlet weak var topScrollView: NSScrollView!
    @IBOutlet var topTextView: NSTextView!
    @IBOutlet weak var middleScrollView: NSScrollView!
    @IBOutlet var middleTextView: NSTextView!
    @IBOutlet weak var leftScrollView: NSScrollView!
    @IBOutlet weak var languageTableView: FMTableView!
    @IBOutlet weak var recordButton: NSButton!
    @IBOutlet var textView: NSTextView!
    
    private var matchRange:NSRange?
    var isListening = false
    private var currentRow:Int = 0

    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    private lazy var lrcVC: KLrcController = {
       let vc = KLrcController()
       return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAuthor()
        
        speechKit.delegate = self
        speechRecognizer.delegate = self
        speechRecognizer.defaultTaskHint = .dictation
        
        setupUI()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
    
  
    @IBAction func speakToTextClicked(_ sender: Any) {
        checkAuthor()
        testAVSpeech()
    }
    
    
    @IBAction func textToSpeakClicked(_ sender: Any) {
        speechToText()
    }
    
    @IBAction func btnRecordClicked(_ sender: Any) {
        if microphoneButton.contentTintColor == .red {
            speechKit.endVoiceRecording()
            return
        }
        microphoneButton.contentTintColor = .red
    }
    
    @IBAction func recordButtonClicked(_ sender: Any) {
        recordButtonTapped()
    }
    
    @IBAction func lrcButtonClicked(_ sender: Any) {
        
        speechKit.recordVoice()
        
//        lrcVC.reloadData()
//        lrcVC.play()
        
    }
    

}

extension ViewController {
    
    private func setupUI() {
        recordButton.isEnabled = false
        microphoneButton.isEnabled = false
        recordButton.title = "Start Recording"
        
        let rect = middleScrollView.frame
        lrcVC.view.frame = CGRect(x: rect.origin.x + rect.size.width, y: rect.origin.y, width: view.frame.width - rect.size.width, height: rect.height)
        self.view.addSubview(lrcVC.view)
        
        setupLanguageTableView()
        setupTextView()
    }
    
    private func setupTextView() {
        textView.isEditable = false
        updateTextRange()
    }
    
    private func updateTextRange() {
        let atrStr = NSAttributedString(string: TEXT_COPY)
        let attrTitle = NSMutableAttributedString.init(attributedString: atrStr)
        //let paraStyle = NSMutableParagraphStyle.init()
        //paraStyle.setParagraphStyle(NSParagraphStyle.default)
        //paraStyle.alignment = .center
        let range = NSMakeRange(0, attrTitle.length)
        //attrTitle.addAttribute(NSAttributedString.Key.paragraphStyle, value: paraStyle, range: range)
        if let matchRange = matchRange {
            attrTitle.addAttribute(.foregroundColor, value: Color.red, range: matchRange)
        }
        topTextView.insertText(attrTitle, replacementRange: range)
    }
    
    private func setupLanguageTableView() {

        languageTableView.delegate = self
        languageTableView.dataSource = self
        languageTableView.gridColor = fm_base_bk_color
        languageTableView.doubleAction = #selector(clickLocateMissingFiles(_:))
        
        languageTableView.allowsColumnResizing = true
        let columnsTiles: [String] = ["语言", "描述"]
        for index in 0..<languageTableView.tableColumns.count {
            languageTableView.tableColumns[index].isEditable = false
            languageTableView.tableColumns[index].headerCell.stringValue = columnsTiles[index]
            languageTableView.tableColumns[index].headerCell.backgroundColor = NSColor.init(rgb: 0x67DDCF)
            let oldHeaderCell = languageTableView.tableColumns[index].headerCell
            languageTableView.tableColumns[index].headerCell = FMTableHeaderCell.init(textCell: oldHeaderCell.stringValue)
            languageTableView.tableColumns[index].headerCell.textColor = fm_base_bk_color
            languageTableView.tableColumns[index].headerCell.drawsBackground = false
        }
        languageTableView.allowsColumnSelection = false
    }
    
    @objc func clickLocateMissingFiles(_ sender: Any) {
        if sender as? FSButton != nil {
            languageTableView.selectRowIndexes(IndexSet.init(integer: (sender as! FSButton).tag), byExtendingSelection: false)
        }
    }
}

extension ViewController {
    
    private func checkAuthor() {
        // Configure the SFSpeechRecognizer object already
        // stored in a local member variable.
        speechRecognizer.delegate = self
        
        // Asynchronously make the authorization request.
        SFSpeechRecognizer.requestAuthorization { authStatus in

            // Divert to the app's main thread so that the UI
            // can be updated.
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    self.recordButton.isEnabled = true
                    
                case .denied:
                    self.recordButton.isEnabled = false
                    self.recordButton.title = "User denied access to speech recognition"
                    
                    
                case .restricted:
                    self.recordButton.isEnabled = false
                    self.recordButton.title = "Speech recognition restricted on this device"
                    
                    
                case .notDetermined:
                    self.recordButton.isEnabled = false
                    self.recordButton.title = "Speech recognition not yet authorized"
                    
                default:
                    self.recordButton.isEnabled = false
                }
            }
        }
    }
    
    private func startRecording() throws {
        
        // Cancel the previous task if it's running.
        recognitionTask?.cancel()
        self.recognitionTask = nil
        
        // Configure the audio session for the app.
        //           let audioSession = AVAudioSession.sharedInstance()
        //           try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        //           try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
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
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                //NotificationCenter.default.post(name: NSNotification.Name.init("ReconitionResultNotification"), object: result)
                
//                self.lrcVC.match(recognitionRes: result)

                isFinal = result.isFinal
                let best = result.bestTranscription
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
                
                self.textView.string = self.textView.string + "\n\n" + result.bestTranscription.formattedString
                
                
                var j = best.segments.count - 1
                var list = [SFTranscriptionSegment]()
                list.append(contentsOf: best.segments)
                
                let compareStr = TEXT_COPY.replacingOccurrences(of: ",", with: " ").replacingOccurrences(of: ".", with: " ")
                
                while j > 0 {
                    let translate = list.map({ (item) -> String in
                        return item.substring
                    }).joined(separator: " ")
                    print("j = \(j),translate = \(translate)")
                    
                    //let range1 = compareStr.ranges(of: translate)
                    if let matchRange = compareStr.nsranges(of: translate).first {
                        print("🍺 匹配到: range=\(matchRange), translate = \(translate)")
                        self.matchRange = matchRange
                        self.updateTextRange()
                        return
                    }
                    
                    list.removeFirst()
                    j = j - 1
                }
                
            }
            
            if error != nil || isFinal {
                // Stop recognizing speech if there is a problem.
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
                
                self.recordButton.isEnabled = true
                self.recordButton.title = "Start Recording"
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
        textView.string = "(Go ahead, I'm listening)"
    }
       
       // MARK: SFSpeechRecognizerDelegate
       
       public func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
           if available {
               recordButton.isEnabled = true
               recordButton.title = "Start Recording"
           } else {
               recordButton.isEnabled = false
               recordButton.title = "Recognition Not Available"
           }
       }
       
       // MARK: Interface Builder actions
       
    func recordButtonTapped() {
           if audioEngine.isRunning {
               audioEngine.stop()
               recognitionRequest?.endAudio()
               recordButton.isEnabled = false
               recordButton.title = "Stopping"
           } else {
               do {
                   try startRecording()
                   recordButton.title = "Stop Recording"
               } catch {
                   recordButton.title = "Recording Not Available"
               }
           }
       }
}

extension ViewController {
    private func textToSpeech() {
        
    }
    
    private func speechToText() {
//        let text = "孔雨露";
//        let voiceType: VoiceType = .standardMale
//        KGoogleSpeechService.shared.speak(text: text, voiceType: voiceType) {
//
//        }
        
        speechKit.recordVoice()
    }
    
    private func textToSpeakSiri() {
        let item = OSSVoiceEnum.allCases[0]
        speechKit.voice = OSSVoice(quality: .enhanced, language: item)
        speechKit.utterance?.rate = 0.45
        // Test attributed string vs normal string
        let attributedString = NSAttributedString(string: item.demoMessage)
        speechKit.speakAttributedText(attributedText: attributedString)
    }
    
    private func testAVSpeech() {
        let speech = KAVSpeech()
         speech.speed = 0.5
         speech.speakWords = "测试语音功能"
         speech.start()
    }
}

extension ViewController:NSTableViewDelegate {
    
    func tableView(_ tableView: NSTableView, didClick tableColumn: NSTableColumn) {
        
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        speechKit.voice = OSSVoice(quality: .enhanced, language: OSSVoiceEnum.allCases[row])
        speechKit.utterance?.rate = 0.45
        // Test attributed string vs normal string
        if row % 2 == 0 {
            speechKit.speakText(OSSVoiceEnum.allCases[row].demoMessage)
        } else {
            let attributedString = NSAttributedString(string: OSSVoiceEnum.allCases[row].demoMessage)
            speechKit.speakAttributedText(attributedText: attributedString)
        }
        
        currentRow = row
        return true
    }
    
}

extension ViewController:NSTableViewDataSource {
    public func numberOfRows(in tableView: NSTableView) -> Int {
           let count = OSSVoiceEnum.allCases.count
           return count
       }
       
       func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
           
           let cellView: MissFileCellView = MissFileCellView.init(frame: NSMakeRect(0, 0, tableView.frame.size.width, 40))
           cellView.autoresizingMask = [NSView.AutoresizingMask.maxXMargin, NSView.AutoresizingMask.minXMargin, NSView.AutoresizingMask.width]
           
           guard let tableColumn = tableColumn else {
               return cellView
           }
           
           if let columnIndex = tableView.tableColumns.index(of: tableColumn) {
               switch columnIndex {
               case 0:
                   cellView.labelView = FMIconTextField.init(frame: cellView.bounds)
                   cellView.labelView?.stringValue = OSSVoiceEnum.allCases[row].title
                   cellView.buttonView?.image = OSSVoiceEnum.allCases[row].flag
                   
                   cellView.labelView?.lineBreakMode = .byCharWrapping
                   cellView.labelView?.alignment = .center
                   if currentRow == row {
                       cellView.labelView?.textColor = .green
                   } else {
                       cellView.labelView?.textColor = .white
                   }
                   
               case 1:
                   cellView.buttonView = FSButton.init(frame: cellView.bounds)
                   cellView.buttonView?.tag = row
                   //cellView.buttonView.
                   cellView.labelView?.stringValue = OSSVoiceEnum.allCases[row].title
                   //cellView.labelView?.stringValue = OSSVoiceEnum.allCases[row].demoMessage
                   cellView.buttonView?.image = OSSVoiceEnum.allCases[row].flag
                   cellView.buttonView?.isHidden = false
                   cellView.labelView?.lineBreakMode = .byCharWrapping
                   cellView.labelView?.alignment = .center
                   if currentRow == row {
                       cellView.labelView?.textColor = .green
                   } else {
                       cellView.labelView?.textColor = .white
                   }
                   
               default:
                   break
               }
           }
           
           return cellView
       }
       
       func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
           let frame: NSRect = NSMakeRect(0, 0, tableView.frame.size.width, tableView.frame.size.height)
           let rowView: FMTableRowView = FMTableRowView.init(frame:frame)

           let evenColor = NSColor.init(rgb: 0x242B33)
           let oddColor = NSColor.init(rgb: 0x2A313A)
           rowView.bkColor = (0 == row % 2) ? evenColor : oddColor
           return rowView
       }
       
       func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
           return 40
       }
    
    @objc func cellIconButtonClicked(sender:Any) {
        
    }
}

extension ViewController:OSSSpeechDelegate {
    func didCompleteTranslation(withText text: String) {
        print("Translation completed: \(text)")
    }
    
    func didFailToProcessRequest(withError error: Error?) {
        guard let err = error else {
            print("Error with the request but the error returned is nil")
            return
        }
        print("Error with the request: \(err)")
    }
    
    func authorizationToMicrophone(withAuthentication type: OSSSpeechKitAuthorizationStatus) {
        print("Authorization status has returned: \(type.message).")
    }
    
    func didFailToCommenceSpeechRecording() {
        print("Failed to record speech.")
    }
    
    func didFinishListening(withText text: String) {
        weak var weakSelf = self
        OperationQueue.main.addOperation {
            weakSelf?.speechKit.speakText(text)
        }
    }
}

extension ViewController:SFSpeechRecognitionTaskDelegate {
    // MARK: - SFSpeechRecognitionTaskDelegate Methods
       
       /// Docs available by Google searching for SFSpeechRecognitionTaskDelegate
       public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishSuccessfully successfully: Bool) {
           print("\(#function)")
       }
       
       /// Docs available by Google searching for SFSpeechRecognitionTaskDelegate
       public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didHypothesizeTranscription transcription: SFTranscription) {
           print("\(#function), transcription=\(transcription.formattedString)")
       }
       
       /// Docs available by Google searching for SFSpeechRecognitionTaskDelegate
       public func speechRecognitionTask(_ task: SFSpeechRecognitionTask, didFinishRecognition recognitionResult: SFSpeechRecognitionResult) {
           print("\(#function)")
       }
       
       public func speechRecognitionDidDetectSpeech(_ task: SFSpeechRecognitionTask) {
           print("\(#function)")
       }
       
       public func speechRecognitionTaskFinishedReadingAudio(_ task: SFSpeechRecognitionTask) {
           print("\(#function)")
       }
       
}

