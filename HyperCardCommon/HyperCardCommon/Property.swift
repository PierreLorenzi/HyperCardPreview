//
//  Property.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 20/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class Property<T> {
    
    private var storedValue: T? = nil
    
    public var observers: [PropertyObserver] = []
    
    public init(_ value: T) {
        self.compute = { return value }
    }
    
    public init(compute: @escaping () -> T) {
        self.compute = compute
    }
    
    public var value: T {
        get {
            guard let someStoredValue = storedValue else {
                let newValue = compute()
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
        didSet {
            self.invalidate()
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
