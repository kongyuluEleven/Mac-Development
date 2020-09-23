//
//  ViewController.swift
//  KRemoveNoiseDemo
//
//  Created by kongyulu on 2020/9/17.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let tool = NoiseTool()
        tool.testNoiseRemove()
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

