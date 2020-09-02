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
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    
    private var recognitionTask: SFSpeechRecognitionTask?
    
    private let audioEngine = AVAudioEngine()
    
    @IBOutlet weak var recordButton: NSButton!
    @IBOutlet var textView: NSTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        recordButton.isEnabled = false
        microphoneButton.isEnabled = false
        speakToTextButton.isHidden = true
        textToSpeakButton.isHidden = true
        
        recordButton.title = "Start Recording"
        
        checkAuthor()
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
               print("*****buffer call back ")
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
        let text = "孔雨露";
        let voiceType: VoiceType = .standardMale
        KGoogleSpeechService.shared.speak(text: text, voiceType: voiceType) {

        }
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

