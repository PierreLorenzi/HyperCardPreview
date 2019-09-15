//
//  ComputedState.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 04/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Stores a value computed with other values, so that computed properties
/// can be included in a network of properties and listeners.
public class Computation<T> {
    
    private let compute: () -> T
    
    private let modify: (T) -> ()
    
    private var valueIsRead: Bool
    
    public var value: T {
        get { return valueProperty.value }
        set {
            self.modify(newValue)
            self.valueProperty.value = newValue
        }
    }
    public var valueProperty: Property<T>
    
    public init(compute: @escaping () -> T, modify: @escaping (T) -> ()) {
        self.compute = compute
        self.modify = modify
        self.valueIsRead = false
        self.valueProperty = Property<T>(lazy: compute)
        
        /* The previous initialization was fake because we need self capture */
        self.valueProperty.lazyCompute { () -> T in
            self.valueIsRead = true
            return compute()
        }
    }
    
    public convenience init(_ compute: @escaping () -> T) {
        self.init(compute: compute) { (newValue: T) in
        }
    }
    
    public func recompute() {
        
        /* If the value has still not been read, keep on waiting for lazy initialization */
        guard self.valueIsRead else {
            return
        }
        
        self.valueProperty.value = compute()
    }
    
    public func dependsOn<PropertyType>(_ property: Property<PropertyType>) {
        property.startNotifications(for: self, by: { [unowned self] in self.recompute() })
    }
    
}
