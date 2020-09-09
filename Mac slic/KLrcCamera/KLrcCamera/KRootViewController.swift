//
//  KRootViewController.swift
//  KLrcCamera
//
//  Created by kongyulu on 2020/9/9.
//

import UIKit

class KRootViewController: UIViewController {

    @IBOutlet weak var btnCamera: UIButton!
    @IBOutlet weak var btnSiri: UIButton!
    @IBOutlet weak var btnRecognitionPicture: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func btnCameraClicked(_ sender: Any) {
        print("\(#function)")
        let nav = NavigationController(rootViewController: KSwiftyCameraVC())
        present(nav, animated: true, completion: nil)
    }
    
    @IBAction func btnRecoginitionPictureClicked(_ sender: Any) {
        print("\(#function)")
        self.navigationController?.pushViewController(KSwiftyCameraVC(), animated: true)
    }
    
    @IBAction func btnSiriClicked(_ sender: Any) {
        print("\(#function)")
        self.navigationController?.pushViewController(KSiriVC(), animated: true)
    }

}
