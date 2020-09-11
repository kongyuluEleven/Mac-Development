//
//  ImageCollectionCell.swift
//  RealtimeMatte
//
//  Created by ws on 2020/9/9.
//  Copyright © 2020 ws. All rights reserved.
//

import UIKit

class ImageCollectionCell: UICollectionViewCell {
    
    let content = ImageContent(contentMode: .scaleAspectFit)
    var showSelectionBorder: Bool = false
    
    var image: UIImage? {
        didSet {
            content.fill(contentData: .init(image: image))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        content.setContentViewHierarchy(in: contentView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected && showSelectionBorder {
                self.layer.borderColor = UIColor.red.cgColor
                self.layer.borderWidth = 2
                self.layer.cornerRadius = 4
                self.layer.masksToBounds = true
            } else {
                self.layer.borderColor = UIColor.clear.cgColor
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        content.imageView.frame = bounds
    }
}
