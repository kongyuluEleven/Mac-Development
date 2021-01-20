//
//  KUserConfigInfo.swift
//  KYLLanguageTools
//
//  Created by kongyulu on 2021/1/20.
//

import Cocoa

class KUserConfigInfo {
    
    var projectRootPath:String?

    var projectLanguageCode:[String:String] = [:]
    
    var searchLocalizetionPrefix:String = "LocalizedString"
    
    var filterLocalizedNames:[String] = []
    
    var checkPlaceholders:[String] = []
    
    var fixValues:[String:String] = [:]

    init() {
        if let oldLanguageCode = UserDefaults.standard.object(forKey: "projectLanguageCode") as? [String:String] {
            self.projectLanguageCode = oldLanguageCode
        }
        if let fixValues = UserDefaults.standard.object(forKey: "fixValues") as? [String:String] {
            self.fixValues = fixValues
        }
        if let filterLocalizedNames = UserDefaults.standard.object(forKey: "filterLocalizedNames") as? [String]  {
            self.filterLocalizedNames = filterLocalizedNames
        }
        if let checkPlaceholders = UserDefaults.standard.object(forKey: "checkPlaceholders") as? [String]  {
            self.checkPlaceholders = checkPlaceholders
        }
        
        if let searchLocalizetionPrefix = UserDefaults.standard.object(forKey: "searchLocalizetionPrefix") as? String {
            if searchLocalizetionPrefix.count > 0 {
                self.searchLocalizetionPrefix = searchLocalizetionPrefix
            }
        }
    }
    
    func save() {
        let userDefault = UserDefaults.standard
        userDefault.set(self.projectLanguageCode, forKey: "projectLanguageCode")
        userDefault.set(self.filterLocalizedNames, forKey: "filterLocalizedNames")
        userDefault.set(self.checkPlaceholders, forKey: "checkPlaceholders")
        userDefault.set(self.searchLocalizetionPrefix, forKey: "searchLocalizetionPrefix")
        userDefault.set(self.fixValues, forKey: "fixValues")
        userDefault.synchronize()
    }

    func languageCodeString() -> String {
        return transferMapToString(map: self.projectLanguageCode)
    }
    
    func transferMapToString(map:[String:String]) -> String {
        var codeList:[String] = []
        for (key,value) in map {
            let subString = "\(key):\(value)"
            codeList.append(subString)
        }
        return codeList.joined(separator: "\n")
    }
}
