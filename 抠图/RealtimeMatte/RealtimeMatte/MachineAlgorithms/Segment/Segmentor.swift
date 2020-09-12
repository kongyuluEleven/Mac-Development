//
//  Segmentor.swift
//  RealtimeMatte
//
//  Created by ws on 2020/9/11.
//  Copyright © 2020 ws. All rights reserved.
//

import Foundation
import VideoToolbox
import UIKit

class Segmentor: Task {
    
    private let segment = Segment()
    
    func process(image: UIImage) -> CGImage? {
        guard !isBusy else { return nil }
        transitToBusy(true)
        defer {
            transitToBusy(false)
        }
        return image.segmentation(segment: segment)
    }
}


