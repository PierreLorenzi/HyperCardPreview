//
//  OpeningError.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 06/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public enum OpeningError: Error {
    case notStack
    case corrupted
    case missingPassword
    case wrongPassword
}
