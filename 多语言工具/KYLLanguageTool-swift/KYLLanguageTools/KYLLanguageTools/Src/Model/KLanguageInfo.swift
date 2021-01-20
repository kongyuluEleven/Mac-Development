//
//  KLanguageInfo.swift
//  KYLLanguageTools
//
//  Created by kongyulu on 2021/1/20.
//



class KLanguageInfo {
    /// 名称
    let name:String?
    /// 已经本地化的值的列表
    var values:[String:Any] = [:]
    
    required init(name:String, dic:[String:Any]? = nil) {
        self.name = name
        dic?.forEach({ (key:String, value:Any) in
            self.values[key] = value
        })
    }
}
