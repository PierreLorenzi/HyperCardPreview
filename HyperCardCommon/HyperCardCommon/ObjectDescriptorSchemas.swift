//
//  ObjectDescriptorSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let object = Schema<ObjectDescriptor>("\(window)\(or: menu)\(or: menuItem)\(or: file)\(or: disk)\(or: document)\(or: application)\(or: folder)\(or: picture)\(or: program)\(or: scriptingLanguage)\(or: hyperCardObjectDescriptor)")
    
        .when(window) { ObjectDescriptor.window($0) }
        
        .when(menu) { ObjectDescriptor.menu($0) }
        
        .when(menuItem) { ObjectDescriptor.menuItem($0) }
        
        .when(file) { ObjectDescriptor.file($0) }
        
        .when(disk) { ObjectDescriptor.disk($0) }
        
        .when(document) { ObjectDescriptor.document($0) }
        
        .when(application) { ObjectDescriptor.application($0) }
        
        .when(folder) { ObjectDescriptor.folder($0) }
        
        .when(picture) { ObjectDescriptor.picture($0) }
        
        .when(program) { ObjectDescriptor.program($0) }
        
        .when(scriptingLanguage) { ObjectDescriptor.scriptingLanguage($0) }
        
        .when(hyperCardObjectDescriptor) { ObjectDescriptor.hyperCardObject($0) }
    
    
    
    static let menu: Schema<MenuDescriptor> = buildHyperCardObjectIdentification(typeName: Vocabulary.menu) {
        
        return $0
    }
    
    static let file = Schema<FileDescriptor>("file \(expressionAgain)")
    
        .returnsSingle { return FileDescriptor(name: $0) }
    
    static let disk = Schema<DiskDescriptor>("disk \(expressionAgain)")
        
        .returnsSingle { return DiskDescriptor(name: $0) }
    
    static let document = Schema<DocumentDescriptor>("document \(expressionAgain)")
        
        .returnsSingle { return DocumentDescriptor(name: $0) }
    
    static let application = Schema<ApplicationDescriptor>("application \(expressionAgain)")
        
        .returnsSingle { return ApplicationDescriptor(name: $0) }
    
    static let folder = Schema<FolderDescriptor>("folder \(expressionAgain)")
        
        .returnsSingle { return FolderDescriptor(name: $0) }
    
    static let scriptingLanguage = Schema<ScriptingLanguageDescriptor>("scriptingLanguage \(expressionAgain)")
        
        .returnsSingle { return ScriptingLanguageDescriptor(name: $0) }
}

public extension Schemas {
    
    
    static let window = Schema<WindowDescriptor>("\(cardWindow)\(or: windowIdentification)")
    
    
    
    static let cardWindow = Schema<WindowDescriptor>("\(Vocabulary.card) \(Vocabulary.window)")
    
        .returns(WindowDescriptor.currentCardWindow)
    
    static let windowIdentification = buildHyperCardObjectIdentification(typeName: Vocabulary.window) {
        
        return WindowDescriptor.identification($0)
    }
    
}

public extension Schemas {
    
    
    static let menuItem = Schema<MenuItemDescriptor>("\(menuItemIdentification) \(of) \(menu)")
    
        .returns { MenuItemDescriptor(identification: $0, parentMenu: $1) }
    
    
    static let menuItemIdentification = buildHyperCardObjectIdentification(typeName: Vocabulary.menu) {
        
        return $0
    }
    
}

public extension Schemas {
    
    
    static let picture = Schema<PictureDescriptor>("\(cardPicture)\(or: backgroundPicture)")
    
    
    
    static let cardPicture = Schema<PictureDescriptor>("\(Vocabulary.card) picture")
        
        .returns(PictureDescriptor(layer: LayerType.card))
    
    static let backgroundPicture = Schema<PictureDescriptor>("\(Vocabulary.background) picture")
        
        .returns(PictureDescriptor(layer: LayerType.background))
    
}

public extension Schemas {
    
    
    static let program = Schema<ProgramDescriptor>("\(cardWindow)\(or: windowIdentification)")
    
    
    
    static let currentProgram = Schema<ProgramDescriptor>("this \(Vocabulary.program)")
        
        .returns(ProgramDescriptor.currentProgram)
    
    static let programWithIdentification = buildHyperCardObjectIdentification(typeName: Vocabulary.program) {
        
        return ProgramDescriptor.identification($0)
    }
    
}

fileprivate extension Schemas {
    
    static let of = Schema<Void>("\(either: "of", "in")")
        .returns(())
}

public extension Schemas {
    

    static func buildHyperCardObjectIdentification<T>(typeName: Schema<Void>, returns compute: @escaping (HyperCardObjectIdentification) -> T) -> Schema<T> {
        
        let ordinalIdentification = buildOrdinalIdentification(typeName: typeName) {
            
            return HyperCardObjectIdentification.withOrdinal($0)
        }
        
        let nameSchema = Schema<HyperCardObjectIdentification>("\(typeName) \(expressionAgain)")
        
            .returnsSingle { HyperCardObjectIdentification.withName($0) }
        
        let identifierSchema = Schema<HyperCardObjectIdentification>("\(typeName) id \(factorAgain)")
        
            .returnsSingle { HyperCardObjectIdentification.withIdentifier($0) }
        
        let schema = Schema<T>("\(identifierSchema)\(or: ordinalIdentification)\(or: nameSchema)")
        
            .when(ordinalIdentification) { compute($0) }
            .when(nameSchema) { compute($0) }
            .when(identifierSchema) { compute($0) }
        
        return schema
    }
    
    static func buildOrdinalIdentification<T>(typeName: Schema<Void>, returns compute: @escaping (Ordinal) -> T) -> Schema<T> {
        
        let numberSchema = Schema<Ordinal>("\(typeName) \(expressionAgain)")
        
            .returnsSingle { Ordinal.number($0) }
        
        let ordinalSchema = Schema<Ordinal>("\(maybe: "the") \(ordinal) \(typeName)")
        
        let schema = Schema<T>("\(numberSchema)\(or: ordinalSchema)")
        
            .when(numberSchema, compute)
            .when(ordinalSchema, compute)
    
        return schema
    }
}

public extension Schemas {
    
    
    static let ordinal = Schema<Ordinal>("\(any)\(or: middle)\(or: last)\(or: first)\(or: second)\(or: third)\(or: fourth)\(or: fifth)\(or: sixth)\(or: seventh)\(or: eighth)\(or: ninth)\(or: tenth)")
    
    
    
    static let any = Schema<Ordinal>("any")
        
        .returns(Ordinal.any)
    
    static let middle = Schema<Ordinal>("middle")
        
        .returns(Ordinal.middle)
    
    static let last = Schema<Ordinal>("last")
        
        .returns(Ordinal.last)
    
    static let first = Schema<Ordinal>("first")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(1))))
    
    static let second = Schema<Ordinal>("second")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(2))))
    
    static let third = Schema<Ordinal>("third")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(3))))
    
    static let fourth = Schema<Ordinal>("fourth")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(4))))
    
    static let fifth = Schema<Ordinal>("fifth")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(5))))
    
    static let sixth = Schema<Ordinal>("sixth")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(6))))
    
    static let seventh = Schema<Ordinal>("seventh")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(7))))
    
    static let eighth = Schema<Ordinal>("eighth")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(8))))
    
    static let ninth = Schema<Ordinal>("ninth")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(9))))
    
    static let tenth = Schema<Ordinal>("tenth")
        
        .returns(Ordinal.number(Expression.literal(Literal.integer(10))))
}
