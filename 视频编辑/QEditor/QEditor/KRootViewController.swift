//
//  KRootViewController.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/15.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit

class KRootViewController: UIViewController {
    
    private var dataArr:[String] = ["拍摄视频","视频编辑","滤镜","抠图"]

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}

extension KRootViewController: UITableViewDelegate, UITableViewDataSource {
    

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "CellIdentifier")
        cell.textLabel?.text = dataArr[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let row = indexPath.row
        
        if row == 0 {
            navigationController?.pushViewController(KSwiftyCameraVC())
        }
        else if row == 1 {
            navigationController?.pushViewController(ProjectListViewController())
        }
        else if row == 2 {
            navigationController?.pushViewController(KFiltersShowController())
        }
        else if row == 3 {
            navigationController?.pushViewController(KImageMattingVC())
        }
    }
    
}
