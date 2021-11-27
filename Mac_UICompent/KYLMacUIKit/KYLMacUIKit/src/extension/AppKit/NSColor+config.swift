//
//  NSColor+config.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - 渐变色

public extension NSColor {

    enum Gradient {
        /// 默认高亮状态，渐变色
        static let defaultHighlightGradient: NSGradient = {
            let topColor     = NSColor(calibratedRed: 0.063, green: 0.439, blue: 0.816, alpha: 1.0)
            let bottomColor  = NSColor(calibratedRed: 0.051, green: 0.361, blue: 0.78, alpha: 1.0)
            let gradient     = NSGradient(starting: topColor, ending: bottomColor)
            return gradient!
        }()
        
        /// 默认鼠标滑过状态，渐变色
        static let defaultHoverGradient: NSGradient = {
            let topColor     = NSColor(calibratedRed: 0.063, green: 0.439, blue: 0.816, alpha: 1.0)
            let bottomColor  = NSColor(calibratedRed: 0.051, green: 0.361, blue: 0.78, alpha: 1.0)
            let gradient     = NSGradient(starting: topColor, ending: bottomColor)
            return gradient!
        }()
        
        /// 默认禁用状态，渐变色
        static let defaultDisableGradient: NSGradient = {
            let topColor     = NSColor(calibratedRed: 0.063, green: 0.439, blue: 0.816, alpha: 1.0)
            let bottomColor  = NSColor(calibratedRed: 0.051, green: 0.361, blue: 0.78, alpha: 1.0)
            let gradient     = NSGradient(starting: topColor, ending: bottomColor)
            return gradient!
        }()
        
        /// 默认正常状态，渐变色
        static let defaultHDGradient: NSGradient = {
            let topColor     = NSColor(calibratedRed: 0.196, green: 0.196, blue: 0.196, alpha: 1.0)
            let bottomColor  = NSColor(calibratedRed: 0.239, green: 0.239, blue: 0.239, alpha: 1.0)
            let gradient = NSGradient(starting: topColor, ending: bottomColor)
            return gradient!
        }()
    }
}

// MARK: - 社交平台app默认颜色

public extension NSColor {

    enum Social {
        /// WS: red: 59, green: 89, blue: 152
        public static let facebook = NSColor(red: 59, green: 89, blue: 152)!

        /// WS: red: 0, green: 182, blue: 241
        public static let twitter = NSColor(red: 0, green: 182, blue: 241)!

        /// WS: red: 223, green: 74, blue: 50
        public static let googlePlus = NSColor(red: 223, green: 74, blue: 50)!

        /// WS: red: 0, green: 123, blue: 182
        public static let linkedIn = NSColor(red: 0, green: 123, blue: 182)!

        /// WS: red: 69, green: 187, blue: 255
        public static let vimeo = NSColor(red: 69, green: 187, blue: 255)!

        /// WS: red: 179, green: 18, blue: 23
        public static let youtube = NSColor(red: 179, green: 18, blue: 23)!

        /// WS: red: 195, green: 42, blue: 163
        public static let instagram = NSColor(red: 195, green: 42, blue: 163)!

        /// WS: red: 203, green: 32, blue: 39
        public static let pinterest = NSColor(red: 203, green: 32, blue: 39)!

        /// WS: red: 244, green: 0, blue: 131
        public static let flickr = NSColor(red: 244, green: 0, blue: 131)!

        /// WS: red: 67, green: 2, blue: 151
        public static let yahoo = NSColor(red: 67, green: 2, blue: 151)!

        /// WS: red: 67, green: 2, blue: 151
        public static let soundCloud = NSColor(red: 67, green: 2, blue: 151)!

        /// WS: red: 44, green: 71, blue: 98
        public static let tumblr = NSColor(red: 44, green: 71, blue: 98)!

        /// WS: red: 252, green: 69, blue: 117
        public static let foursquare = NSColor(red: 252, green: 69, blue: 117)!

        /// WS: red: 255, green: 176, blue: 0
        public static let swarm = NSColor(red: 255, green: 176, blue: 0)!

        /// WS: red: 234, green: 76, blue: 137
        public static let dribbble = NSColor(red: 234, green: 76, blue: 137)!

        /// WS: red: 255, green: 87, blue: 0
        public static let reddit = NSColor(red: 255, green: 87, blue: 0)!

        /// WS: red: 74, green: 93, blue: 78
        public static let devianArt = NSColor(red: 74, green: 93, blue: 78)!

        /// WS: red: 238, green: 64, blue: 86
        public static let pocket = NSColor(red: 238, green: 64, blue: 86)!

        /// WS: red: 170, green: 34, blue: 182
        public static let quora = NSColor(red: 170, green: 34, blue: 182)!

        /// WS: red: 247, green: 146, blue: 30
        public static let slideShare = NSColor(red: 247, green: 146, blue: 30)!

        /// WS: red: 0, green: 153, blue: 229
        public static let px500 = NSColor(red: 0, green: 153, blue: 229)!

        /// WS: red: 223, green: 109, blue: 70
        public static let listly = NSColor(red: 223, green: 109, blue: 70)!

        /// WS: red: 0, green: 180, blue: 137
        public static let vine = NSColor(red: 0, green: 180, blue: 137)!

        /// WS: red: 0, green: 175, blue: 240
        public static let skype = NSColor(red: 0, green: 175, blue: 240)!

        /// WS: red: 235, green: 73, blue: 36
        public static let stumbleUpon = NSColor(red: 235, green: 73, blue: 36)!

        /// WS: red: 255, green: 252, blue: 0
        public static let snapchat = NSColor(red: 255, green: 252, blue: 0)!

        /// WS: red: 37, green: 211, blue: 102
        public static let whatsApp = NSColor(red: 37, green: 211, blue: 102)!
    }
}


// MARK: - Filmora 深色，浅色颜色值
extension NSColor {
    static let filmoraDarkColors : [String : NSColor] =
                ["background_tint1": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.160),
                "background_surface3": #colorLiteral(red: 0.129, green: 0.184, blue: 0.239, alpha: 1.000),
                "background_surface2": #colorLiteral(red: 0.125, green: 0.161, blue: 0.196, alpha: 1.000),
                "background_overlay1": #colorLiteral(red: 0.090, green: 0.122, blue: 0.149, alpha: 1.000),
                "background_overlay1_90": #colorLiteral(red: 0.090, green: 0.122, blue: 0.149, alpha: 0.900),
                "background_shade2": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.240),
                "background_shade3": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.320),
                "background_base": #colorLiteral(red: 0.097, green: 0.135, blue: 0.169, alpha: 1.000),
                "background_base_90": #colorLiteral(red: 0.090, green: 0.121, blue: 0.149, alpha: 0.900),
                "background_surface1": #colorLiteral(red: 0.114, green: 0.150, blue: 0.186, alpha: 1.000),
                "background_tint3": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.320),
                "background_tint2": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.240),
                "background_overlay2": #colorLiteral(red: 0.071, green: 0.102, blue: 0.137, alpha: 1.000),
                "background_shade1": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.160),
                "local_title_background": #colorLiteral(red: 0.169, green: 0.169, blue: 0.169, alpha: 1.000),
                "local_mask": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500),
                "local_primary_marquee": #colorLiteral(red: 0.333, green: 0.898, blue: 0.773, alpha: 0.300),
                "local_deeplin": #colorLiteral(red: 0.027, green: 0.039, blue: 0.047, alpha: 1.000),
                "local_deep_list": #colorLiteral(red: 0.067, green: 0.086, blue: 0.106, alpha: 1.000),
                "local_light_list": #colorLiteral(red: 0.118, green: 0.180, blue: 0.243, alpha: 1.000),
                "local_tips": #colorLiteral(red: 0.208, green: 0.263, blue: 0.314, alpha: 1.000),
                "local_player": #colorLiteral(red: 0.063, green: 0.078, blue: 0.102, alpha: 1.000),
                "local_colormatch": #colorLiteral(red: 0.102, green: 0.157, blue: 0.216, alpha: 1.000),
                "local_special_hover": #colorLiteral(red: 1.000, green: 0.839, blue: 0.420, alpha: 1.000),
                "local_secondary-line": #colorLiteral(red: 0.086, green: 0.114, blue: 0.141, alpha: 1.000),
                "local_preset_mask": #colorLiteral(red: 0.133, green: 0.161, blue: 0.192, alpha: 0.400),
                "local_normal": #colorLiteral(red: 0.788, green: 0.788, blue: 0.788, alpha: 1.000),
                "local_disabled": #colorLiteral(red: 0.388, green: 0.388, blue: 0.388, alpha: 1.000),
                "local_hover": #colorLiteral(red: 0.914, green: 0.914, blue: 0.914, alpha: 1.000),
                "local_special_pressed": #colorLiteral(red: 1.000, green: 0.925, blue: 0.537, alpha: 1.000),
                "local_alchemy_normal": #colorLiteral(red: 0.506, green: 0.518, blue: 0.525, alpha: 1.000),
                "local_timeline": #colorLiteral(red: 0.067, green: 0.071, blue: 0.075, alpha: 1.000),
                "alert_success": #colorLiteral(red: 0.000, green: 0.745, blue: 0.341, alpha: 1.000),
                "alert_warning": #colorLiteral(red: 0.992, green: 0.749, blue: 0.204, alpha: 1.000),
                "alert_danger": #colorLiteral(red: 1.000, green: 0.310, blue: 0.310, alpha: 1.000),
                "alert_buy": #colorLiteral(red: 1.000, green: 0.392, blue: 0.114, alpha: 1.000),
                "filmorax_first_low": #colorLiteral(red: 1.000, green: 0.459, blue: 0.459, alpha: 0.100),
                "filmorax_accent": #colorLiteral(red: 1.000, green: 0.400, blue: 0.329, alpha: 1.000),
                "filmorax_fifth_low": #colorLiteral(red: 0.212, green: 0.812, blue: 0.988, alpha: 0.100),
                "filmorax_primary_hover": #colorLiteral(red: 0.600, green: 0.937, blue: 0.863, alpha: 1.000),
                "filmorax_fourth_low": #colorLiteral(red: 0.271, green: 0.949, blue: 0.584, alpha: 0.100),
                "filmorax_fourth_high": #colorLiteral(red: 0.271, green: 0.949, blue: 0.584, alpha: 0.500),
                "filmorax_seventh_low": #colorLiteral(red: 0.725, green: 0.631, blue: 1.000, alpha: 0.100),
                "filmorax_first": #colorLiteral(red: 1.000, green: 0.459, blue: 0.459, alpha: 1.000),
                "filmorax_primary_pressed": #colorLiteral(red: 0.733, green: 0.961, blue: 0.910, alpha: 1.000),
                "filmorax_seventh_high": #colorLiteral(red: 0.725, green: 0.631, blue: 1.000, alpha: 0.500),
                "filmorax_third_medium": #colorLiteral(red: 1.000, green: 0.808, blue: 0.310, alpha: 0.200),
                "filmorax_seventh_medium": #colorLiteral(red: 0.725, green: 0.631, blue: 1.000, alpha: 0.200),
                "filmorax_primary": #colorLiteral(red: 0.333, green: 0.898, blue: 0.773, alpha: 1.000),
                "filmorax_fifth_high": #colorLiteral(red: 0.212, green: 0.812, blue: 0.988, alpha: 0.500),
                "filmorax_second_low": #colorLiteral(red: 1.000, green: 0.545, blue: 0.333, alpha: 0.100),
                "filmorax_third_low": #colorLiteral(red: 1.000, green: 0.808, blue: 0.310, alpha: 0.100),
                "filmorax_alchemy_low": #colorLiteral(red: 0.780, green: 0.780, blue: 0.780, alpha: 0.100),
                "filmorax_fifth_medium": #colorLiteral(red: 0.212, green: 0.812, blue: 0.988, alpha: 0.200),
                "filmorax_first_medium": #colorLiteral(red: 1.000, green: 0.459, blue: 0.459, alpha: 0.200),
                "filmorax_first_high": #colorLiteral(red: 1.000, green: 0.459, blue: 0.459, alpha: 0.500),
                "filmorax_third": #colorLiteral(red: 1.000, green: 0.808, blue: 0.310, alpha: 1.000),
                "filmorax_sixth_medium": #colorLiteral(red: 0.498, green: 0.573, blue: 1.000, alpha: 0.200),
                "filmorax_third_high": #colorLiteral(red: 1.000, green: 0.808, blue: 0.310, alpha: 0.500),
                "filmorax_sixth_high": #colorLiteral(red: 0.498, green: 0.573, blue: 1.000, alpha: 0.500),
                "filmorax_accent_pressed": #colorLiteral(red: 1.000, green: 0.580, blue: 0.529, alpha: 1.000),
                "filmorax_seventh": #colorLiteral(red: 0.725, green: 0.631, blue: 1.000, alpha: 1.000),
                "filmorax_alchemy": #colorLiteral(red: 0.780, green: 0.780, blue: 0.780, alpha: 1.000),
                "filmorax_alchemy_high": #colorLiteral(red: 0.780, green: 0.780, blue: 0.780, alpha: 0.500),
                "filmorax_second": #colorLiteral(red: 1.000, green: 0.545, blue: 0.333, alpha: 1.000),
                "filmorax_fourth_medium": #colorLiteral(red: 0.271, green: 0.949, blue: 0.584, alpha: 0.200),
                "filmorax_fifth": #colorLiteral(red: 0.212, green: 0.812, blue: 0.988, alpha: 1.000),
                "filmorax_second_high": #colorLiteral(red: 1.000, green: 0.545, blue: 0.333, alpha: 0.500),
                "filmorax_sixth": #colorLiteral(red: 0.498, green: 0.573, blue: 1.000, alpha: 1.000),
                "filmorax_sixth_low": #colorLiteral(red: 0.498, green: 0.573, blue: 1.000, alpha: 0.100),
                "filmorax_alchemy_medium": #colorLiteral(red: 0.780, green: 0.780, blue: 0.780, alpha: 0.200),
                "filmorax_accent_hover": #colorLiteral(red: 1.000, green: 0.490, blue: 0.431, alpha: 1.000),
                "filmorax_fourth": #colorLiteral(red: 0.271, green: 0.949, blue: 0.584, alpha: 1.000),
                "filmorax_second_medium": #colorLiteral(red: 1.000, green: 0.545, blue: 0.333, alpha: 0.200),
                "component_divider_primary": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.720),
                "component_input": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.240),
                "component_control": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.040),
                "component_divider_secondary": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.240),
                "component_control_stroke": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.160),
                "state_pressed": #colorLiteral(red: 1.000, green: 1.000, blue:1.000, alpha: 0.240),
                "state_hover": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.080),
                "state_disabled": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.160),
                "textIcon_primary": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000),
                "textIcon_disabled": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.240),
                "textIcon_tertiary": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.560),
                "textIcon_secondary": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.720),
                "textIcon_pressed": #colorLiteral(red: 0.282, green: 0.388, blue: 0.533, alpha: 1.000),
                "common_white": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000),
                "common_black": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000),
                "common_mask": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.560),
                "wondershare_cta": #colorLiteral(red: 0.000, green: 0.482, blue: 1.000, alpha: 1.000),
                "wondershare_cta_pressed": #colorLiteral(red: 0.333, green: 0.655, blue: 1.000, alpha: 1.000),
                "wondershare_cta_hover": #colorLiteral(red: 0.165, green: 0.569, blue: 1.000, alpha: 1.000),
                ]
    
    static let filmoraLightColors : [String : NSColor] =
                ["background_tint1": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.160),
                "background_surface3": #colorLiteral(red: 0.129, green: 0.184, blue: 0.239, alpha: 1.000),
                "background_surface2": #colorLiteral(red: 0.125, green: 0.161, blue: 0.196, alpha: 1.000),
                "background_overlay1": #colorLiteral(red: 0.090, green: 0.122, blue: 0.149, alpha: 1.000),
                "background_overlay1_90": #colorLiteral(red: 0.090, green: 0.122, blue: 0.149, alpha: 0.900),
                "background_shade2": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.240),
                "background_shade3": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.320),
                "background_base": #colorLiteral(red: 0.097, green: 0.135, blue: 0.169, alpha: 1.000),
                "background_base_90": #colorLiteral(red: 0.090, green: 0.121, blue: 0.149, alpha: 0.900),
                "background_surface1": #colorLiteral(red: 0.114, green: 0.150, blue: 0.186, alpha: 1.000),
                "background_tint3": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.320),
                "background_tint2": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.240),
                "background_overlay2": #colorLiteral(red: 0.071, green: 0.102, blue: 0.137, alpha: 1.000),
                "background_shade1": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.160),
                "local_title_background": #colorLiteral(red: 0.169, green: 0.169, blue: 0.169, alpha: 1.000),
                "local_mask": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.500),
                "local_primary_marquee": #colorLiteral(red: 0.333, green: 0.898, blue: 0.773, alpha: 0.300),
                "local_deeplin": #colorLiteral(red: 0.027, green: 0.039, blue: 0.047, alpha: 1.000),
                "local_deep_list": #colorLiteral(red: 0.067, green: 0.086, blue: 0.106, alpha: 1.000),
                "local_light_list": #colorLiteral(red: 0.118, green: 0.180, blue: 0.243, alpha: 1.000),
                "local_tips": #colorLiteral(red: 0.208, green: 0.263, blue: 0.314, alpha: 1.000),
                "local_player": #colorLiteral(red: 0.063, green: 0.078, blue: 0.102, alpha: 1.000),
                "local_colormatch": #colorLiteral(red: 0.102, green: 0.157, blue: 0.216, alpha: 1.000),
                "local_special_hover": #colorLiteral(red: 1.000, green: 0.839, blue: 0.420, alpha: 1.000),
                "local_secondary-line": #colorLiteral(red: 0.086, green: 0.114, blue: 0.141, alpha: 1.000),
                "local_preset_mask": #colorLiteral(red: 0.133, green: 0.161, blue: 0.192, alpha: 0.400),
                "local_normal": #colorLiteral(red: 0.788, green: 0.788, blue: 0.788, alpha: 1.000),
                "local_disabled": #colorLiteral(red: 0.388, green: 0.388, blue: 0.388, alpha: 1.000),
                "local_hover": #colorLiteral(red: 0.914, green: 0.914, blue: 0.914, alpha: 1.000),
                "local_special_pressed": #colorLiteral(red: 1.000, green: 0.925, blue: 0.537, alpha: 1.000),
                "local_alchemy_normal": #colorLiteral(red: 0.506, green: 0.518, blue: 0.525, alpha: 1.000),
                "local_timeline": #colorLiteral(red: 0.067, green: 0.071, blue: 0.075, alpha: 1.000),
                "alert_success": #colorLiteral(red: 0.000, green: 0.745, blue: 0.341, alpha: 1.000),
                "alert_warning": #colorLiteral(red: 0.992, green: 0.749, blue: 0.204, alpha: 1.000),
                "alert_danger": #colorLiteral(red: 1.000, green: 0.310, blue: 0.310, alpha: 1.000),
                "alert_buy": #colorLiteral(red: 1.000, green: 0.392, blue: 0.114, alpha: 1.000),
                "filmorax_first_low": #colorLiteral(red: 1.000, green: 0.459, blue: 0.459, alpha: 0.100),
                "filmorax_accent": #colorLiteral(red: 1.000, green: 0.400, blue: 0.329, alpha: 1.000),
                "filmorax_fifth_low": #colorLiteral(red: 0.212, green: 0.812, blue: 0.988, alpha: 0.100),
                "filmorax_primary_hover": #colorLiteral(red: 0.600, green: 0.937, blue: 0.863, alpha: 1.000),
                "filmorax_fourth_low": #colorLiteral(red: 0.271, green: 0.949, blue: 0.584, alpha: 0.100),
                "filmorax_fourth_high": #colorLiteral(red: 0.271, green: 0.949, blue: 0.584, alpha: 0.500),
                "filmorax_seventh_low": #colorLiteral(red: 0.725, green: 0.631, blue: 1.000, alpha: 0.100),
                "filmorax_first": #colorLiteral(red: 1.000, green: 0.459, blue: 0.459, alpha: 1.000),
                "filmorax_primary_pressed": #colorLiteral(red: 0.733, green: 0.961, blue: 0.910, alpha: 1.000),
                "filmorax_seventh_high": #colorLiteral(red: 0.725, green: 0.631, blue: 1.000, alpha: 0.500),
                "filmorax_third_medium": #colorLiteral(red: 1.000, green: 0.808, blue: 0.310, alpha: 0.200),
                "filmorax_seventh_medium": #colorLiteral(red: 0.725, green: 0.631, blue: 1.000, alpha: 0.200),
                "filmorax_primary": #colorLiteral(red: 0.333, green: 0.898, blue: 0.773, alpha: 1.000),
                "filmorax_fifth_high": #colorLiteral(red: 0.212, green: 0.812, blue: 0.988, alpha: 0.500),
                "filmorax_second_low": #colorLiteral(red: 1.000, green: 0.545, blue: 0.333, alpha: 0.100),
                "filmorax_third_low": #colorLiteral(red: 1.000, green: 0.808, blue: 0.310, alpha: 0.100),
                "filmorax_alchemy_low": #colorLiteral(red: 0.780, green: 0.780, blue: 0.780, alpha: 0.100),
                "filmorax_fifth_medium": #colorLiteral(red: 0.212, green: 0.812, blue: 0.988, alpha: 0.200),
                "filmorax_first_medium": #colorLiteral(red: 1.000, green: 0.459, blue: 0.459, alpha: 0.200),
                "filmorax_first_high": #colorLiteral(red: 1.000, green: 0.459, blue: 0.459, alpha: 0.500),
                "filmorax_third": #colorLiteral(red: 1.000, green: 0.808, blue: 0.310, alpha: 1.000),
                "filmorax_sixth_medium": #colorLiteral(red: 0.498, green: 0.573, blue: 1.000, alpha: 0.200),
                "filmorax_third_high": #colorLiteral(red: 1.000, green: 0.808, blue: 0.310, alpha: 0.500),
                "filmorax_sixth_high": #colorLiteral(red: 0.498, green: 0.573, blue: 1.000, alpha: 0.500),
                "filmorax_accent_pressed": #colorLiteral(red: 1.000, green: 0.580, blue: 0.529, alpha: 1.000),
                "filmorax_seventh": #colorLiteral(red: 0.725, green: 0.631, blue: 1.000, alpha: 1.000),
                "filmorax_alchemy": #colorLiteral(red: 0.780, green: 0.780, blue: 0.780, alpha: 1.000),
                "filmorax_alchemy_high": #colorLiteral(red: 0.780, green: 0.780, blue: 0.780, alpha: 0.500),
                "filmorax_second": #colorLiteral(red: 1.000, green: 0.545, blue: 0.333, alpha: 1.000),
                "filmorax_fourth_medium": #colorLiteral(red: 0.271, green: 0.949, blue: 0.584, alpha: 0.200),
                "filmorax_fifth": #colorLiteral(red: 0.212, green: 0.812, blue: 0.988, alpha: 1.000),
                "filmorax_second_high": #colorLiteral(red: 1.000, green: 0.545, blue: 0.333, alpha: 0.500),
                "filmorax_sixth": #colorLiteral(red: 0.498, green: 0.573, blue: 1.000, alpha: 1.000),
                "filmorax_sixth_low": #colorLiteral(red: 0.498, green: 0.573, blue: 1.000, alpha: 0.100),
                "filmorax_alchemy_medium": #colorLiteral(red: 0.780, green: 0.780, blue: 0.780, alpha: 0.200),
                "filmorax_accent_hover": #colorLiteral(red: 1.000, green: 0.490, blue: 0.431, alpha: 1.000),
                "filmorax_fourth": #colorLiteral(red: 0.271, green: 0.949, blue: 0.584, alpha: 1.000),
                "filmorax_second_medium": #colorLiteral(red: 1.000, green: 0.545, blue: 0.333, alpha: 0.200),
                "component_divider_primary": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.720),
                "component_input": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.240),
                "component_control": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.040),
                "component_divider_secondary": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.240),
                "component_control_stroke": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.160),
                "state_pressed": #colorLiteral(red: 1.000, green: 1.000, blue:1.000, alpha: 0.240),
                "state_hover": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.080),
                "state_disabled": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.160),
                "textIcon_primary": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000),
                "textIcon_disabled": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.240),
                "textIcon_tertiary": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.560),
                "textIcon_secondary": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 0.720),
                "textIcon_pressed": #colorLiteral(red: 0.282, green: 0.388, blue: 0.533, alpha: 1.000),
                "common_white": #colorLiteral(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000),
                "common_black": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000),
                "common_mask": #colorLiteral(red: 0.000, green: 0.000, blue: 0.000, alpha: 0.560),
                "wondershare_cta": #colorLiteral(red: 0.000, green: 0.482, blue: 1.000, alpha: 1.000),
                "wondershare_cta_pressed": #colorLiteral(red: 0.333, green: 0.655, blue: 1.000, alpha: 1.000),
                "wondershare_cta_hover": #colorLiteral(red: 0.165, green: 0.569, blue: 1.000, alpha: 1.000),
                ]
    
}



protocol WSColorNameProtocol {
    var name: String {get}
    var langName: String {get}
}

protocol WSColorProtocol {
    var color: NSColor {get}
}

// MARK: - 根据颜色名称获取颜色值，会自动根据系统匹配颜色

public extension NSColor {
        //获取语义色彩（这是唯一的颜色获取API，为了兼容旧系统，不要在xib中直接使用Assets.xcassets中的NamedColor）
    class func filmoraColor(name: String) -> NSColor {
            // 10.13以上提供深浅两套皮肤
            if #available(OSX 10.13, *) {
                guard let colorInDarkOrLight = NSColor(named: NSColor.Name(name)) else {
                    return NSColor.black
                }
                return colorInDarkOrLight
            }else {// 兼容旧系统展示深色皮肤
                return filmoraDarkColors[name] ?? NSColor.black
            }
        }

}

// MARK: - Common

public extension NSColor {
    enum Common: String, WSColorNameProtocol, WSColorProtocol {
        case white = "white"
        case black = "black"
        case mask = "mask"
        public var name: String {
            return self.rawValue
        }
        public var langName: String {
            return String.init(format: "common_%@", self.rawValue)
        }
        
        public var color: NSColor {
            return NSColor.filmoraColor(name: langName)
        }
    }
}


// MARK: - Background

public extension NSColor {
    enum Background: String, WSColorNameProtocol, WSColorProtocol {
        case surface3 = "surface3"
        case surface2 = "surface2"
        case surface1 = "surface1"
        case base = "base"
        case base_90 = "base_90"
        case overlay1 = "overlay1"
        case overlay1_90 = "overlay1_90"
        case overlay2 = "overlay2"
        case tint1 = "tint1"
        case tint2 = "tint2"
        case tint3 = "tint3"
        case shade1 = "shade1"
        case shade2 = "shade2"
        case shade3 = "shade3"
        
        public var name: String {
            return self.rawValue
        }
        
        public var langName: String {
            return String.init(format: "background_%@", self.rawValue)
        }
        
        public var color: NSColor {
            return NSColor.filmoraColor(name: langName)
        }
    }
}


// MARK: - TextIcon

public extension NSColor {
    enum TextIcon: String, WSColorNameProtocol, WSColorProtocol {
        case primary = "primary"
        case secondary = "secondary"
        case disabled = "disabled"
        case tertiary = "tertiary"
        case pressed = "pressed"
        
        public var name: String {
            return self.rawValue
        }
        
        public var langName: String {
            return String.init(format: "textIcon_%@", self.rawValue)
        }
        
        public var color: NSColor {
            return NSColor.filmoraColor(name: langName)
        }
    }
}

// MARK: - Component

public extension NSColor {
    enum Component: String, WSColorNameProtocol, WSColorProtocol  {
        case dividerPrimary = "divider_primary"
        case dividerSecondary = "divider_secondary"
        case control = "control"
        case controlStroke = "control_stroke"
        case input = "input"
        
        public var name: String {
            return self.rawValue
        }
        
        public var langName: String {
            return String.init(format: "component_%@", self.rawValue)
        }
        
        public var color: NSColor {
            return NSColor.filmoraColor(name: langName)
        }
    }
}

// MARK: - State

public extension NSColor {
    enum State : String, WSColorNameProtocol, WSColorProtocol {
        case hover = "hover"
        case pressed = "pressed"
        case disabled = "disabled"
        
        public var name: String {
            return self.rawValue
        }
        
        public var langName: String {
            return String.init(format: "state_%@", self.rawValue)
        }
        
        public var color: NSColor {
            return NSColor.filmoraColor(name: langName)
        }
    }
}

// MARK: - Alert

public extension NSColor {
    enum Alert : String, WSColorNameProtocol, WSColorProtocol {
        case success = "success"
        case danger = "danger"
        case buy = "buy"
        case warning = "warning"
        
        public var name: String {
            return self.rawValue
        }
        
        public var langName: String {
            return String.init(format: "alert_%@", self.rawValue)
        }
        
        public var color: NSColor {
            return NSColor.filmoraColor(name: langName)
        }
    }
}

// MARK: - Filmorax

public extension NSColor {
    enum Filmorax : String, WSColorNameProtocol, WSColorProtocol {
        case primary = "primary"
        case primaryHover = "primary_hover"
        case primaryPressed = "primary_pressed"
        case accent = "accent"
        case accentHover = "accent_hover"
        case accentPressed = "accent_pressed"
        case first = "first"
        case firstHigh = "first_high"
        case firstMedium = "first_medium"
        case firstLow = "first_low"
        case second = "second"
        case secondHigh = "second_high"
        case secondMedium = "second_medium"
        case secondLow = "second_low"
        case third = "third"
        case thirdHigh = "third_high"
        case thirdMedium = "third_medium"
        case thirdLow = "third_low"
        case fourth = "fourth"
        case fourthHigh = "fourth_high"
        case fourthMedium = "fourth_medium"
        case fourthLow = "fourth_low"
        case fifth = "fifth"
        case fifthHigh = "fifth_high"
        case fifthMedium = "fifth_medium"
        case fifthLow = "fifth_low"
        case sixth = "sixth"
        case sixthHigh = "sixth_high"
        case sixthMedium = "sixth_medium"
        case sixthLow = "sixth_low"
        case seventh = "seventh"
        case seventhHigh = "seventh_high"
        case seventhMedium = "seventh_medium"
        case seventhLow = "seventh_low"
        case alchemy = "alchemy"
        case alchemyHigh = "alchemy_high"
        case alchemyMedium = "alchemy_medium"
        case alchemyLow = "alchemy_low"
        
        public var name: String {
            return self.rawValue
        }
        
        public var langName: String {
            return String.init(format: "filmorax_%@", self.rawValue)
        }
        
        public var color: NSColor {
            return NSColor.filmoraColor(name: langName)
        }
    }
}

// MARK: - LocalColorIcon

public extension NSColor {
    enum LocalColorIcon : String, WSColorNameProtocol, WSColorProtocol {
        case titleBackground = "title_background"
        case mask = "mask"
        case specialHover = "special_hover"
        case normal = "normal"
        case disabled = "disabled"
        case hover = "hover"
        case specialPressed = "special_pressed"
        case presetMask = "preset_mask"
        case primaryMarquee = "primary_marquee"
        case deeplin = "deeplin"
        case deepList = "deep_list"
        case lightList = "light_list"
        case tips = "tips"
        case player = "player"
        case colorMatch = "colormatch"
        case secondaryLine = "secondary-line"
        case alchemyNormal = "alchemy_normal"
        case timeline = "timeline"
        
        public var name: String {
            return self.rawValue
        }
        
        public var langName: String {
            return String.init(format: "local_%@", self.rawValue)
        }
        
        public var color: NSColor {
            return NSColor.filmoraColor(name: langName)
        }
    }
}


// MARK: - Wondershare

public extension NSColor {
    enum Wondershare : String, WSColorNameProtocol, WSColorProtocol {
        case cta = "cta"
        case ctaPressed = "cta_pressed"
        case ctaHover = "cta_hover"
        
        public var name: String {
            return self.rawValue
        }
        
        public var langName: String {
            return String.init(format: "wondershare_%@", self.rawValue)
        }
        
        public var color: NSColor {
            return NSColor.filmoraColor(name: langName)
        }
    }
}

#endif
