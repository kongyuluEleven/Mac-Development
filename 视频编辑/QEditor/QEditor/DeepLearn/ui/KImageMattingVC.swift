//
//  KImageMattingVC.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/11.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class KImageMattingVC: UIViewController {

    @IBOutlet weak var btnPictureMatting: UIButton!
    @IBOutlet weak var btnVideoMatting: UIButton!
    @IBOutlet weak var btnRecordMatting: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    
    @IBAction func btnPictureMattingClicked(_ sender: Any) {
        navigationController?.pushViewController(KPhotoMattingVC())
    }
    
    @IBAction func btnVideoMattingClicked(_ sender: Any) {
        navigationController?.pushViewController(KVideoMattingVC())
    }
    
    @IBAction func btnRecordMattingClicked(_ sender: Any) {
        navigationController?.pushViewController(KVideoRecordVC())
    }
}
