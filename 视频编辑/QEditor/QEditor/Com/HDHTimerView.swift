//
//  HDHTimerView.swift
//  timeTest
//
//  Created by 郭明健 on 2018/1/5.
//  Copyright © 2018年 艾泽拉斯. All rights reserved.
//

import UIKit

typealias completeCallback = (_ seconds : Int) -> Void

class HDHTimerView: UIView {
    
    //MARK:-
    @IBOutlet weak private var minutesLabel: UILabel!
    @IBOutlet weak private var secondsLabel: UILabel!
    @IBOutlet weak private var msLabel: UILabel!
    
    //MARK:-
    fileprivate var countTimer : Timer?
    fileprivate var minutes : Int = 0   //分
    fileprivate var seconds : Int = 0   //秒
    fileprivate var ms : Int = 0        //毫秒
    
    //MARK:- 外部属性
    var maxSeconds : Int = 10 { //计时器停止时间.(单位秒，默认10)
        didSet {
            if maxSeconds < 0 || maxSeconds > 3600 {
                maxSeconds = 10
            }
        }
    }
    var timeCompleteBlock : completeCallback?
    
}

//MARK:-
extension HDHTimerView
{
    //MARK:- 外部方法
    /// 计数器开始
    func start ()
    {
        stop()
        countTimer = Timer.init(timeInterval: 0.01, target: self, selector: #selector(self.timeRunning), userInfo: nil, repeats: true)
        RunLoop.main.add(countTimer!, forMode: .common)
    }
    
    /// 计数器暂停
    func stop()
    {
        countTimer?.invalidate()
        countTimer = nil
    }
    
    /// 计数器复位
    func reset()
    {
        stop()
        minutes = 0
        seconds = 0
        ms = 0
        updateUI()
    }
    
    //MARK:-
    //开始计数
    @objc fileprivate func timeRunning()
    {
        ms += 1
        
        if ms == 100 {
            seconds += 1
            ms = 0;
        }
        
        if seconds == 60 {
            minutes += 1;
            seconds = 0;
        }
        
        let totalTime = self.getTotalTime()
        if (totalTime == maxSeconds * 100) {
            if timeCompleteBlock != nil {
                timeCompleteBlock!(maxSeconds)
                self.stop()
            }
        }
        
        if minutes == 60 {
            self.reset()
        }
        
        self.updateUI()
    }

    //获取当前计时总时间（毫秒）
    func getTotalTime() -> (Int) {

        var totalTime = ms
        totalTime += seconds * 100
        totalTime += minutes * 60 * 100

        return totalTime
    }
    
    //刷新UI
    fileprivate func updateUI()
    {
        minutesLabel.text = String.init(format: "%02d", minutes)
        secondsLabel.text = String.init(format: "%02d", seconds)
        msLabel.text = String.init(format: "%02d", ms)
    }
}

//MARK:- 从xib中快速创建的类方法
extension HDHTimerView
{
    class func getTimerView() -> HDHTimerView
    {
        return Bundle.main.loadNibNamed("HDHTimerView", owner: nil, options: nil)?.first as! HDHTimerView
    }
}
