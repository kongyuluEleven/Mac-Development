//
//  YouTubeShareManager.swift
//  KYoutubeDemo
//
//  Created by kongyulu on 2020/10/12.
//  Copyright © 2020 wondershare. All rights reserved.
//

import AppKit
import Photos

struct Instagram{
    static let appURL = URL(string: "instagram://")
    static let videoExtension = "igo"
    
    static func installed() -> Bool{
        guard let url = appURL else {
            return false
        }
        //return UIApplication.shared.canOpenURL(url)
        return false
    }
}

class InstagramShareManager: NSObject{
    
    static let `default` = InstagramShareManager()
    fileprivate override init() {}
    
    func shareVideo(_ url: URL) {
        guard Instagram.installed() else {
            //print("Instagram has not been installed!")
            return
        }
        guard FileManager.default.fileExists(atPath: url.path) else {
            //print("share video not exist at \(url.path)!")
            return
        }
        var newIdentifier: String?
        PHPhotoLibrary.shared().performChanges({
            let newAsset = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            newIdentifier = newAsset?.placeholderForCreatedAsset?.localIdentifier
        }) { (success, error) in
            guard success else{
                //print("failed to save video to photos library! \(error?.localizedDescription ?? "")")
                return
            }
            if newIdentifier == nil{
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
                let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                newIdentifier = fetchResult.firstObject?.localIdentifier
            }
            DispatchQueue.main.async {
                self.shareVideo(newIdentifier)
            }
        }
    }
    
    func shareVideo(_ assetIdentifier: String?) {
//        guard Instagram.installed() else {
//            let alertController = UIAlertController(title: FMLocalizedString("Instagram is not installed!"), message: nil, preferredStyle: .alert)
//            alertController.addAction(UIAlertAction(title: FMLocalizedString("OK"), style: .cancel, handler: nil))
//            UIApplication.shared.topViewController()?.present(alertController, animated: true, completion: nil)
//            //print("Instagram has not been installed!")
//            return
//        }
//        guard let identifier = assetIdentifier else{
//            //print("invalid asset identifier")
//            return
//        }
//        let commont = "ShareVideo"
//        let shareURL = URL(string: "instagram://library?LocalIdentifier=\(identifier)&InstagramCaption=\(commont)")!
//        guard UIApplication.shared.canOpenURL(shareURL) else {
//            //print("can not share video!")
//            return
//        }
//        UIApplication.shared.open(shareURL, options: [:], completionHandler: nil)
    }
    
    func shareVideo(_ asset: PHAsset) {
        shareVideo(asset.localIdentifier)
    }

}
