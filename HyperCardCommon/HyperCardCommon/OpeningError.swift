//
//  OpeningError.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// Errors raised when loading a stack from a file
public enum OpeningError: Error {
    
    /// The file is not a HyperCard stack
    case notStack
    
    /// The file data is corrupted
    case corrupted
    
    /// You must provide a password
    case missingPassword
    
    /// Your password was wrong.
    case wrongPassword
}
