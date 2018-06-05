//
//  ComputedState.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 04/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public class Computation<T> {
    
    private let compute: () -> T
    
    public var value: T {
        get { return valueProperty.value }
        set { valueProperty.value = newValue }
    }
    public var valueProperty: Property<T>
    
    public init(_ compute: @escaping () -> T) {
        self.compute = compute
        self.valueProperty = Property<T>(compute())
    }
    
    public func recompute() {
        self.valueProperty.value = compute()
    }
    
    public func dependsOn<PropertyType>(_ property: Property<PropertyType>) {
        property.startNotifications(for: self, by: { [unowned self] in self.recompute() })
    }
    
}
