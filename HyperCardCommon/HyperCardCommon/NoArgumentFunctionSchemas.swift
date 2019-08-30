//
//  NoArgumentFunctionSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let noArgumentFunctionCall = Schema<FunctionCall>("the \(noArgumentFunction)")
}

public extension Schemas {
    
    
    static let noArgumentFunction = Schema<FunctionCall>("\(clickChunk)\(or: clickH)\(or: clickV)\(or: clickLine)\(or: clickLoc)\(or: clickText)\(or: commandKey)\(or: date)\(or: destination)\(or: diskSpace)\(or: foundChunk)\(or: foundField)\(or: foundLine)\(or: foundText)\(or: heapSpace)\(or: menus)\(or: mouse)\(or: mouseClick)\(or: mouseH)\(or: mouseV)\(or: mouseLoc)\(or: optionKey)\(or: paramCount)\(or: params)\(or: programs)\(or: result)\(or: screenRect)\(or: seconds)\(or: selectedChunk)\(or: selectedField)\(or: selectedLine)\(or: selectedLoc)\(or: selectedText)\(or: shiftKey)\(or: sound)\(or: stacks)\(or: systemVersion)\(or: target)\(or: ticks)\(or: time)\(or: tool)\(or: windows)")
    
    
    
    static let clickChunk = Schema<FunctionCall>("clickChunk")
    
        .returns(FunctionCall.clickChunk)
    
    static let clickH = Schema<FunctionCall>("clickH")
        
        .returns(FunctionCall.clickH)
    
    static let clickV = Schema<FunctionCall>("clickV")
        
        .returns(FunctionCall.clickV)
    
    static let clickLine = Schema<FunctionCall>("clickLine")
        
        .returns(FunctionCall.clickLine)
    
    static let clickLoc = Schema<FunctionCall>("clickLoc")
        
        .returns(FunctionCall.clickLoc)
    
    static let clickText = Schema<FunctionCall>("clickText")
        
        .returns(FunctionCall.clickText)
    
    static let commandKey = Schema<FunctionCall>("commandKey")
        
        .returns(FunctionCall.commandKey)
    
    static let date = Schema<FunctionCall>("\(maybe: exactness) date")
        
        .returnsSingle { FunctionCall.date(exactness: $0) }
    
    static let destination = Schema<FunctionCall>("destination")
        
        .returns(FunctionCall.destination)
    
    static let diskSpace = Schema<FunctionCall>("diskSpace")
        
        .returns(FunctionCall.diskSpace(diskName: nil))
    
    static let foundChunk = Schema<FunctionCall>("foundChunk")
        
        .returns(FunctionCall.foundChunk)
    
    static let foundField = Schema<FunctionCall>("foundField")
        
        .returns(FunctionCall.foundField)
    
    static let foundLine = Schema<FunctionCall>("foundLine")
        
        .returns(FunctionCall.foundLine)
    
    static let foundText = Schema<FunctionCall>("foundText")
        
        .returns(FunctionCall.foundText)
    
    static let heapSpace = Schema<FunctionCall>("heapSpace")
        
        .returns(FunctionCall.heapSpace)
    
    static let menus = Schema<FunctionCall>("menus")
        
        .returns(FunctionCall.menus)
    
    static let mouse = Schema<FunctionCall>("mouse")
        
        .returns(FunctionCall.mouse)
    
    static let mouseClick = Schema<FunctionCall>("mouseClick")
        
        .returns(FunctionCall.mouseClick)
    
    static let mouseH = Schema<FunctionCall>("mouseH")
        
        .returns(FunctionCall.mouseH)
    
    static let mouseV = Schema<FunctionCall>("mouseV")
        
        .returns(FunctionCall.mouseV)
    
    static let mouseLoc = Schema<FunctionCall>("mouseLoc")
        
        .returns(FunctionCall.mouseLoc)
    
    static let optionKey = Schema<FunctionCall>("optionKey")
        
        .returns(FunctionCall.optionKey)
    
    static let paramCount = Schema<FunctionCall>("paramCount")
        
        .returns(FunctionCall.paramCount)
    
    static let params = Schema<FunctionCall>("params")
        
        .returns(FunctionCall.params)
    
    static let programs = Schema<FunctionCall>("programs")
        
        .returns(FunctionCall.programs(machineName: nil))
    
    static let result = Schema<FunctionCall>("result")
        
        .returns(FunctionCall.result)
    
    static let screenRect = Schema<FunctionCall>("screenRect")
        
        .returns(FunctionCall.screenRect)
    
    static let seconds = Schema<FunctionCall>("seconds")
        
        .returns(FunctionCall.seconds)
    
    static let selectedChunk = Schema<FunctionCall>("selectedChunk")
        
        .returns(FunctionCall.selectedChunk)
    
    static let selectedField = Schema<FunctionCall>("selectedField")
        
        .returns(FunctionCall.selectedField)
    
    static let selectedLine = Schema<FunctionCall>("selectedLine")
        
        .returns(FunctionCall.selectedLine(SelectedLineFunction.selectedLine))
    
    static let selectedLoc = Schema<FunctionCall>("selectedLoc")
        
        .returns(FunctionCall.selectedLoc)
    
    static let selectedText = Schema<FunctionCall>("selectedText")
        
        .returns(FunctionCall.selectedText)
    
    static let shiftKey = Schema<FunctionCall>("shiftKey")
        
        .returns(FunctionCall.shiftKey)
    
    static let sound = Schema<FunctionCall>("sound")
        
        .returns(FunctionCall.sound)
    
    static let stacks = Schema<FunctionCall>("stacks")
        
        .returns(FunctionCall.stacks)
    
    static let systemVersion = Schema<FunctionCall>("systemVersion")
        
        .returns(FunctionCall.systemVersion)
    
    static let target = Schema<FunctionCall>("\(maybe: exactness) target")
        
        .returnsSingle{ FunctionCall.target(exactness: $0) }
    
    static let ticks = Schema<FunctionCall>("ticks")
        
        .returns(FunctionCall.ticks)
    
    static let time = Schema<FunctionCall>("\(maybe: exactness) time")
        
        .returnsSingle{ FunctionCall.time(exactness: $0) }
    
    static let tool = Schema<FunctionCall>("tool")
        
        .returns(FunctionCall.tool)
    
    static let windows = Schema<FunctionCall>("windows")
        
        .returns(FunctionCall.windows)
}

public extension Schemas {
    
    
    static let exactness = Schema<Exactness>("\(longExactness)\(or: shortExactness)\(or: abbreviatedExactness)\(or: englishExactness)")
    
    
    
    static let longExactness = Schema<Exactness>("long")
    
        .returns(Exactness.long)
    
    static let shortExactness = Schema<Exactness>("short")
        
        .returns(Exactness.short)
    
    static let abbreviatedExactness = Schema<Exactness>("\(either: "abbreviated", "abbrev", "abbr")")
        
        .returns(Exactness.abbreviated)
    
    static let englishExactness = Schema<Exactness>("english")
        
        .returns(Exactness.english)
}
