//
//  NSObject+Extension.swift
//  BaseUIKit
//
//  Created by kongyulu on 2020/12/18.
//  Copyright © 2020 Wondershare. All rights reserved.
//

#if canImport(Cocoa)
import Cocoa

public extension NSObject {
    ///获取类名
    func classNameStr() -> String {
        let project_cls_name: String = NSStringFromClass(type(of: self))
        let range = (project_cls_name as NSString).range(of: ".")
        guard range.length > 1 else {return "unknow class name"}
        let cls_name = (project_cls_name as NSString).substring(from: range.location + 1) as String
        return cls_name
    }
    
    ///获取一个对象的str
    var className: String {
        return classNameStr()
    }
    
    
    /// 获取类名
    /// - Returns: 返回对象的类型
    class func getClassName() -> String {
        let names = className().components(separatedBy: ".")
        return names.last ?? ""
    }
}


enum AssociationPolicy {
    case assign
    case retainNonatomic
    case copyNonatomic
    case retain
    case copy

    var rawValue: objc_AssociationPolicy {
        switch self {
        case .assign:
            return .OBJC_ASSOCIATION_ASSIGN
        case .retainNonatomic:
            return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        case .copyNonatomic:
            return .OBJC_ASSOCIATION_COPY_NONATOMIC
        case .retain:
            return .OBJC_ASSOCIATION_RETAIN
        case .copy:
            return .OBJC_ASSOCIATION_COPY
        }
    }
}

final class ObjectAssociation<Value: Any> {
    private let defaultValue: Value
    private let policy: AssociationPolicy

    init(defaultValue: Value, policy: AssociationPolicy = .retainNonatomic) {
        self.defaultValue = defaultValue
        self.policy = policy
    }

    subscript(index: AnyObject) -> Value {
        get {
            objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as? Value ?? defaultValue
        }
        set {
            objc_setAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque(), newValue, policy.rawValue)
        }
    }
}

extension ObjectAssociation {
    convenience init<T>(policy: AssociationPolicy = .retainNonatomic) where Value == T? {
        self.init(defaultValue: nil, policy: policy)
    }
}


private let bindLifetimeAssociatedObjectKey = ObjectAssociation<[AnyObject]>(defaultValue: [])

/// 将对象A的生存期绑定到对象B，因此当B释放时，A也会释放，但在此之前不会。
func bindLifetime(of object: AnyObject, to target: AnyObject) {
    var retainedObjects = bindLifetimeAssociatedObjectKey[target]
    retainedObjects.append(object)
    bindLifetimeAssociatedObjectKey[target] = retainedObjects
}


// MARK: - KVO utilities
extension NSKeyValueObservation {
    /// 使观察保持与给定对象一样长。
    @discardableResult
    func tiedToLifetimeOf(_ object: AnyObject) -> Self {
        bindLifetime(of: self, to: object)
        return self
    }
}

extension NSObjectProtocol where Self: NSObject {
    /// 方便的“观察”函数，在初始和新值上触发，只提供新值。
    func observe<Value>(
        _ keyPath: KeyPath<Self, Value>,
        onChange: @escaping (Value) -> Void
    ) -> NSKeyValueObservation {
        observe(keyPath, options: [.initial, .new]) { _, change in
            guard let newValue = change.newValue else {
                return
            }

            onChange(newValue)
        }
    }

    /**
     将一个对象的属性绑定到另一个对象的属性。

    ```
    window.bind(\.title, to: toolbarItem, at: \.title)
        .tiedToLifetimeOf(self)
    ```
    */
    func bind<Value, Target>(
        _ sourceKeyPath: KeyPath<Self, Value>,
        to target: Target,
        at targetKeyPath: ReferenceWritableKeyPath<Target, Value>
    ) -> NSKeyValueObservation {
        observe(sourceKeyPath) {
            target[keyPath: targetKeyPath] = $0
        }
    }

    /**
     绑定的字符串一个对象的'属性转换为另一个对象的' String '属性。
     如果source属性是' nil '并且目标是不可选的，那么目标将被设置为一个空字符串。

    ```
    webView.bind(\.title, to: window, at: \.title)
        .tiedToLifetimeOf(self)
    ```
    */
    func bind<Target>(
        _ sourceKeyPath: KeyPath<Self, String?>,
        to target: Target,
        at targetKeyPath: ReferenceWritableKeyPath<Target, String>
    ) -> NSKeyValueObservation {
        observe(sourceKeyPath) {
            target[keyPath: targetKeyPath] = $0 ?? ""
        }
    }
}


#endif
