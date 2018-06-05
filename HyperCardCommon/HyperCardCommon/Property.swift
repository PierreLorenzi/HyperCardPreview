//
//  Property.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 20/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class Property<T> {
    
    private var lazyValue: LazyValue
    
    private var notifications: [Notification] = []
    
    private enum LazyValue {
        case stored(T)
        case lazy(() -> T)
    }
    
    private struct Notification {
        weak var object: AnyObject?
        var make: () -> ()
    }
    
    public init(_ value: T) {
        self.lazyValue = LazyValue.stored(value)
    }
    
    public var value: T {
        get {
            switch self.lazyValue {
            case .stored(let value):
                return value
            case .lazy(let compute):
                let value = compute()
                self.lazyValue = LazyValue.stored(value)
                return value
            }
        }
        set {
            self.lazyValue = LazyValue.stored(newValue)
            
            var areThereDeadObjects = false
            
            /* Send the notifications */
            for notification in notifications {
                
                guard notification.object != nil else {
                    areThereDeadObjects = true
                    continue
                }
                
                notification.make()
            }
            
            /* Forget the dead objects */
            if areThereDeadObjects {
                notifications = notifications.filter({ $0.object != nil })
            }
        }
    }
    
    public func lazyCompute(_ compute: @escaping () -> T) {
        self.lazyValue = LazyValue.lazy(compute)
    }
    
    public func startNotifications(for object: AnyObject, by make: @escaping () -> ()) {
        let notification = Notification(object: object, make: make)
        notifications.append(notification)
    }
    
    public func stopNotifications(for object: AnyObject) {
        notifications = notifications.filter({ $0.object !== object })
    }
    
}
