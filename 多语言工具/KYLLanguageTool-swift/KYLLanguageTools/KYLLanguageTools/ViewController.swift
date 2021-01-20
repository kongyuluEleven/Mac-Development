//
//  ViewController.swift
//  KYLLanguageTools
//
//  Created by kongyulu on 2021/1/20.
//

import Cocoa

class ViewController: NSViewController {
    
    
    /// excel文件路径输入框
    @IBOutlet weak var xlsTextField: NSTextField!
    
    /// localstring文件路径输入框
    @IBOutlet weak var stringTextField: NSTextField!
    
    /// excel 导入 string
    @IBOutlet weak var radioExcelToString: NSButton!
    
    /// string导入excel
    @IBOutlet weak var radioStringToExcel: NSButton!
    
    
    /// 选择excel
    @IBOutlet weak var btnExcel: NSButton!
    
    
    /// 选择String
    @IBOutlet weak var btnString: NSButton!
    
    
    /// 开始导出
    @IBOutlet weak var btnStart: NSButton!
    
    
    /// 导出未添加的key
    @IBOutlet weak var btnExportUnkey: NSButton!
    
    
    /// 一键保存多语言
    @IBOutlet weak var btnOneKeySave: NSButton!
    
    
    private var isExcelToString:Bool = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareUI()
        updateRadioUI()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    /// 点击选择Excel文件
    /// - Parameter sender: 消息发送者
    @IBAction func btnExcelClicked(_ sender: Any) {
        /* 读取 CSV 文件并赋值到文本框里面 */
        self.xlsTextField.stringValue = String.getFile(fileTypes: ["xls","csv"])
    }
    
    
    /// 点击选择LocalString文件
    /// - Parameter sender: 消息发送者
    @IBAction func btnStringClicked(_ sender: Any) {
        self.stringTextField.stringValue = String.getDirectory() ?? ""
    }
    
    /// 点击开始
    /// - Parameter sender: 消息发送者
    @IBAction func btnStartClicked(_ sender: Any) {
        let filePath = self.xlsTextField.stringValue
        guard !filePath.isEmpty else {
            debugPrint("路径为空")
            let _ = NSAlert(message: "路径为空").runModal()
            return
        }
    
        if !filePath.isSuffix(type: "xls"), !filePath.isSuffix(type: "csv") {
            debugPrint("格式不对")
            let _ = NSAlert(message: "格式不对").runModal()
            return
        }
        
        if isExcelToString {
            KLanguageToolManager.shared.exportExcelToStringFile(filePath: filePath)
        } else {
            KLanguageToolManager.shared.inputStringToDefaultExcelFile()
        }
    }
    
    /// 点击导出未添加的key
    /// - Parameter sender: 消息发送者
    @IBAction func btnOneKeyClicked(_ sender: Any) {
    }
    
    
    /// 点击一键保存多语言
    /// - Parameter sender: 消息发送者
    @IBAction func btnOneKeySaveClicked(_ sender: Any) {
    }
    
    
    @IBAction func radioExcelToStringClicked(_ sender: Any) {
        isExcelToString = true
        updateRadioUI()
    }
    
    @IBAction func radioStringToExcelClicked(_ sender: Any) {
        isExcelToString = false
        updateRadioUI()
    }
}

//MARK: - UI初始化
extension ViewController {
    private func prepareUI() {
        
    }
    
    private func updateRadioUI() {
        if isExcelToString {
            radioExcelToString.state = .on
            radioStringToExcel.state = .off
        } else {
            radioExcelToString.state = .off
            radioStringToExcel.state = .on
        }
    }
}


//MARK: - 事件处理
extension ViewController {
    
}

//MARK: - 逻辑处理
extension ViewController {
    
}

