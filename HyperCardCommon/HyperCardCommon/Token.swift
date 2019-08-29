//
//  Token.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 14/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public enum Token: Equatable {
    case word(HString)
    case quotedString(HString)
    case symbol(HString)
    case integer(Int)
    case realNumber(Double)
    case lineSeparation
}

