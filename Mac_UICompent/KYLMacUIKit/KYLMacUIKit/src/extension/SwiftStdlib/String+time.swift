//
//  String+time.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

// MARK: - 静态，类方法
public extension String {
    
    /// 格式化毫秒时间戳为00:00:00:00 格式的字符串
    ///  hour :  minute :  second  :  frame
    ///  ==》   String.formatToHMSF(milliSecond: 3600000, frameRate: 25)
    ///
    ///
    /// - Parameters:
    ///   - milliSecond: 时间戳，毫秒数
    ///   - frameRate: 帧率
    /// - Returns: 返回格式化为00:00:00:00 格式的字符串
    static func formatToHMSF(milliSecond: Int64, frameRate: Int) -> String {
        let frame = Int64(frameRate > 0 ? frameRate : 25)
        let hour = milliSecond / 3600000
        let min = (milliSecond - hour * 3600000) / 60000
        let second = (milliSecond - 3600000 * hour - 60000 * min) / 1000
        let frameCount = milliSecond % 1000 / (1000 / frame)
        
        let str = String(format: "%02d:%02d:%02d:%02d", hour,min,second,frameCount)
        return str
    }
    
    
    /// 格式化毫秒时间戳为00:00:00 格式的字符串
    ///  hour :  minute :  second  :
    ///  ==》   String.formatToHMSF(milliSecond: 3600000)
    ///
    /// - Parameter milliSecond: 时间戳，毫秒数
    /// - Returns: 返回格式化为00:00:00 格式的字符串
    static func formatToHMS(milliSecond: Int64) -> String {
        let hour = milliSecond / 3600000
        let min = (milliSecond - hour * 3600000) / 60000
        let second = (milliSecond - 3600000 * hour - 60000 * min) / 1000
        let str = String(format: "%02d:%02d:%02d", hour,min,second)
        return str
    }
    
    /// 格式化秒时间戳为00:00:00 格式的字符串
    ///  hour :  minute :  second  :
    ///  ==》   String.formatToHMSF(second: 3600000)
    ///
    /// - Parameter second: 时间戳，秒数
    /// - Returns: 返回格式化为00:00:00 格式的字符串
    static func formatToHMS(second: Int64) -> String {
        let hour = second / 3600
        let min = second % 3600 / 60
        let second = second % 3600 % 60
        let str = String(format: "%02d:%02d:%02d", hour,min,second)
        return str
    }
}

// MARK: - 格式化 得到新的时间戳字符串
public extension String {
    
    /// 得到一个格式化为“00：00：00” 格式的字符串
    ///   "hour :  minute  : second  "
    /// - Returns: 格式化的字符串
    func timeFormatHMS() -> String {
        var newString:String = self
        let timeString = self
        let strList = timeString.components(separatedBy: ":")
        if strList.count > 1 {
            //默认为已经格式化的字符串
            return timeString
        }
        var subStr1 = "00"
        var subStr2 = "00"
        var subStr3 = "00"
        let nsStr = timeString as NSString
        let strLen = nsStr.length
        if strLen >= 6 {
            subStr3 = nsStr.substring(with: NSMakeRange(strLen-2, 2))
            subStr2 = nsStr.substring(with: NSMakeRange(strLen-4, 2))
            subStr1 = nsStr.substring(with: NSMakeRange(strLen-6, 2))
        } else if strLen >= 4 {
            subStr3 = nsStr.substring(with: NSMakeRange(strLen-2, 2))
            subStr2 = nsStr.substring(with: NSMakeRange(strLen-4, 2))
            subStr1 = nsStr.substring(with: NSMakeRange(0, 1))
        } else if strLen >= 2 {
            subStr3 = nsStr.substring(with: NSMakeRange(strLen-2, 2))
            subStr2 = nsStr.substring(with: NSMakeRange(0, 1))
        } else {
            subStr3 = timeString
        }
        
        newString = "\(subStr1):\(subStr2):\(subStr3)"
        
        return newString
    }
    
    /// 得到一个格式化为“00：00：00 : 00” 格式的字符串
    ///  "hour :  minute  : second  :  format"
    /// - Returns: 格式化的字符串
    func timeFormatHMSF() -> String {
        var newString:String = self
        let timeString = self
        let strList = timeString.components(separatedBy: ":")
        if strList.count > 1 {
            //默认为已经格式化的字符串
            return timeString
        }
        var subStr1 = "00"
        var subStr2 = "00"
        var subStr3 = "00"
        var subStr4 = "00"
        let nsStr = timeString as NSString
        let strLen = nsStr.length
        if strLen >= 8 {
            subStr4 = nsStr.substring(with: NSMakeRange(strLen-2, 2))
            subStr3 = nsStr.substring(with: NSMakeRange(strLen-4, 2))
            subStr2 = nsStr.substring(with: NSMakeRange(strLen-6, 2))
            subStr1 = nsStr.substring(with: NSMakeRange(strLen-8, 2))
        } else if strLen >= 6 {
            subStr4 = nsStr.substring(with: NSMakeRange(strLen-2, 2))
            subStr3 = nsStr.substring(with: NSMakeRange(strLen-4, 2))
            subStr2 = nsStr.substring(with: NSMakeRange(strLen-6, 2))
            subStr1 = nsStr.substring(with: NSMakeRange(0, 1))
        } else if strLen >= 4 {
            subStr4 = nsStr.substring(with: NSMakeRange(strLen-2, 2))
            subStr3 = nsStr.substring(with: NSMakeRange(strLen-4, 2))
            subStr2 = nsStr.substring(with: NSMakeRange(0, 1))
        } else if strLen >= 2 {
            subStr4 = nsStr.substring(with: NSMakeRange(strLen-2, 2))
            subStr3 = nsStr.substring(with: NSMakeRange(0, 1))
        } else {
            subStr4 = timeString
        }
        
        newString = "\(subStr1):\(subStr2):\(subStr3):\(subStr4)"
        
        return newString
    }
}

// MARK: - 格式化 得到Int类型时间戳信息
public extension String {
    
    /// 将一个“00：00：00” 格式的字符串转换为一个Int三元组，（hour, minute, second）
    /// - Returns: 转换成功则返回（hour, minute, second） 元组，否则返回nil
    func HMS() -> (hour:Int32, minute:Int32, second:Int32)? {
        let timeString = self
        
        let list = timeString.components(separatedBy: ":")
        guard list.count > 0 else {
            return nil
        }
        
        var second:Int32 = 0
        var minute:Int32 = 0
        var hour:Int32 = 0
        
        var isSetSecond = false
        var isSetMinute = false
        var isSetHour = false
        
        for i in (0..<list.count).reversed() {
            let item = list[i] as NSString
            
            if item.length == 0 { //无效字符
                continue
            }
            
            //获取小时
            if !isSetHour {
                hour = item.intValue
                isSetHour = true
            }
            
            //获取分
            if !isSetMinute {
                minute = item.intValue
                isSetMinute = true
            }
            
            //获取秒
            if !isSetSecond {
                second = item.intValue
                isSetSecond = true
            }
        }
        
        return (hour,minute,second)
    }
    
    /// 将一个“00：00：00：00” 格式的字符串转换为一个Int四元组，（hour, minute, second, frameRate）
    /// - Returns: 转换成功则返回（hour, minute, second, frameRate） 元组，否则返回nil
    func HMSF() -> (hour:Int32, minute:Int32, second:Int32, frame:Int32)? {

        let timeString = self
        
        let list = timeString.components(separatedBy: ":")
        guard list.count > 0 else {
            return nil
        }
        
        var frameRate:Int32 = 0
        var second:Int32 = 0
        var minute:Int32 = 0
        var hour:Int32 = 0
        
        var isSetFramerate = false
        var isSetSecond = false
        var isSetMinute = false
        var isSetHour = false
        
        for i in (0..<list.count).reversed() {
            let item = list[i] as NSString
            
            if item.length == 0 { //无效字符
                continue
            }
            
            //获取帧率
            if !isSetFramerate {
                frameRate = item.intValue
                isSetFramerate = true
            }
            
            //获取小时
            if !isSetHour {
                hour = item.intValue
                isSetHour = true
            }
            
            //获取分
            if !isSetMinute {
                minute = item.intValue
                isSetMinute = true
            }
            
            //获取秒
            if !isSetSecond {
                second = item.intValue
                isSetSecond = true
            }
        }
        
        return (hour,minute,second, frameRate)
    }
}
