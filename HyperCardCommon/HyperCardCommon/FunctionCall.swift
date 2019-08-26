//
//  FunctionCall.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public enum FunctionCall {
    
    case custom(identifier: Identifier, arguments: [Expression])
    
    case abs(number: Expression)
    case annuity(number1: Expression, number2: Expression)
    case atan(number: Expression)
    case average(numberList: Expression)
    case charToNum(character: Expression)
    case clickChunk
    case clickH
    case clickV
    case clickLine
    case clickLoc
    case clickText
    case commandKey
    case compound(number1: Expression, number2: Expression)
    case cos(number: Expression)
    case date(exactness: Exactness)
    case destination
    case diskSpace(diskName: Expression?)
    case exp(number: Expression)
    case exp1(number: Expression)
    case exp2(number: Expression)
    case foundChunk
    case foundField
    case foundLine
    case foundText
    case heapSpace
    case length(Expression)
    case ln(number: Expression)
    case log1(number: Expression)
    case log2(number: Expression)
    case max(numberList: Expression)
    case menus
    case min(numberList: Expression)
    case mouse
    case mouseClick
    case mouseH
    case mouseV
    case mouseLoc
    case number(NumberFunction)
    case numToChar(number: Expression)
    case offset(text1: Expression, text2: Expression)
    case optionKey
    case param(number: Expression)
    case paramCount
    case params
    case programs(machineName: Expression?)
    case random(number: Expression)
    case result
    case round(number: Expression)
    case screenRect
    case seconds
    case selectedButton(ofFamilyWithNumber: Expression, inLayerWithType: LayerType)
    case selectedChunk
    case selectedField
    case selectedLine(SelectedLineFunction)
    case selectedLoc
    case selectedText
    case shiftKey
    case sin(number: Expression)
    case sound
    case sqrt(number: Expression)
    case stacks
    case stackSpace
    case sum(numberList: Expression)
    case systemVersion
    case tan(number: Expression)
    case target(exactness: Exactness?)
    case ticks
    case time(exactness: Exactness?)
    case tool
    case trunc(number: Expression)
    case value(of: Expression)
    case windows
}

public enum NumberFunction {
    
    case numberOfButtons(inLayerWithType: LayerType)
    case numberOfFields(inLayerWithType: LayerType)
    case numberOfParts(inLayerWithType: LayerType)
    
    case numberOfMarkedCards
    case numberOfCards
    case numberOfCardsInBackground(BackgroundDescriptor)
    case numberOfBackgrounds
    
    case numberOfWindows
    case numberOfMenus
    case numberOfMenuItems(inMenu: MenuDescriptor)
    
    case numberOfChunks(ChunkType, `in`: Expression)
}

public enum SelectedLineFunction {
    case selectedLine
    case selectedLineInListField(FieldDescriptor)
    case selectedLineInPopUpButton(ButtonDescriptor)
}

