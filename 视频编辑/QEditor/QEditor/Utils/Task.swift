//
//  Task.swift
//  RealtimeMatte
//
//  Created by ws on 2020/9/11.
//  Copyright © 2020 ws. All rights reserved.
//

import Foundation

class Task {
    
    private let lock = NSLock()
    private var _isBusy: Bool = false
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    var isBusy: Bool {
        lock.lock()
        defer { lock.unlock() }
        return _isBusy
    }
    
    func transitToBusy(_ busy: Bool) {
        _isBusy = busy
    }
}
