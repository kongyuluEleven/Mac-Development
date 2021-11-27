//
//  NSEvent+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit


public extension NSEvent {
    /// Events triggered by user interaction.
    static let userInteractionEvents: [NSEvent.EventType] = {
        var events: [NSEvent.EventType] = [
            .leftMouseDown,
            .leftMouseUp,
            .rightMouseDown,
            .rightMouseUp,
            .leftMouseDragged,
            .rightMouseDragged,
            .keyDown,
            .keyUp,
            .scrollWheel,
            .tabletPoint,
            .otherMouseDown,
            .otherMouseUp,
            .otherMouseDragged,
            .gesture,
            .magnify,
            .swipe,
            .rotate,
            .beginGesture,
            .endGesture,
            .smartMagnify,
            .quickLook,
            .directTouch
        ]

        if #available(macOS 10.10.3, *) {
            events.append(.pressure)
        }

        return events
    }()

    /// Whether the event was triggered by user interaction.
    var isUserInteraction: Bool { NSEvent.userInteractionEvents.contains(type) }
}

public extension NSEvent.ModifierFlags {
    
    static var none: NSEvent.ModifierFlags = NSEvent.ModifierFlags(rawValue: 0)
    
    func equal(_ modiferFlags: NSEvent.ModifierFlags ...) -> Bool {
        var mask: UInt = 0
        for modiferFlag in modiferFlags {
            mask |= modiferFlag.rawValue
        }
        
        var selfMask = self.rawValue & NSEvent.ModifierFlags.deviceIndependentFlagsMask.rawValue
        selfMask &= ~(NSEvent.ModifierFlags.numericPad.rawValue)
        selfMask &= ~(NSEvent.ModifierFlags.help.rawValue)
        selfMask &= ~(NSEvent.ModifierFlags.function.rawValue)
        selfMask &= ~(NSEvent.ModifierFlags.help.rawValue)
        selfMask &= ~(NSEvent.ModifierFlags.capsLock.rawValue)
        
        return selfMask == mask
    }

}


#endif
