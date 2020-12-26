//
//  ViewController.swift
//  KFacebookshareDemo-iOS
//
//  Created by kongyulu on 2020/10/12.
//  Copyright © 2020 wondershare. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit

class ViewController: UIViewController {
    
    private var loginButton: FBLoginButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        loginButton = FBLoginButton(frame: CGRect(x: 40, y: 140, width: 100, height: 30))
        self.view.addSubview(loginButton)
        loginButton.delegate = self
        
        testLogin()
    }
    
    private func testCore() {
        
    }
    
    private func testLogin() {
        
    }
    
    private func testShare() {
        
    }
    
    @IBAction func facebookLogin(_ sender: Any) {
    }
    
    @IBAction func facebookShare(_ sender: Any) {
        sharePhoto()
    }
    
    
    @IBAction func shareLink() {
           guard let url = URL(string: "https://newsroom.fb.com/") else {
               preconditionFailure("URL is invalid")
           }

           let content = ShareLinkContent()
           content.contentURL = url
           content.hashtag = Hashtag("#bestSharingSampleEver")

           dialog(withContent: content).show()
       }

       @IBAction func sharePhoto() {
           #if targetEnvironment(simulator)
           presentAlert(
               title: "Error",
               message: "Sharing an image will not work on a simulator. Please build to a device and try again."
           )
           return
           #endif

           guard let image = UIImage(named: "puppy") else {
               presentAlert(
                   title: "Invalid image",
                   message: "Could not find image to share"
               )
               return
           }

           let photo = SharePhoto(image: image, userGenerated: true)
           let content = SharePhotoContent()
           content.photos = [photo]

           let dialog = self.dialog(withContent: content)

           // Recommended to validate before trying to display the dialog
           do {
               try dialog.validate()
           } catch {
               presentAlert(for: error)
           }

           dialog.show()
       }

       func dialog(withContent content: SharingContent) -> ShareDialog {
           return ShareDialog(
               fromViewController: self,
               content: content,
               delegate: self
           )
       }

}

extension ViewController: LoginButtonDelegate {

    func loginButton(
        _ loginButton: FBLoginButton,
        didCompleteWith potentialResult: LoginManagerLoginResult?,
        error potentialError: Error?
    ) {
        if let error = potentialError {
            return presentAlert(for: error)
        }

        guard let result = potentialResult else {
            return presentAlert(title: "Invalid Result", message: "Login attempt failed")
        }
        
        guard !result.isCancelled else {
            return presentAlert(title: "Cancelled", message: "Login attempt was cancelled")
        }

        showLoginDetails()
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        presentAlert(title: "Logged Out", message: "You are now logged out.")
    }
    
    private func showLoginDetails() {
        print("\(#function)")
    }

}

extension ViewController: SharingDelegate {

    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        print(results)
    }

    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        presentAlert(for: error)
    }

    func sharerDidCancel(_ sharer: Sharing) {
        presentAlert(title: "Cancelled", message: "Sharing cancelled")
    }


}

extension ViewController {

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        guard let appID = Bundle.main.object(forInfoDictionaryKey: "FacebookAppID") as? String,
            appID != "{your-app-id}"
            else {
                return presentAlert(
                    title: "Invalid App Identifier",
                    message: "Please enter your Facebook application identifier in your Info.plist. This can be found on the developer portal at developers.facebook.com"
                )
        }

        guard let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: [String]]],
            let scheme = urlTypes.first?["CFBundleURLSchemes"]?.first,
            scheme != "fb{your-app-id}"
            else {
                return presentAlert(
                    title: "Invalid URL Scheme",
                    message: "Please update the url scheme in your info.plist with your Facebook application identifier to allow for the login flow to reopen this app"
                )
        }
    }

    func presentAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "Dismiss", style: .default)
        alertController.addAction(dismissAction)

        present(alertController, animated: true)
    }

    func presentAlert(for error: Error) {
        let nsError = error as NSError

        guard let sdkMessage = nsError.userInfo["com.facebook.sdk:FBSDKErrorDeveloperMessageKey"] as? String
            else {
                preconditionFailure("Errors from the SDK should have a developer facing message")
        }

        presentAlert(title: "Sharing Error", message: sdkMessage)
    }

}

