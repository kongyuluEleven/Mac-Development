//
//  NSWorkspace+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public enum PaneAnchor: String {
    case camera = "Privacy_Camera"
    case microphone = "Privacy_Microphone"
    case location = "Privacy_LocationServices"
    case accessibility = "Privacy_Accessibility"
    case reminders = "Privacy_Reminders"
    case calendars = "Privacy_Calendars"
    case firewall = "Firewall"
    case assistive = "Privacy_Assistive"
    case contacts = "Privacy_Contacts"
    case general = "General"
    case advanced = "Advanced"
    case FDE = "FDE"
    case privacy = "Privacy"
    case allFiles = "Privacy_AllFiles"
    case systemServices = "Privacy_SystemServices"
    case screenRecoding = "Privacy_ScreenCapture"
    case photos = "Privacy_Photos"
}

public enum SysPreferences  {
    var mainPane: String {
       return "x-apple.systempreferences:"
    }
    case securityPane(PaneAnchor)
    
    var rawValue: String {
        switch self {
        case .securityPane:
            return "com.apple.preference.security"
        }
    }
}

public extension NSWorkspace {
    func openSysPreferencesPanel(_ panel: SysPreferences) {
        var url: URL?
        switch panel {
        case .securityPane(let anchor):
            url = URL(string: panel.mainPane + panel.rawValue + "?" + anchor.rawValue)

//            switch anchor {
//            case .photos, .screenRecoding:
//                url = URL(string: panel.mainPane + panel.rawValue + "?" + PaneAnchor.camera.rawValue)
//            default:
//                url = URL(string: panel.mainPane + panel.rawValue + "?" + anchor.rawValue)
//            }
        }
        if let url = url {
            /// 1. 先启动，让其成为活跃窗口，否则不会弹到最前面
            /// 2. 否则在系统偏好设置面板没有启动的时候，无法跳到子设置面板
            if applicationRunning(bundleIdentifier: "com.apple.systempreferences") {
                NSWorkspace.shared.launchApplication(withBundleIdentifier: "com.apple.systempreferences",
                                                     options: [.andHideOthers],
                                                     additionalEventParamDescriptor: nil,
                                                     launchIdentifier: nil)

            } else {
                open(url)
            }
            self.perform(#selector(open(_:)), with: url, afterDelay: 1)
        }
    }
    
    func applicationRunning(bundleIdentifier: String) -> Bool {
      let count = NSRunningApplication.runningApplications(withBundleIdentifier: bundleIdentifier).count
        if count > 0 {
            return true
        }
        return false
    }
}

public extension NSWorkspace {
    /// Returns the height of the Dock.
    /// It's `nil` if there's no primary screen or if the Dock is set to be automatically hidden.
    var dockHeight: Double? {
        guard let screen = NSScreen.primary else {
            return nil
        }

        let height = Double(screen.visibleFrame.origin.y - screen.frame.origin.y)

        guard height != 0 else {
            return nil
        }

        return height
    }

    /// Whether the user has "Turn Hiding On" enabled in the Dock preferences.
    var isDockAutomaticallyToggled: Bool {
        guard NSScreen.primary != nil else {
            return false
        }

        return dockHeight == nil
    }
}


#endif
