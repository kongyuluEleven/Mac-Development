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

class ViewController: NSViewController, SFSpeechRecognizerDelegate {
    
    private let speechKit = OSSSpeech.shared

    @IBOutlet weak var microphoneButton: NSButton!
    
    @IBOutlet weak var speakToTextButton: NSButton!
    
    @IBOutlet weak var textToSpeakButton: NSButton!
    
    @IBOutlet weak var lrcButton: NSButton!
    
    @IBOutlet weak var leftScrollView: NSScrollView!
    // Is the app listening flag
    var isListening = false
    
    @IBOutlet weak var languageTableView: FMTableView!
    private var currentRow:Int = 0
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    @IBOutlet weak var recordButton: NSButton!
    @IBOutlet var textView: NSTextView!
    
    
    private lazy var lrcVC: KLrcController = {
       let vc = KLrcController()
       return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        recordButton.isEnabled = false
        microphoneButton.isEnabled = false
        speakToTextButton.isHidden = true
        textToSpeakButton.isHidden = true
        
        recordButton.title = "Start Recording"
        
        checkAuthor()
        
        speechKit.delegate = self
        speechRecognizer.delegate = self
        
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
        let rect = leftScrollView.frame
        lrcVC.view.frame = CGRect(x: rect.origin.x + rect.size.width, y: rect.origin.y, width: view.frame.width - rect.size.width, height: rect.height)
        self.view.addSubview(lrcVC.view)
        
        setupLanguageTableView()
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
        //self.clickLocate(sender)
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
           
           // Create a recognition task for the speech recognition session.
           // Keep a reference to the task so that it can be canceled.
//        @NSCopying open var bestTranscription: SFTranscription { get }
//        // Hypotheses for possible transcriptions, sorted in decending order of confidence (more likely first)
//        open var transcriptions: [SFTranscription] { get }
//        // True if the hypotheses will not change; speech processing is complete.
//        open var isFinal: Bool { get }
           recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { result, error in
               var isFinal = false
               
               if let result = result {
                   // Update the text view with the results.
                   self.textView.string = result.bestTranscription.formattedString
                
                   isFinal = result.isFinal
                   print("Text \(result.bestTranscription.formattedString)")
                
                   
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


//// Called when the task first detects speech in the source audio
//- (void)speechRecognitionDidDetectSpeech:(SFSpeechRecognitionTask *)task;
//
//// Called for all recognitions, including non-final hypothesis
//- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didHypothesizeTranscription:(SFTranscription *)transcription;
//
//// Called only for final recognitions of utterances. No more about the utterance will be reported
//- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishRecognition:(SFSpeechRecognitionResult *)recognitionResult;
//
//// Called when the task is no longer accepting new audio but may be finishing final processing
//- (void)speechRecognitionTaskFinishedReadingAudio:(SFSpeechRecognitionTask *)task;
//
//// Called when the task has been cancelled, either by client app, the user, or the system
//- (void)speechRecognitionTaskWasCancelled:(SFSpeechRecognitionTask *)task;
//
//// Called when recognition of all requested utterances is finished.
//// If successfully is false, the error property of the task will contain error information
//- (void)speechRecognitionTask:(SFSpeechRecognitionTask *)task didFinishSuccessfully:(BOOL)successfully;

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

