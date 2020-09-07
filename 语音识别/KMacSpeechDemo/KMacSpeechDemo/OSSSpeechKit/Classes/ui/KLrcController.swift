//
//  KLrcController.swift
//  KMacSpeechDemo
//
//  Created by kongyulu on 2020/9/5.
//  Copyright © 2020 wondershare. All rights reserved.
//

import Cocoa
import AVFoundation
import Speech

let SONE = "多幸运"


class KLrcController: NSViewController {
    @IBOutlet weak var tableView: FMTableView!
    //歌词数组
    private var lrcArray:[LRC] = []
    private var needMatchArr:[LRC] = []
    
    private var isDragging:Bool = false
    private var currentRow:Int = 0
    
    private lazy var player:AVPlayer? = {
        guard let path = Bundle.main.url(forResource: SONE, withExtension: "mp3") else {return nil}
        let player = AVPlayer(url: path)
        return player
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        reloadData()
        //play()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

extension KLrcController {
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.gridColor = fm_base_bk_color
        //tableView.doubleAction = #selector(clickLocateMissingFiles(_:))
        tableView.allowsColumnResizing = true
        //let columnsTiles: [String] = [FMLocal("File name"), FMLocal("Original path"), FMLocal("Matched file"), FMLocal("")]
        for index in 0..<tableView.tableColumns.count {
            tableView.tableColumns[index].isEditable = false
            //tableView.tableColumns[index].headerCell.stringValue = columnsTiles[index]
            
            //            tableView.tableColumns[index].headerCell.backgroundColor = NSColor.init(rgb: 0x67DDCF)
            let oldHeaderCell = tableView.tableColumns[index].headerCell
            tableView.tableColumns[index].headerCell = FMTableHeaderCell.init(textCell: oldHeaderCell.stringValue)//NSTableHeaderCell(textCell: oldHeaderCell.stringValue)//
            tableView.tableColumns[index].headerCell.textColor = fm_base_bk_color
            tableView.tableColumns[index].headerCell.drawsBackground = false
        }
        tableView.allowsColumnSelection = false
    }
}

extension KLrcController {
    public func reloadData() {
        let analyzer = LrcAnalyzer()
        guard let path = Bundle.main.url(forResource: "Passage55", withExtension: "txt")?.path else {return}
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {return}
        lrcArray = analyzer.analyzerLrc(text: content)
        needMatchArr.removeAll()
        needMatchArr.append(contentsOf: lrcArray)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    public func play() {
        guard let player = player else {return}
        
        player.addPeriodicTimeObserver(forInterval: CMTime(seconds: 3, preferredTimescale: 30), queue: DispatchQueue.main) { [weak self] (time) in
            guard let self = self else {return}
            let currentTime = CMTimeGetSeconds(time)
            //let total = player.currentItem?.duration
            let totalTime = CMTimeGetSeconds(player.currentItem?.duration ?? time)
            
            if !self.isDragging {
                //歌词滚动显示
                for  i in 0 ... self.lrcArray.count-1 {
                    let item = self.lrcArray[i]
                    if Double(item.time) < currentTime {
                        self.currentRow = i
                        //let currentIndexPath = NSIndexPath(forItem: i, inSection: 0)
                        self.tableView.scrollRowToVisible(i+3)
                        self.tableView.reloadData()
                    }
                }
            }
        }
        
        player.play()
    }
    
    public func match(subString:String) {
        guard let kmp = GMatcherExpression(pattern: subString, option: .KMP) else {return}
        for i in 0 ... lrcArray.count-1  {
            let lineStr = lrcArray[i].lrc
            //let matchRange = kmp.rangeOfFirstMatch(in: lineStr)
            if let matchArr = kmp.matches(in: lineStr), let range = matchArr.first?.range, currentRow != i {
                currentRow = i
                self.tableView.scrollRowToVisible(i)
                self.tableView.reloadData()
                return
            }
        }
    }
    
    public func match(recognitionRes:SFSpeechRecognitionResult) {
        
        let best = recognitionRes.bestTranscription
        guard let kmp = GMatcherExpression(pattern: best.formattedString, option: .KMP) else {return}
        
        guard let firstRange = best.segments.first else {return}
        
        let firstWord = firstRange.substring
        let firstWordRange = firstRange.substringRange
        
        let matchLines = lrcArray.filter { (item) -> Bool in
            
            guard let ranga = item.lrc.range(of: firstWord) else {return false}
            
            let ra = item.lrc.nsrange(fromRange: ranga)
            
            return ra == firstWordRange
        }
        
        for i in 0 ... lrcArray.count-1  {
            let lineStr = lrcArray[i].lrc
            if let matchArr = kmp.matches(in: lineStr), let range = matchArr.first?.range, currentRow != i {
                currentRow = i
                self.tableView.scrollRowToVisible(i)
                self.tableView.reloadData()
                return
            }
        }
        
        var j = best.segments.count - 1
        var list = [SFTranscriptionSegment]()
        list.append(contentsOf: best.segments)
        while j > 0 {
            let translate = list.map({ (item) -> String in
                return item.substring
            }).joined(separator: " ")
            
            if let kmp = GMatcherExpression(pattern:translate, option: .KMP) {
                if let index = lrcArray.firstIndex(where: { (item) -> Bool in
                    if let match = kmp.firstMatch(in: item.lrc) {
                        return true
                    }
                    return false
                }) {
                    currentRow = index
                    self.tableView.scrollRowToVisible(currentRow)
                    self.tableView.reloadData()
                    return
                }
            }
                
            list.removeLast()
            j = j - 1
        }
        
    }
}

extension KLrcController:NSTableViewDelegate {

}

extension KLrcController:NSTableViewDataSource {
    
    
    public func numberOfRows(in tableView: NSTableView) -> Int {
        return self.lrcArray.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        let cellView: MissFileCellView = MissFileCellView.init(frame: NSMakeRect(0, 0, tableView.frame.size.width, 60))
        cellView.autoresizingMask = [NSView.AutoresizingMask.maxXMargin, NSView.AutoresizingMask.minXMargin, NSView.AutoresizingMask.width]
        
        guard let tableColumn = tableColumn else {
            return cellView
        }
        
        if let columnIndex = tableView.tableColumns.index(of: tableColumn) {
            switch columnIndex {
            case 0:
                cellView.labelView = FMIconTextField.init(frame: cellView.bounds)
                cellView.labelView?.stringValue = lrcArray[row].lrc
                cellView.labelView?.lineBreakMode = .byCharWrapping
                cellView.labelView?.alignment = .left
                if currentRow == row {
                    cellView.labelView?.textColor = .green
                } else {
                    cellView.labelView?.textColor = .white
                }
                
            case 1:
                cellView.labelView = FMIconTextField.init(frame: cellView.bounds)
                //                    cellView.labelView?.lineBreakMode = NSParagraphStyle.LineBreakMode.byTruncatingMiddle
                //                    cellView.labelView?.textColor = fm_base_label_color
                //                    cellView.labelView?.stringValue = arrMissingFiles[row].deleteLastPathComponent()
                
            default:
                break
            }
        }
        
        return cellView
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let frame: NSRect = NSMakeRect(0, 0, tableView.frame.size.width, tableView.frame.size.height)
        let rowView: FMTableRowView = FMTableRowView.init(frame:frame)

        let evenColor = NSColor.init(rgb: 0x242B33)
        let oddColor = NSColor.init(rgb: 0x2A313A)
        rowView.bkColor = (0 == row % 2) ? evenColor : oddColor
        return rowView
    }
    
    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 60
    }
}

