//
//  KAVSpeech.swift
//  KMacSpeechDemo
//
//  Created by kongyulu on 2020/8/24.
//  Copyright © 2020 wondershare. All rights reserved.
//

import Foundation
import AVFoundation

protocol SpeechDelegate {
    func didStart(speech: KAVSpeech)
    func didFinish(speech: KAVSpeech)
    func didPause(speech: KAVSpeech)
    func didContinue(speech: KAVSpeech)
    func didCancel(speech: KAVSpeech)
    func speechSpeakRange(speech: KAVSpeech, range: NSRange)
}

class KAVSpeech: NSObject {
    
    //读字速度 0-1
    public var speed: Float = 0.5 {
        didSet {
            reset()
        }
    }
    //音色
    public var pitchMultiplier: Float = 1 {
        didSet {
            reset()
        }
    }
    //音量大小 0-1
    public var volume: Float = 1
    //读一段话前停顿
    public var preDelay: TimeInterval = 0 {
        didSet {
            reset()
        }
    }
    //读一段话后停顿
    public var postDelay: TimeInterval = 0 {
        didSet {
            reset()
        }
    }
    //重复次数
    public var repeatCount: Int = 1 {
        didSet {
            if let current = currentRepeatCount {
                if repeatCount < current {
                    currentRepeatCount = 1
                } else {
                    currentRepeatCount = repeatCount - current
                }
            }
        }
    }
    //内容
    public var speakWords: String? {
        didSet {
            if let speakWords = speakWords {
                currentSpeakWords = speakWords
                startToSpeak()
            }
        }
    }
    
    fileprivate var speechSynthier: AVSpeechSynthesizer!
    fileprivate var speechUtterance: AVSpeechUtterance!
    fileprivate var speechVoice: AVSpeechSynthesisVoice! = {
       return AVSpeechSynthesisVoice(language: "zh_CN")
    }()
    fileprivate var currentSpeakIndex: Int?
    fileprivate var currentSpeakWords: String?
    fileprivate var currentRepeatCount: Int?
    fileprivate var isComplete: Bool = false
    fileprivate var isPause: Bool = false
    
    public var delegate: SpeechDelegate?
    
    override init() {
        super.init()
        setDefault()
    }
    
    fileprivate func setDefault() {
        speechSynthier = AVSpeechSynthesizer()
        speechSynthier.delegate = self
        self.pitchMultiplier = 1
        self.preDelay = 0
        self.postDelay = 0
        self.speed = 0.5
        self.volume = 1
        self.repeatCount = 1
        currentSpeakIndex = self.repeatCount
        isPause = true
    }
    
    private func subString(string: String) -> String {
        let head = string.range(of: "http")
        let end = string.range(of: "html")
        let headIndex = string.index((head?.lowerBound)!, offsetBy: -1)
        let endIndex = string.index((end?.upperBound)!, offsetBy: 1)
        return string.substring(with: headIndex..<endIndex)
    }
    
    public func reset() {
        
        guard self.isComplete else {
            return
        }
        self.isComplete = false
        if let wordsTemp = currentSpeakWords {
            let words = NSString(string: wordsTemp)
            let lenght = words.length
            currentSpeakWords = words.substring(with: NSMakeRange(currentSpeakIndex!, lenght - currentSpeakIndex!))
            startToSpeak()
        }
        
    }
    
    
    public func start() {
        currentRepeatCount = self.repeatCount
        isPause = false
        startToSpeak()
    }
    
    public func stop() {
        currentRepeatCount = 1
        speechSynthier.stopSpeaking(at: AVSpeechBoundary.word)
    }
    
    public func pause() -> Bool {
        isPause = true
        return speechSynthier.pauseSpeaking(at: AVSpeechBoundary.word)
    }
    
    public func continueSpeak() {
        isPause = false
        speechSynthier.continueSpeaking()
    }
    
    fileprivate func startToSpeak() {
        speechSynthier.stopSpeaking(at: AVSpeechBoundary.immediate)
        guard let _ = currentSpeakWords else {
            return
        }
        speechSynthier.speak(speechUtterance(speakWords: currentSpeakWords!))
    }
    
    fileprivate func speechUtterance(speakWords: String) -> AVSpeechUtterance {
        speechUtterance = AVSpeechUtterance(string: speakWords)
        speechUtterance.rate = speed
        speechUtterance.pitchMultiplier = pitchMultiplier
        speechUtterance.postUtteranceDelay = postDelay
        speechUtterance.preUtteranceDelay = preDelay
        speechUtterance.volume = volume
        speechUtterance.voice = speechVoice
        return speechUtterance
    }
    
}

extension KAVSpeech: AVSpeechSynthesizerDelegate {
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didStart utterance: AVSpeechUtterance) {
        self.delegate?.didStart(speech: self)
        isComplete = true
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if currentRepeatCount == 1 {
            self.delegate?.didFinish(speech: self)
            currentRepeatCount = 1
        } else {
            currentSpeakWords = self.speakWords
            currentRepeatCount = currentRepeatCount! - 1
            if isPause {
                let _ = pause()
                return
            }
            
            startToSpeak()
        }
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didPause utterance: AVSpeechUtterance) {
        self.delegate?.didPause(speech: self)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didContinue utterance: AVSpeechUtterance) {
        self.delegate?.didContinue(speech: self)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didCancel utterance: AVSpeechUtterance) {
        self.delegate?.didCancel(speech: self)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, willSpeakRangeOfSpeechString characterRange: NSRange, utterance: AVSpeechUtterance) {
        currentSpeakIndex = characterRange.location + characterRange.length
        self.delegate?.speechSpeakRange(speech: self, range: characterRange)
    }
    
    
}
