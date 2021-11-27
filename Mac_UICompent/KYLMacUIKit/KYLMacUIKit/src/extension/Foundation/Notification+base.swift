//
//  Notification+base.swift
//  KYLMacUIKit
//
//  Created by kongyulu on 2021/11/27.
//

#if canImport(Foundation)
import Foundation


public typealias NotifyName = NSNotification.Name
public typealias NotificationHandle = ((Notification) -> Void)


public extension NotificationCenter {
    /// 向通知中心的调度表添加一个一次性条目，其中包括一个通知队列和要添加到队列中的块，以及一个可选的通知名称和发送方。
    ///
    ///
    ///            NotificationCenter.default.observeOnce(forName: NSNotification.Name("AppearenceChangeToLightModel"),
    ///                           object: self,
    ///                           queue: OperationQueue.main) { (notificaton) in
    ///                                       print("收到通知 \(notificaton)")
    ///                                  }
    ///
    ///
    ///
    /// - Parameters:
    ///   - name: 须为其注册观察员的通知的名称;也就是说，只有使用此名称的通知才能将块添加到操作队列中。
    ///
    ///     如果你传递' nil '，通知中心不会使用通知的名称来决定是否将块添加到操作队列。
    ///   - obj: 观察者想要接收的通知的对象;也就是说，只有这个发送方发送的通知才会被发送到观察者。
    ///
    ///     如果你传递' nil '，通知中心不会使用通知的发送者来决定是否发送给观察者。
    ///   - queue: 应该添加块的操作队列。
    ///
    ///     如果你传递' nil '， block会在发布线程上同步运行。
    ///   - block: 接收到通知时要执行的块。
    ///
    ///     区块被通知中心复制，并且(副本)一直保存到观察者注册被删除。
    ///
    ///     块有一个参数:
    ///   - notification: 传回注册的通知
    func observeOnce(forName name: NSNotification.Name?,
                     object obj: Any? = nil,
                     queue: OperationQueue? = nil,
                     using block: @escaping (_ notification: Notification) -> Void) {
        var handler: NSObjectProtocol!
        handler = addObserver(forName: name, object: obj, queue: queue) { [unowned self] in
            self.removeObserver(handler!)
            block($0)
        }
    }
}
// MARK: - 通知分发
extension NotificationCenter {
    
    /// 确保在主线程中分发通知
    /// - Parameter notification: 需要分发的通知对象
    public func postOnMainThread(_ notification: Notification) {
        if Thread.current.isMainThread {
            self.post(notification)
        } else {
            DispatchQueue.main.async {
                self.post(notification)
            }
        }
    }
    
    
    /// 确保在主线程中分发通知
    /// - Parameters:
    ///   - name: 通知名称
    ///   - object: 可行对象
    ///   - userInfo: 可行字典参数
    public func postNameOnMainThread(name: NSNotification.Name, object: Any?, userInfo: [AnyHashable : Any]? = nil) {
        if Thread.current.isMainThread {
            self.post(name: name, object: object, userInfo: userInfo)
        } else {
            DispatchQueue.main.async {
                self.post(name: name, object: object, userInfo: userInfo)
            }
        }
    }
    
    /// 添加通知，走block回调
    /// - Parameters:
    ///   - name: 通知名(NotifyName)
    ///   - object: object description
    ///   - queue: OperationQueue
    ///   - handle: 默认回调方法
    @discardableResult
    public func addObserver(name: NotifyName,
                            object: Any? = nil,
                            queue: OperationQueue? = nil,
                            handle: @escaping NotificationHandle) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: name, object: object, queue: queue, using: handle)
    }
    
    /// 添加通知，走block回调
    /// - Parameters:
    ///   - name: 通知名(String)
    ///   - object: object description
    ///   - queue: The operation queue to which block should be added.
    ///   If you pass nil, the block is run synchronously on the posting thread.
    ///   - handle: 默认回调方法
    @discardableResult
    public func addObserver(name: String,
                            object: Any? = nil,
                            queue: OperationQueue? = nil,
                            handle: @escaping NotificationHandle) -> NSObjectProtocol {
        let newName = NotifyName(name)
       return NotificationCenter.default.addObserver(forName: newName, object: object, queue: queue, using: handle)
    }
    
    /// 添加通知，走`Selector`
    /// - Parameters:
    ///   - observer: observer object
    ///   - name: 通知名(NotifyName)
    ///   - selector: selector description
    ///   - object: object description
    public func addObserver(_ observer: Any,
                            name: NotifyName,
                            selector: Selector,
                            object: Any? = nil) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: object)
    }
    
    /// 添加通知，走`Selector`
    /// - Parameters:
    ///   - observer: observer object
    ///   - name: 通知名(String)
    ///   - selector: selector description
    ///   - object: object description
    public func addObserver(_ observer: Any,
                            name: String,
                            selector: Selector,
                            object: Any? = nil) {
        let newName = NotifyName(name)
         NotificationCenter.default.addObserver(observer, selector: selector, name: newName, object: object)
    }
    
    /// 发送通知
    /// - Parameters:
    ///   - name: 通知名
    ///   - object: object
    ///   - userInfo: 通知的内容
    ///   - reserve: 保留字段，没有用到
    public func post(name: NotifyName, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil, reserve: String="") {
        NotificationCenter.default.post(name: name, object: object, userInfo: userInfo)
    }
    
    /// 发送通知
    /// - Parameters:
    ///   - name: 通知名
    ///   - object: object
    ///   - userInfo: 通知的内容
    public func post(name: String, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: NotifyName(name), object: object, userInfo: userInfo)
    }
    
    /// 移除通知
    /// - Parameters:
    ///   - name: 通知名
    ///   - object: 添加通知时传入的对象
    public func removeObserver(_ observer: Any, name: String, object: Any? = nil) {
        NotificationCenter.default.removeObserver(observer, name: NotifyName(name), object: object)
    }
    
    
}

extension NotificationQueue {
    public func enqueueOnMainThread(_ notification: Notification, postingStyle: NotificationQueue.PostingStyle) {
        if Thread.current.isMainThread {
            self.enqueue(notification, postingStyle: postingStyle)
        }
        
        DispatchQueue.main.sync {
            self.enqueue(notification, postingStyle: postingStyle)
        }
    }
    
    public func enqueueOnMainThread(_ notification: Notification, postingStyle: NotificationQueue.PostingStyle, coalesceMask: NotificationQueue.NotificationCoalescing, forModes modes: [RunLoop.Mode]?) {
        if Thread.current.isMainThread {
            self.enqueue(notification,
                         postingStyle: postingStyle,
                         coalesceMask: coalesceMask,
                         forModes: modes)
        }
        
        DispatchQueue.main.sync {
            self.enqueue(notification,
                         postingStyle: postingStyle,
                         coalesceMask: coalesceMask,
                         forModes: modes)
        }
    }
}


#endif
