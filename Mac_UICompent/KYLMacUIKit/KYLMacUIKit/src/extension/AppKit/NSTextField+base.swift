//
//  NSTextField+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit

// MARK: - 属性

public extension NSTextField {
    /// 标签的高度要求
    var requiredHeight: CGFloat {
        let label = NSTextField(frame: CGRect(x: 0, y: 0, width: frame.width, height: CGFloat.greatestFiniteMagnitude))
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.font = font
        label.stringValue = stringValue
        label.attributedStringValue = attributedStringValue
        label.sizeToFit()
        return label.frame.height
    }
    
    /// 内容是否为空
    var isEmpty:Bool {
        return !(stringValue.count > 0)
    }
}


// MARK: - Methods

public extension NSTextField {
    /// 用text初始化一个NSTextField
    convenience init(text: String?) {
        self.init()
        self.stringValue = text ?? ""
    }

    
    
    /// 当前是否处于编辑状态
    /// - Returns: 返回当前是否处于编辑状态
    func isEditing() -> Bool {
        var isEditing = false
        if let textEditor = window?.fieldEditor(false, for: self){
            if let isEq = textEditor.delegate?.isEqual(self) , isEq == true{
                isEditing = true
            }
        }
        return isEditing
    }
}

// MARK: - 时间控件用到

public extension NSTextField {
    
    /// 在原始内容上追加标签内容，使用defaultSperactor为分割符号
    /// - Parameters:
    ///   - label: 标签内容
    ///   - defaultSperactor: 分割符号
    func addPromptLabel(label:String, defaultSperactor:String = ":") {
        guard !isEmpty else {return}
        var value = label
        if !value.contains(defaultSperactor) {
            value = value.appending(defaultSperactor)
        }
        self.stringValue = value
    }
    
    /// 同步slider进度内容到textFiled中
    /// 使用滑块的范围验证字段值，并将接收器或滑块设置为该值(视情况而定)。返回值。
    /// 所有这些都可以通过绑定完成，但这也可以，并且在Mac OS X 10.2中也可以。
    /// - Parameters:
    ///   - slider: 进度条
    ///   - usingFieldValue: 是否使用textFiled的原始值
    func syncronizeValue(with slider: NSSlider, usingFieldValue:Bool = false) -> Int32 {
        let max = slider.maxValue
        var value:Int32 = 0
        
        if usingFieldValue {
            value = self.intValue
        } else {
            value = slider.intValue
        }
        
        var isUsingField = usingFieldValue
        if value < Int32(slider.minValue) || value > Int32(max) {
            isUsingField = false
            value = slider.intValue
        }
        
        if isUsingField {
            slider.intValue = value
        } else {
            var temp = value
            if max > 1000 {
                temp /= 60
            }
            self.intValue = temp
        }
        
        return value
    }
    
    /// 自动垂直调整高度适应窗口大小
    /// 如果字段内容当前不适合它的框架，该方法将调整包含该字段和字段本身的窗口的大小，以便它确实适合。
    /// 窗口和字段只能垂直调整大小。自动调整大小的spring和struts不需要也不受此更改的影响。
    /// 窗口大小只是增加，而不是减少。如果需要调整大小，则返回YES;如果已经足够大，则返回NO。
    func resizeFitToWindowVertically() -> Bool {
        let oldFrame = self.frame
        var newFrame = oldFrame
        
        //确定场地的理想高度:
        newFrame.size.height = 10000.0
        newFrame.size = self.cell?.cellSize(forBounds: newFrame) ?? oldFrame.size
        
        //如果没有变化，或者新的高度会更小，什么都不做:
        if NSHeight(newFrame) <= NSHeight(oldFrame) {return false}
        
        //我们需要调整大小，所以调整自动调整大小蒙版:
        //let masks = self.widthAdjustLimit
        
        //根据新的文本框大小调整窗口大小:
        
        return true
    }
}

#endif
