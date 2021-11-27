//
//  NSAlert+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

public extension NSAlert {
    /// 如果窗口为“ nil”或未指定窗口，则将警报显示为窗口模式工作表或应用程序模式（独立于窗口）警报。
    @discardableResult
    static func showModal(
        for window: NSWindow? = nil,
        message: String,
        informativeText: String? = nil,
        detailText: String? = nil,
        style: Style = .warning,
        buttonTitles: [String] = [],
        defaultButtonIndex: Int? = nil
    ) -> NSApplication.ModalResponse {
        NSAlert(
            message: message,
            informativeText: informativeText,
            detailText: detailText,
            style: style,
            buttonTitles: buttonTitles,
            defaultButtonIndex: defaultButtonIndex
        ).runModal(for: window)
    }

   ///在buttonTitles数组中的索引，该按钮用作默认按钮。
    ///将`-1'设置为没有默认值。 对于真正的破坏性动作很有用。
    var defaultButtonIndex: Int {
        get {
            buttons.firstIndex { $0.keyEquivalent == "\r" } ?? -1
        }
        set {
            // Clear the default button indicator from other buttons.
            for button in buttons where button.keyEquivalent == "\r" {
                button.keyEquivalent = ""
            }

            if newValue != -1 {
                buttons[newValue].keyEquivalent = "\r"
            }
        }
    }
    
    convenience init(
        message: String,
        informativeText: String? = nil,
        style: Style = .warning,
        buttonTitles: [String] = [],
        defaultButtonIndex: Int? = nil
    ) {
        self.init()
        self.messageText = message
        self.alertStyle = style

        if let informativeText = informativeText {
            self.informativeText = informativeText
        }

        addButtons(withTitles: buttonTitles)

        if let defaultButtonIndex = defaultButtonIndex {
            self.defaultButtonIndex = defaultButtonIndex
        }
    }

    convenience init(
        message: String,
        informativeText: String? = nil,
        detailText: String? = nil,
        style: Style = .warning,
        buttonTitles: [String] = [],
        defaultButtonIndex: Int? = nil
    ) {
        self.init()
        self.messageText = message
        self.alertStyle = style

        if let informativeText = informativeText {
            self.informativeText = informativeText
        }

        if let detailText = detailText {
            if #available(OSX 10.14, *) {
                let scrollView = NSTextView.scrollableTextView()
                // We're setting the frame manually here as it's impossible to use auto-layout,
                // since it has nothing to constrain to. This will eventually be rewritten in SwiftUI anyway.
                scrollView.frame = CGRect(width: 300, height: 120)

                scrollView.onAddedToSuperview {
                    if let messageTextField = (scrollView.superview?.superview?.subviews.first { $0 is NSTextField }) {
                        scrollView.frame.width = messageTextField.frame.width
                    } else {
                        assertionFailure("Couldn't detect the message textfield view of the NSAlert panel")
                    }
                }

                let textView = scrollView.documentView as! NSTextView
                textView.drawsBackground = false
                textView.isEditable = false
                textView.font = .systemFont(ofSize: NSFont.systemFontSize(for: .small))
                textView.textColor = .secondaryLabelColor
                textView.string = detailText

                self.accessoryView = scrollView
            } else {
                // Fallback on earlier versions
            }

            
        }

        addButtons(withTitles: buttonTitles)

        if let defaultButtonIndex = defaultButtonIndex {
            self.defaultButtonIndex = defaultButtonIndex
        }
    }

    ///将警报作为窗口模式工作表运行，或者如果窗口为“ nil”或未指定窗口，则作为应用程序模式（独立于窗口）运行警报。
    @discardableResult
    func runModal(for window: NSWindow? = nil) -> NSApplication.ModalResponse {
        guard let window = window else {
            return runModal()
        }

        beginSheetModal(for: window) { returnCode in
            NSApp.stopModal(withCode: returnCode)
        }

        return NSApp.runModal(for: window)
    }

    /// Adds buttons with the given titles to the alert.
    func addButtons(withTitles buttonTitles: [String]) {
        for buttonTitle in buttonTitles {
            addButton(withTitle: buttonTitle)
        }
    }
}




#endif
