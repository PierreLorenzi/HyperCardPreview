//
//  HyperCard Objects.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public struct MenuBar {
    var rectangle: Rectangle
}

public struct Window {
    var rectangle: Rectangle
    var identifier: Int
    var name: String
    var owner: String
    var scroll: Point
    var visible: Bool
    var zoomed: Bool
}

public struct MenuItem {
    var checkMark: Bool
    var commandChar: HChar
    var enabled: Bool
    var markChar: HChar
    var menuMessage: String
    var name: String
    var englishName: String
    var textStyle: TextStyle
    var visible: Bool
}

public struct Menu {
    var enabled: Bool
    var identifier: Int
    var name: String
    var englishName: String
}

public struct MessageBox {
    var textFontIdentifier: Int
    var textFontSize: Int
    var textStyle: TextStyle
}



