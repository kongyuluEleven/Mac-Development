

import UIKit
import AVFoundation

/// A function to specifty the Preview Layer's videoGravity. Indicates how the video is displayed within a player layer’s bounds rect.
public enum SwiftyCamVideoGravity {

    /**
     - Specifies that the video should be stretched to fill the layer’s bounds
     - Corrsponds to `AVLayerVideoGravityResize`
    */
    case resize
    /**
     - Specifies that the player should preserve the video’s aspect ratio and fit the video within the layer’s bounds.
     - Corresponds to `AVLayerVideoGravityResizeAspect`
     */
    case resizeAspect
    /**
     - Specifies that the player should preserve the video’s aspect ratio and fill the layer’s bounds.
     - Correponds to `AVLayerVideoGravityResizeAspectFill`
    */
    case resizeAspectFill
}

class SwiftyPreviewView: UIView {
    
    private var gravity: SwiftyCamVideoGravity = .resizeAspect
    
    init(frame: CGRect, videoGravity: SwiftyCamVideoGravity) {
        gravity = videoGravity
        super.init(frame: frame)
        self.backgroundColor = UIColor.black
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
	var videoPreviewLayer: AVCaptureVideoPreviewLayer {
        let previewlayer = layer as! AVCaptureVideoPreviewLayer
        switch gravity {
        case .resize:
            previewlayer.videoGravity = AVLayerVideoGravity.resize
        case .resizeAspect:
            previewlayer.videoGravity = AVLayerVideoGravity.resizeAspect
        case .resizeAspectFill:
            previewlayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
		return previewlayer
	}
	
	var session: AVCaptureSession? {
		get {
			return videoPreviewLayer.session
		}
		set {
			videoPreviewLayer.session = newValue
		}
	}
	
	// MARK: UIView
	
	override class var layerClass : AnyClass {
		return AVCaptureVideoPreviewLayer.self
	}
}
