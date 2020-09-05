//
//  LrcItem.swift
//  KLrcDemo
//
//  Created by kongyulu on 2020/9/4.
//  Copyright © 2020 wondershare. All rights reserved.
//

import Cocoa

struct LRC {
    var time:UInt64
    var lrc:String
}


class LrcAnalyzer: NSObject {
    var lrcList:[LRC] = []
    
    
    
}


extension LrcAnalyzer {
    func lrcList(fromPath:String) -> [LRC] {
        return lrcList
    }
    
    func analyzerLrc(text:String) -> [LRC] {
        let arr = text.components(separatedBy: "\n").filter{!$0.isEmpty}
        arr.forEach { (item) in
            let strArr = item.components(separatedBy: "]")
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "[mm:ss.SS"
            
            if let str1 = strArr.first,let lrcValue = strArr.last,
                let date1 = dateFormat.date(from: str1),
                let date2 = dateFormat.date(from: "[00:00.00") {
                let interval1 = fabs(date1.timeIntervalSince1970 - date2.timeIntervalSince1970)
                let lrc = LRC(time: UInt64(interval1), lrc: lrcValue)
                lrcList.append(lrc)
            }
        }
        return lrcList
    }
}
