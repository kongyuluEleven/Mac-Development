//
//  DeepLabCenter.swift
//  RealtimeMatte
//
//  Created by ws on 2020/9/11.
//  Copyright © 2020 ws. All rights reserved.
//

import Foundation
import CoreVideo

class DeepLabCenter {
    
    let deepLabs: [DeepLab]
    
    init() {
        let deepLab1 = DeepLab(name: "deepLab1")
        let deepLab2 = DeepLab(name: "deepLab2")
        let deepLab3 = DeepLab(name: "deepLab3")
        deepLabs = [deepLab1, deepLab2, deepLab3]
    }
    
    private func idleDeepLab() -> DeepLab? {
        return deepLabs.filter { !$0.isBusy }.first
    }
    
    func predict(imageURL: URL) -> CVPixelBuffer? {
        guard let deepLab = idleDeepLab() else {
            return nil
        }
        return deepLab.predict(imageURL: imageURL)
    }
    
    func predict(with pixelBuffer: CVPixelBuffer) -> CVPixelBuffer? {
        guard let deepLab = idleDeepLab() else {
            return nil
        }
        print(deepLab.name)
        return deepLab.predict(with: pixelBuffer)
    }
}
