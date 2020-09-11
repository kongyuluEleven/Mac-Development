//
//  ImageContent.swift
//  RealtimeMatte
//
//  Created by ws on 2020/9/9.
//  Copyright © 2020 ws. All rights reserved.
//

import UIKit

/// 只包含一张图片内容
struct ImageContent: ContentDataFilling, ContentViewHierarchySettable {
    
    struct ContentData {
        var image: UIImage?
    }
    
    let imageView: UIImageView
    
    init(contentMode: UIView.ContentMode = .scaleAspectFit) {
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = contentMode
    }
    
    func fill(contentData: ContentData) {
        imageView.image = contentData.image
    }
    
    func setContentViewHierarchy(in containerView: UIView) {
        containerView.addSubview(imageView)
    }
}
