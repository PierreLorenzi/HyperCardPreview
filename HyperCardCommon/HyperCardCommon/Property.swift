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
    
    public var observers: [PropertyObserver] = []
    
    public var isLazy = false
    
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
        
        for observer in observers {
            observer.valueDidChange()
        }
    }
    
}

public protocol PropertyObserver {
    
    func valueDidChange()
    
}
