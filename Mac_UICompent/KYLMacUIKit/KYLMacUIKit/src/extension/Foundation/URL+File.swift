//
//  URL+File.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation

extension URL {

    /// UIKit: 如果给定文件是目录，则返回true
    public var fileIsDirectory: Bool {
        var isdirv: AnyObject?
        do {
            try (self as NSURL).getResourceValue(&isdirv, forKey: URLResourceKey.isDirectoryKey)
        } catch _ {
        }
        return isdirv?.boolValue ?? false
    }

    /// UIKit: 文件修改日期，如果文件不存在，则为零
    public var fileModifiedDate: Date? {
        get {
            var datemodv: AnyObject?
            do {
                try (self as NSURL).getResourceValue(&datemodv, forKey: URLResourceKey.contentModificationDateKey)
            } catch _ {
            }
            return datemodv as? Date
        }
        set {
            do {
                try (self as NSURL).setResourceValue(newValue, forKey: URLResourceKey.contentModificationDateKey)
            } catch _ {
            }
        }
    }

    /// UIKit: 文件创建日期，如果文件不存在，则为nil
    public var fileCreationDate: Date? {
        get {
            var datecreatev: AnyObject?
            do {
                try (self as NSURL).getResourceValue(&datecreatev, forKey: URLResourceKey.creationDateKey)
            } catch _ {
            }
            return datecreatev as? Date
        }
        set {
            do {
                try (self as NSURL).setResourceValue(newValue, forKey: URLResourceKey.creationDateKey)
            } catch _ {
            }

        }
    }

    /// UIKit: 返回上次文件访问日期，如果文件不存在或尚未访问，则返回nil
    public var fileAccessDate: Date? {
        _ = URLResourceKey.customIconKey
        var dateaccessv: AnyObject?
        do {
            try (self as NSURL).getResourceValue(&dateaccessv, forKey: URLResourceKey.contentAccessDateKey)
        } catch _ {
        }
        return dateaccessv as? Date
    }

    /// UIKit: 返回文件大小，如果文件不存在，则返回-1
    public var fileSize: Int64 {
        var sizev: AnyObject?
        do {
            try (self as NSURL).getResourceValue(&sizev, forKey: URLResourceKey.fileSizeKey)
        } catch _ {
        }
        return sizev?.int64Value ?? -1
    }

    /// UIKit: 文件是否隐藏，不关心是否以点开头的文件
    public var fileIsHidden: Bool {
        get {
            var ishiddenv: AnyObject?
            do {
                try (self as NSURL).getResourceValue(&ishiddenv, forKey: URLResourceKey.isHiddenKey)
            } catch _ {
            }
            return ishiddenv?.boolValue ?? false
        }
        set {
            do {
                try (self as NSURL).setResourceValue(newValue, forKey: URLResourceKey.isHiddenKey)
            } catch _ {
            }
            
        }
    }

    /// UIKit:检查文件是否可写
    public var fileIsWritable: Bool {
        var isdirv: AnyObject?
        do {
            try (self as NSURL).getResourceValue(&isdirv, forKey: URLResourceKey.isWritableKey)
        } catch _ {
        }
        return isdirv?.boolValue ?? false
    }
    
    /// UIKit:检查文件是否可读
    public var fileIsReadable: Bool {
        var isdirv: AnyObject?
        do {
            try (self as NSURL).getResourceValue(&isdirv, forKey: URLResourceKey.isReadableKey)
        } catch _ {
        }
        return isdirv?.boolValue ?? false
    }
}


#endif
