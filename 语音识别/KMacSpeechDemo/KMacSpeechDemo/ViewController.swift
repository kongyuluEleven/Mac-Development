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
let TEST_URL = "http://m.kekenet.com/menu/201206/185740.shtml"

let HOLDE_PLACE_TEXT = "请在此处输入你想要跟踪失败的文字，然后点击《拷贝》按钮"

let TEXT_COPY_DEFAULT = """
 Passage 37. Life Lessons
 Sometimes people come into your life and you know right away that they were meant to be there,
 to serve some sort of purpose,teach you a lesson, or to help you figure out who you are or who you want to become. You never know who these people may be—a roommate, a neighbor, a professor, a friend, a lover, or even a complete stranger—but when you lock eyes with them,you know at that very moment they will affect your life in some profound way. Sometimes things happen to you that may seem horrible,painful, and unfair at first,but in reflection you find that without overcoming those obstacles you would have never realized your potential, strength,willpower, or heart. Everything happens for a reason. Nothing happens by chance or by means of good or bad luck. Illness,injury, love, lost moments of true greatness, and sheer stupidity all occur to test the limits of your soul. Without these small tests, whatever they may be, life would be like a smoothly paved straight flat road to nowhere. It would be safe and comfortable,but dull and utterly pointless.
 The people you meet who affect your life, and the success and downfalls you experience, help to create who you are and who you become. Even the bad experiences can be learned from. In fact, they are sometimes the most important ones. If someone loves you, give love back to them in whatever way you can, not only because they love you, but because in a way, they are teaching you to love and how to open your heart and eyes to things. If someone hurts you, betrays you, or breaks your heart,forgive them, for they have helped you learn about trust and the importance of being cautious to whom you open your heart. Make every day count. Appreciate every moment and take from those moments everything that you possibly can for you may never be able to experience it again. Talk to people that you have never talked to before, and listen to what they have to say. Let yourself fall in love, break free, and set your sights high. Hold your head up because you have every right to. Tell yourself you are a great individual and believe in yourself, for if you don’t believe in yourself, it will be hard for others to believe in you.
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
    private var lastMatchRange:NSRange?
    var isListening = false
    private var currentRow:Int = 0
    private var originText:String = TEXT_COPY_DEFAULT
    @IBOutlet weak var labelLanguage: NSTextField!
    
    private var speechRecognizer:SFSpeechRecognizer?
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var lock = NSLock.init()
    
    private lazy var lrcVC: KLrcController = {
       let vc = KLrcController()
       return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkAuthor()
        
        speechKit.delegate = self
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
        speechRecognizer?.delegate = self
        speechRecognizer?.defaultTaskHint = .dictation
        
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
        
 //       speechKit.recordVoice()
        
//        lrcVC.reloadData()
//        lrcVC.play()
        let text = middleTextView.string
        guard !text.isEmpty, text.count > 1, text != HOLDE_PLACE_TEXT else {
            middleTextView.string = HOLDE_PLACE_TEXT
            return
        }
        originText = text
        topTextView.string = ""
        updateTextRange()
        middleTextView.string = ""
        
    }
    
}

extension ViewController {
    
    private func setupUI() {
        recordButton.isEnabled = false
        microphoneButton.isEnabled = false
        recordButton.title = "Start Recording"
        
//        let rect = middleScrollView.frame
//        lrcVC.view.frame = CGRect(x: rect.origin.x + rect.size.width, y: rect.origin.y, width: view.frame.width - rect.size.width, height: rect.height)
//        self.view.addSubview(lrcVC.view)
        
        setupLanguageTableView()
        setupTextView()
        
        labelLanguage.stringValue = "当前语言：英语"
        
        middleTextView.string = HOLDE_PLACE_TEXT
    }
    
    private func setupTextView() {
        textView.isEditable = false
        updateTextRange()
    }
    
    private func updateTextRange() {
        topTextView.string = ""
        let atrStr = NSAttributedString(string: originText)
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
        let columnsTiles: [String] = ["选择语言", "国家"]
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
        
        recognitionRequest.requiresOnDeviceRecognition = false
        
        guard let speechRecognizer = speechRecognizer else {return}
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
            var isFinal = false
            
            if let result = result {
                //NotificationCenter.default.post(name: NSNotification.Name.init("ReconitionResultNotification"), object: result)
                
//                self.lrcVC.match(recognitionRes: result)
                self.textView.string = result.bestTranscription.formattedString
                
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
               stopRecording()
           } else {
               do {
                   try startRecording()
                   recordButton.title = "Stop Recording"
               } catch {
                   recordButton.title = "Recording Not Available"
               }
           }
       }
    
    private func stopRecording() {
        audioEngine.stop()
        recognitionRequest?.endAudio()
        recordButton.isEnabled = false
        recordButton.title = "Stopping"
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
        if let cell  = tableColumn.dataCell(forRow: currentRow) as? MissFileCellView {
            cell.labelView?.textColor = .red
        }
        tableView.scrollRowToVisible(currentRow)
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
        
        stopRecording()
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: OSSVoiceEnum.allCases[row].rawValue))
        speechRecognizer?.delegate = self
        speechRecognizer?.defaultTaskHint = .dictation
        
        self.recordButton.isEnabled = true
        self.recordButton.title = "Start Recording"
        
        tableView.reloadData()
        tableView.scrollRowToVisible(row)
        
        labelLanguage.stringValue = "Language：\(OSSVoiceEnum.allCases[row].title)"
        
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

