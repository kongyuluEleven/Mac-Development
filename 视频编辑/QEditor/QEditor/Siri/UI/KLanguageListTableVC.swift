//
//  KLanguaageListTableVC.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/9.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit


public protocol KLanguageListTableVCDelegate: class {
    func KLanguageListTableVCDidSelectLanguage(_ language:OSSVoiceEnum)
}

class KLanguageListTableVC: UITableViewController {

    // MARK: - Variables
    
    private let speechKit = OSSSpeech.shared
    var delegate:KLanguageListTableVCDelegate?
    
    private lazy var microphoneButton: UIBarButtonItem = {
        var micImage: UIImage?
        if #available(iOS 13.0, *) {
            micImage = UIImage(systemName: "mic.fill")?.withRenderingMode(.alwaysTemplate)
        } else {
            micImage = UIImage(named: "oss-microphone-icon")?.withRenderingMode(.alwaysTemplate)
        }
        let button = UIBarButtonItem(image: micImage, style: .plain, target: self, action: #selector(recordVoice))
        button.tintColor = .black
        button.accessibilityIdentifier = "OSSSpeechKitMicButton"
        return button
    }()
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Languages"
        tableView.accessibilityIdentifier = "OSSSpeechKitLanguageTableView"
        speechKit.delegate = self
        navigationItem.rightBarButtonItem = microphoneButton
        tableView.register(KLanguageTableViewCell.self,
                           forCellReuseIdentifier: KLanguageTableViewCell.reuseIdentifier)
    }
    
    // MARK: - Voice Recording
    
    @objc func recordVoice() {
        if microphoneButton.tintColor == .red {
            speechKit.endVoiceRecording()
            return
        }
        microphoneButton.tintColor = .red
        speechKit.recordVoice()
    }
}

extension KLanguageListTableVC {

    // MARK: - Table View Data Source and Delegate

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OSSVoiceEnum.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: KLanguageTableViewCell.reuseIdentifier,
                                                       for: indexPath) as? KLanguageTableViewCell else {
            return UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.reuseIdentifier)
        }
        cell.language = OSSVoiceEnum.allCases[indexPath.row]
        cell.isAccessibilityElement = true
        cell.accessibilityIdentifier = "OSSLanguageCell_\(indexPath.section)_\(indexPath.row)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // NOTE: Must set the voice before requesting speech. This can be set once.
        speechKit.voice = OSSVoice(quality: .enhanced, language: OSSVoiceEnum.allCases[indexPath.item])
        speechKit.utterance?.rate = 0.45
        // Test attributed string vs normal string
        if indexPath.item % 2 == 0 {
            speechKit.speakText(OSSVoiceEnum.allCases[indexPath.item].demoMessage)
        } else {
            let attributedString = NSAttributedString(string: OSSVoiceEnum.allCases[indexPath.item].demoMessage)
            speechKit.speakAttributedText(attributedText: attributedString)
        }
        
        delegate?.KLanguageListTableVCDidSelectLanguage(OSSVoiceEnum.allCases[indexPath.item])
    }
}

extension KLanguageListTableVC: OSSSpeechDelegate {
    
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
            weakSelf?.microphoneButton.tintColor = .black
            weakSelf?.speechKit.speakText(text)
        }
    }
}

extension UIView {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
