//
//  FunctionCall.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public enum FunctionCall {
    
    case custom(identifier: HString, arguments: [Expression])
    
    case abs(Expression)
    case annuity(number1: Expression, number2: Expression)
    case atan(Expression)
    case average(numberList: Expression)
    case charToNum(Expression)
    case clickChunk
    case clickH
    case clickV
    case clickLine
    case clickLoc
    case clickText
    case commandKey
    case compound(number1: Expression, number2: Expression)
    case cos(Expression)
    case date(exactness: Exactness?)
    case destination
    case diskSpace(diskName: Expression?)
    case exp(Expression)
    case exp1(Expression)
    case exp2(Expression)
    case foundChunk
    case foundField
    case foundLine
    case foundText
    case heapSpace
    case length(Expression)
    case ln(Expression)
    case log1(Expression)
    case log2(Expression)
    case max(numberList: Expression)
    case menus
    case min(numberList: Expression)
    case mouse
    case mouseClick
    case mouseH
    case mouseV
    case mouseLoc
    case number(Countable)
    case numToChar(Expression)
    case offset(text1: Expression, text2: Expression)
    case optionKey
    case param(Expression)
    case paramCount
    case params
    case programs(machineName: Expression?)
    case random(Expression)
    case result
    case round(Expression)
    case screenRect
    case seconds
    case selectedButton(ofFamilyWithNumber: Expression, inLayerWithType: LayerType)
    case selectedChunk
    case selectedField
    case selectedLine(SelectedLineFunction)
    case selectedLoc
    case selectedText
    case shiftKey
    case sin(Expression)
    case sound
    case sqrt(Expression)
    case stacks
    case stackSpace
    case sum(numberList: Expression)
    case systemVersion
    case tan(Expression)
    case target(exactness: Exactness?)
    case ticks
    case time(exactness: Exactness?)
    case tool
    case trunc(Expression)
    case value(Expression)
    case windows
}


public enum Countable {
    
    case buttons(LayerType)
    case fields(LayerType)
    case parts(LayerType)
    
    case cardsInStack(StackDescriptor)
    case cardsInBackground(BackgroundDescriptor)
    case markedCards
    case backgrounds(StackDescriptor)
    
    case windows
    case menus
    case menuItems(inMenu: MenuDescriptor)
    
    case chunks(ChunkType, `in`: Expression)
}

public enum SelectedLineFunction {
    case selectedLine
    case selectedLineInListField(FieldDescriptor)
    case selectedLineInPopUpButton(ButtonDescriptor)
}

