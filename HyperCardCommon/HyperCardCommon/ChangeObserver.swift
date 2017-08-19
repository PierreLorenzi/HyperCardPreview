//
//  ChangeObserver.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 19/08/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


public class ChangeObserver: PropertyObserver {
    
    private let sessionCallback: SessionObserver
    
    public init(callback: @escaping () -> ()) {
        self.sessionCallback = SessionObserver(willStart: {}, didFinish: {
            callback()
        })
    }
    
    override func generateSetObserver() -> SessionObserver? {
        return self.sessionCallback
    }
    
}
