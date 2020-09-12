//
//  KGridView.swift
//  QEditor
//
//  Created by kongyulu on 2020/9/12.
//  Copyright © 2020 YiZhong Qi. All rights reserved.
//

import UIKit
class KGridView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let width = frame.width/3.0
        let height = frame.height/3.0
        
        let lineWidth = 1/UIScreen.main.scale
        
        for row in 0...1 {
            let line = UIView()
            line.backgroundColor = UIColor(white: 1, alpha: 0.8)
            line.frame = CGRect(x: 0, y: CGFloat(row + 1) * height, width: frame.width, height: lineWidth)
            addSubview(line)
        }
        
        for col in 0...1 {
            let line = UIView()
            line.backgroundColor = UIColor(white: 1, alpha: 0.8)
            line.frame = CGRect(x: CGFloat(col + 1) * width, y: 0, width: lineWidth, height: frame.height)
            addSubview(line)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
