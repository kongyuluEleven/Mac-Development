//
//  HDHProgressBarView.swift
//  timeTest
//
//  Created by 郭明健 on 2018/1/8.
//  Copyright © 2018年 艾泽拉斯. All rights reserved.
//

import UIKit

class HDHProgressBarView: UIView {
    
    //MARK:-
    @IBOutlet weak private var contentView: UIView!

    //MARK:- 外部属性
    var progressBarBackgroundColor : UIColor = UIColor.green {
        didSet {
            contentView.backgroundColor = progressBarBackgroundColor
        }
    }
    var finishedTime : Int = 10 { //进度条完成所需时间，默认10秒
        didSet {
            if  finishedTime < 0 {
                finishedTime = 10
            }
        }
    }
    var refreshFrequency : TimeInterval = 0.1 { //进度条刷新频率（秒）
        didSet {
            if refreshFrequency > 2 || refreshFrequency < 0.01 {
                refreshFrequency = 0.1
            }
        }
    }
    
    //MARK:-
    fileprivate var progressTimer : Timer?
    fileprivate var currentRunTime : CGFloat = 0 //当前进度时间（秒）
    fileprivate var percentage : CGFloat = 0 //进度百分比
    
}

//MARK:-
extension HDHProgressBarView
{
    //MARK:- 外部方法
    /// 进度条开始
    func start ()
    {
        stop()
        progressTimer = Timer.init(timeInterval: refreshFrequency, target: self, selector: #selector(self.timeRunning), userInfo: nil, repeats: true)
        RunLoop.main.add(progressTimer!, forMode: .common)
    }
    
    /// 进度条暂停
    func stop()
    {
        progressTimer?.invalidate()
        progressTimer = nil
    }
    
    /// 进度条复位
    func reset()
    {
        stop()
        currentRunTime = 0
        percentage = 0
        updateUI()
    }
    
    //MARK:-
    //进度开始加载
    @objc fileprivate func timeRunning()
    {
        currentRunTime += CGFloat(refreshFrequency)
        if currentRunTime > CGFloat(finishedTime)
        {
            self.stop()
            return
        }
        percentage = currentRunTime / CGFloat(finishedTime)
        self.updateUI()
    }
    
    //刷新UI
    fileprivate func updateUI()
    {
        UIView.animate(withDuration: refreshFrequency) {
            var frame = self.contentView.frame
            let width = self.percentage * CGFloat(self.frame.size.width)
            frame.size.width = width
            self.contentView.frame = frame
        }
    }
}

//MARK:- 从xib中快速创建的类方法
extension HDHProgressBarView
{
    class func getProgressBarView() -> HDHProgressBarView
    {
        return Bundle.main.loadNibNamed("HDHProgressBarView", owner: nil, options: nil)?.first as! HDHProgressBarView
    }
}
