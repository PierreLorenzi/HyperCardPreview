//
//  Property.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 20/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class Property<T> {
    
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
        get {
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
    
    public func invalidate() {
        self.storedValue = nil
        
        /* Send the notifications */
        for notification in notifications {
            
            guard notification.object != nil else {
                continue
            }
            
            notification.make()
        }
        
        /* Forget the dead objects */
        notifications = notifications.filter({ $0.object != nil })
    }
    
    public func startNotifications(for object: AnyObject, by make: @escaping () -> ()) {
        let notification = Notification(object: object, make: make)
        notifications.append(notification)
    }
    
    public func stopNotifications(for object: AnyObject) {
        notifications = notifications.filter({ $0.object !== object })
    }
    
    public func dependsOn<T>(_ property: Property<T>) {
        property.startNotifications(for: self, by: { [unowned self] in self.invalidate() })
    }
    
}
