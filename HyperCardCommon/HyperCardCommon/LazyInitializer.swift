//
//  LazyInitializer.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 19/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class LazyInitializer<T>: PropertyObserver {
    
    unowned private let property: Property<T>
    
    private let initialization: () -> T
    
    public init(property: Property<T>, initialization: @escaping () -> T) {
        self.property = property
        self.initialization = initialization
    }
    
    override func generateGetObserver() -> SessionObserver? {
        return SessionObserver(willStart: {
            
            /* Init the value */
            self.property.storedValue = self.initialization()
            
            /* Remove myself from the observers */
            self.removeFromObservers()
            
        }, didFinish: {})
    }
    
    override func generateSetObserver() -> SessionObserver? {
        return SessionObserver(willStart: {
            
            /* Remove myself from the observers */
            self.removeFromObservers()
            
        }, didFinish: {})
    }
    
    private func removeFromObservers() {
        
        let index = self.property.observers.index(where: {$0 === self})!
        self.property.observers.remove(at: index)
    }
    
}
