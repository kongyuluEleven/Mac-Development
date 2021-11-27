//
//  Date+time.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

// MARK: - 时间信息转换
public extension Date {
    
    struct WSTimeInfo {
        /// 最大小时数
        public static let MaxHour:Int64 = 24
        
        /// 最大帧率
        public static let MaxFrameRate: Double  = 30.0
        
        /// 时间戳，单位为毫秒
        var value:Int64 = 0
        /// 当前帧率
        var frame:Double = MaxFrameRate
        
        /// 秒数
        var second:Int64 {
            return value / 1000
        }
    
        /// 纳秒数
        var nanoSecond:Int64 {
            return value * 10000
        }
        
    }
}


// MARK: - 时间信息转换
public extension Date {
    
    /// TODO:
    ///  将一个字符串转换为一个WSTimeInfo对象
    /// - Parameter timeString: 需要格式化的字符串，
    /// - Returns: 转换成功返回WSTimeInfo对象，否则返回nil
    static func convert(timeString:String) -> WSTimeInfo? {
        
        let hmsfString = timeString.timeFormatHMSF()
        
        if let hmsf = hmsfString.HMSF() {
            return self.convert(hmsf.hour, hmsf.minute, hmsf.second, hmsf.frame)
        }
            
        let hmsString = timeString.timeFormatHMS()
        
        if let hms = hmsString.HMS() {
            return self.convert(hms.hour, hms.minute, hms.second)
        }
        
        return nil
    }
    
    
    /// 根据时，分，秒，得到一个WSTimeInfo
    /// - Parameters:
    ///   - hour: 小时数
    ///   - minute: 分
    ///   - second: 秒
    /// - Returns: 转换后的WSTimeInfo对象
    static func convert(_ hour:Int32, _ minute:Int32, _ second:Int32) -> WSTimeInfo? {
        var h = hour
        var m = minute
        var s = second
        //处理进位问题
        //进位到分
        m += second / 60
        s = s % 60
        
        //进位到小时
        h += m / 60
        m  = m % 60
        
        var timeValue = (Int64(hour) * 3600 + Int64(minute) * 60 + Int64(second)) * 1000
        if timeValue > (Int64(24) * 3600) * 1000 {
            timeValue = (Int64(hour) * 3600) * 1000
        }
        
        let time = WSTimeInfo(value: timeValue, frame: WSTimeInfo.MaxFrameRate)
        
        return time
    }
    
    ///  根据时，分，秒，帧率，得到一个WSTimeInfo对象
    /// - Parameters:
    ///   - hour: 时
    ///   - minute: 分
    ///   - second: 秒
    ///   - frame: 帧率
    /// - Returns:一个WSTimeInfo对象
    static func convert(_ hour:Int32, _ minute:Int32, _ second:Int32, _ frame:Int32) -> WSTimeInfo? {
        var h = hour
        var m = minute
        var s = second
        var f = frame
        //处理进位问题
        s = f / Int32(WSTimeInfo.MaxFrameRate)
        f = f % Int32(WSTimeInfo.MaxFrameRate)
        
        //进位到分
        m += second / 60
        s = s % 60
        
        //进位到小时
        h += m / 60
        m  = m % 60
        
        var timeValue = (Int64(hour) * 3600 + Int64(minute) * 60 + Int64(second)) * 1000
        if timeValue > (Int64(24) * 3600) * 1000 {
            timeValue = (Int64(hour) * 3600) * 1000
        }
        
        let time = WSTimeInfo(value: timeValue, frame: Double(f))
        return time
    }
}


#endif
