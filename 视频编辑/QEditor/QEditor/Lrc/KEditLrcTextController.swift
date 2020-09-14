//
//  KEditLrcTextController.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/14.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

public protocol KEditLrcTextControllerDeleage: class {
    
    func KEditLrcTextController_didSaveText(content:String)
    func KEditLrcTextController_didStartCamera(content:String)
}

class KEditLrcTextController: UIViewController {

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    @IBOutlet weak var btnStartVideo: UIButton!
    @IBOutlet weak var btnClear: UIButton!
    
    var orginText:String? {
        didSet {
            
        }
    }
    
    public weak var deleage:KEditLrcTextControllerDeleage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        setupNavigationButton()
        contentTextView.text = orginText
    }
    
    private func setupNavigationButton() {
        let rightBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(save(_:)))
        self.navigationItem.rightBarButtonItem = rightBarButton
    }

    @IBAction func btnStartVideoClicked(_ sender: Any) {
        deleage?.KEditLrcTextController_didStartCamera(content: contentTextView.text)
        self.dismiss(animated: true) {
            
        }
    }
    
    @objc func save(_ sender: Any) {
        deleage?.KEditLrcTextController_didSaveText(content: contentTextView.text)
        self.dismiss(animated: true) {
            
        }
    }
    
    @IBAction func btnClearClicked(_ sender: Any) {
        contentTextView.clear()
    }
    
    

}
