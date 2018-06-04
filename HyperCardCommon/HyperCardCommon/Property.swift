//
//  Property.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 20/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public struct Property<T> {
    
    private var storedValue: T? = nil
    
    private var _compute: () -> T
    
    private var notifications: [Notification] = []
    
    public var isLazy = false
    
    private struct Notification {
        weak var object: AnyObject?
        var make: () -> ()
    }
    
    public init(_ value: T) {
        _compute = { return value }
    }
    
    public init(compute: @escaping () -> T) {
        _compute = compute
    }
    
    public var value: T {
        mutating get {
            guard let someStoredValue = storedValue else {
                let newValue = compute()
                
                /* If the property is lazy, discard the closure to free the captured objects,
                 that are only necessary for the computation */
                if isLazy {
                    _compute = { return newValue }
                }
                
                self.storedValue = newValue
                return newValue
            }
            return someStoredValue
        }
        set {
            self.compute = { return newValue }
        }
    }
    
    public var compute: () -> T {
        get {
            return _compute
        }
        set {
            _compute = newValue
            self.invalidate()
        }
    }
    
    public var lazyCompute: () -> T {
        get {
            return _compute
        }
        set {
            _compute = newValue
            isLazy = true
        }
    }
    
    public mutating func invalidate() {
        self.storedValue = nil
        
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
    
    public mutating func startNotifications(for object: AnyObject, by make: @escaping () -> ()) {
        let notification = Notification(object: object, make: make)
        notifications.append(notification)
    }
    
    public mutating func stopNotifications(for object: AnyObject) {
        notifications = notifications.filter({ $0.object !== object })
    }
    
}
