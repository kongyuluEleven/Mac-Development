//
//  ImageDataProvider.swift
//  RealtimeMatte
//
//  Created by ws on 2020/9/9.
//  Copyright © 2020 ws. All rights reserved.
//

import Foundation
import UIKit

class ImageDataProvider {
    
    fileprivate var imageNames = [String]()
    
    init() {
        loadData()
    }
    
    func loadData() {
        imageNames.removeAll()
        for index in 0...10 {
            imageNames.append("material_\(index).jpg")
        }
    }
    
    func image(at index: Int) -> UIImage? {
        return UIImage(named: imageNames[index])
    }
    
    func numberOfImages() -> Int {
        return imageNames.count
    }
}
