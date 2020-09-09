//
//  ViewController.swift
//  QEditor
//
//  Created by Q YiZhong on 2019/10/6.
//  Copyright © 2019 YiZhong Qi. All rights reserved.
//

import UIKit
import SnapKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()

    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        let buttonCamera = UIButton(type: .custom)
        buttonCamera.frame = .init(x: 0, y: 0, width: 100, height: 100)
        buttonCamera.setTitle("拍摄", for: .normal)
        buttonCamera.center = view.center
        buttonCamera.addTarget(self, action: #selector(clickCameraButton), for: .touchUpInside)
        buttonCamera.setTitleColor(.red, for: .normal)
        view.addSubview(buttonCamera)
        
        let buttonProjects = UIButton(type: .custom)
        buttonProjects.frame = .init(x: 0, y: 0, width: 100, height: 100)
        buttonProjects.setTitle("编辑视频", for: .normal)
        buttonProjects.center = view.center
        buttonProjects.addTarget(self, action: #selector(clickProjectButton), for: .touchUpInside)
        buttonProjects.setTitleColor(.red, for: .normal)
        view.addSubview(buttonProjects)
        
        let buttonLrc = UIButton(type: .custom)
        buttonLrc.frame = .init(x: 0, y: 0, width: 100, height: 100)
        buttonLrc.setTitle("字幕", for: .normal)
        buttonLrc.center = view.center
        buttonLrc.addTarget(self, action: #selector(clickLrcButton), for: .touchUpInside)
        buttonLrc.setTitleColor(.red, for: .normal)
        view.addSubview(buttonLrc)
        
        let buttonLanguage = UIButton(type: .custom)
        buttonLanguage.frame = .init(x: 0, y: 0, width: 100, height: 100)
        buttonLanguage.setTitle("语言", for: .normal)
        buttonLanguage.center = view.center
        buttonLanguage.addTarget(self, action: #selector(clickbuttonLanguage), for: .touchUpInside)
        buttonLanguage.setTitleColor(.red, for: .normal)
        view.addSubview(buttonLanguage)
        
        buttonCamera.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(120)
            make.width.equalTo(60)
            make.height.equalTo(30)
        }
        
        buttonProjects.snp.makeConstraints { (make) in
            make.left.equalTo(buttonCamera)
            make.top.equalTo(buttonCamera.snp.bottom).offset(20)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        buttonLrc.snp.makeConstraints { (make) in
            make.left.equalTo(buttonProjects)
            make.top.equalTo(buttonProjects.snp.bottom).offset(20)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
        buttonLanguage.snp.makeConstraints { (make) in
            make.left.equalTo(buttonLrc)
            make.top.equalTo(buttonLrc.snp.bottom).offset(20)
            make.width.equalTo(100)
            make.height.equalTo(30)
        }
        
    }
    
    @objc func clickCameraButton() {
        navigationController?.pushViewController(KSwiftyCameraVC())
    }
    
    
    @objc func clickProjectButton() {
        navigationController?.pushViewController(ProjectListViewController())
    }
    
    @objc func clickLrcButton() {
        //self.navigationController?.pushViewController(MediaViewController.buildView())
        let nav = NavigationController(rootViewController: MediaViewController.buildView())
        present(nav, animated: true, completion: nil)
    }
    
    @objc func clickbuttonLanguage() {
        navigationController?.pushViewController(KLanguaageListTableVC())
//        let nav = NavigationController(rootViewController: KLanguaageListTableVC())
//        present(nav, animated: true, completion: nil)
    }


}

