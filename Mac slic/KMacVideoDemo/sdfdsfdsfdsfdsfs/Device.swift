//
//  Device.swift
//  NHCapture
//
//  Created by nenhall on 2020/5/13.
//  Copyright © 2020 nenhall. All rights reserved.
//

import AppKit
import AVFoundation


/// 录制状态类型
///
/// `stop`、 `pause`、 `recording`
@objc public enum NHAVStatus: Int {
    /// 停止，也是默认状态
    case stop
    /// 暂停
    case pause
    /// 录制中
    case recording
}


@objc public class Device: NSObject {

   
    @objc public static func position(_ position: AVCaptureDevice.Position) -> AVCaptureDevice {
        let discoverySession = AVCaptureDevice.DiscoverySession.init(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: position)
        
        for device in discoverySession.devices {
            try? device.lockForConfiguration()
            // 设置视频帧率
            device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 10)
            
            if #available(iOS 10, *) {
                let settings = AVCapturePhotoSettings.init()
//                settings.flashMode = AVCaptureDevice.FlashMode.auto
            } else {
                let autoFlash = device.isFlashModeSupported(AVCaptureDevice.FlashMode.auto)
                //自动闪光灯
                if autoFlash {
                    device.flashMode = AVCaptureDevice.FlashMode.auto
                }
            }
            
            //自动白平衡
            let autoBalance = device.isWhiteBalanceModeSupported(AVCaptureDevice.WhiteBalanceMode.autoWhiteBalance)
            if autoBalance {
                device.whiteBalanceMode = AVCaptureDevice.WhiteBalanceMode.autoWhiteBalance
            }
            
            //自动对焦
            let autoFocus = device.isFocusModeSupported(AVCaptureDevice.FocusMode.autoFocus)
            if autoFocus {
                device.focusMode = AVCaptureDevice.FocusMode.autoFocus
            }
            
            //自动曝光
            let autoExpose = device.isExposureModeSupported(AVCaptureDevice.ExposureMode.autoExpose)
            if autoExpose {
                device.exposureMode = AVCaptureDevice.ExposureMode.autoExpose
            }
            
            device.unlockForConfiguration()
            return device
        }
        
       return discoverySession.devices.first!
    }


    /// 转换设备方向
    ///
    /// 应用程序的用户界面锁定为垂直方向，不过我们需要捕捉应该可以支持任何文向，
    /// 所以需要合适的转换，在写入会话期间，方向会按照这一设定保持不变
    /// - Parameter orientation: 设备的方向
    /// - Returns: 转换后的方向
//    @objc public static func transformDevice(orientation: UIDeviceOrientation) -> CGAffineTransform {
//        var transform = CGAffineTransform.identity
//        switch orientation {
//        case .landscapeLeft:
//            transform = CGAffineTransform.init(rotationAngle: CGFloat((Double.pi / 2.0) * 3.0))
//            
//        case .landscapeRight:
//            transform = CGAffineTransform.init(rotationAngle: CGFloat(Double.pi))
//            
//        case .portrait, .faceUp, .faceDown:
//            transform = CGAffineTransform.init(rotationAngle: CGFloat((Double.pi / 2.0)))
//            
//        default:
//            transform = CGAffineTransform.identity
//        }
//        return transform
//    }

//    @objc public static func currentOrientation() -> AVCaptureVideoOrientation {
//        var orientation = AVCaptureVideoOrientation.portrait
//        let deviceOrientation = UIDevice.current.orientation
//        switch deviceOrientation {
//        case .landscapeRight:
//            orientation = .landscapeLeft
//        case .landscapeLeft:
//            orientation = .landscapeRight
//        case .portraitUpsideDown:
//            orientation = .portraitUpsideDown
//        default:
//            orientation = .portrait
//        }
//        return orientation
//    }
    
}
