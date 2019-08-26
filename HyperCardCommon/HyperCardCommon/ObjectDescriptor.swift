//
//  ObjectDescriptor.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public enum ObjectDescriptor {
    case window(WindowDescriptor)
    case menu(MenuDescriptor)
    case menuItem(MenuItemDescriptor)
    case file(FileDescriptor)
    case disk(DiskDescriptor)
    case document(DocumentDescriptor)
    case application(ApplicationDescriptor)
    case folder(FolderDescriptor)
    case picture(PictureDescriptor)
    case program(ProgramDescriptor)
    case scriptingLanguage(ScriptingLanguageDescriptor)
    case hyperCardObject(HyperCardObjectDescriptor)
}

public typealias MenuDescriptor = StandardObjectDescriptor<Void>
public typealias MenuItemDescriptor = StandardObjectDescriptor<MenuDescriptor>
public typealias FileDescriptor = NamedDescriptor
public typealias DiskDescriptor = NamedDescriptor
public typealias DocumentDescriptor = NamedDescriptor
public typealias ApplicationDescriptor = NamedDescriptor
public typealias FolderDescriptor = NamedDescriptor
public typealias ScriptingLanguageDescriptor = NamedDescriptor

public struct NamedDescriptor {
    public var name: Expression
}

public enum ProgramDescriptor {
    case thisProgram
    case programWithPath(Expression)
    case programWithSignature(Expression)
}

public enum WindowDescriptor {
    case currentCardWindow
    case absolute(StandardObjectDescriptor<Void>)
}

public enum PictureDescriptor {
    case cardPicture(CardDescriptor)
    case backgroundPicture(BackgroundDescriptor)
}
