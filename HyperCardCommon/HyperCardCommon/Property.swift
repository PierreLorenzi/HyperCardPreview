//
//  Property.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 19/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//

public class Property<T> {
    public var storedValue: T
    
    public var observers: [PropertyObserver] = []
    
    public init(_ value: T) {
        self.storedValue = value
    }
    
    public var value: T {
        get {
            let sessionObservers: [SessionObserver] = observers.flatMap { (c: PropertyObserver) -> SessionObserver? in
                return c.generateGetObserver()
            }
            for observer in sessionObservers {
                observer.willStart()
            }
            let value = self.storedValue
            for observer in sessionObservers {
                observer.didFinish()
            }
            return value
        }
        set {
            let sessionObservers: [SessionObserver] = observers.flatMap { (c: PropertyObserver) -> SessionObserver? in
                return c.generateSetObserver()
            }
            for observer in sessionObservers {
                observer.willStart()
            }
            self.storedValue = newValue
            for observer in sessionObservers {
                observer.didFinish()
            }
        }
    }
}

public class PropertyObserver {
    
    func generateGetObserver() -> SessionObserver? {
        return nil
    }
    
    func generateSetObserver() -> SessionObserver? {
        return nil
    }
    
}

public struct SessionObserver {
    
    let willStart: () -> ()
    
    let didFinish: () -> ()
    
}
