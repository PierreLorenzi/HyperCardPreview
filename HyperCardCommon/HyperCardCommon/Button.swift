//
//  Button.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 26/02/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//


/// A button, as a HyperCard object
public class Button: Part {
    
    /// The content
    public var content: HString {
        get { return self.contentProperty.value }
        set { self.contentProperty.value = newValue }
    }
    public var contentProperty = Property<HString>("")
    
    /// Whether the specified button appears and behaves in an enabled or disabled
    /// state.
    public var enabled: Bool {
        get { return self.enabledProperty.value }
        set { self.enabledProperty.value = newValue }
    }
    public var enabledProperty = Property<Bool>(true)
    
    /// Whether the specified button is highlighted (displayed in inverse video).
    public var hilite: Bool {
        get { return self.hiliteProperty.value }
        set { self.hiliteProperty.value = newValue }
    }
    public var hiliteProperty = Property<Bool>(false)
    
    /// Whether the specified button highlights when that button is pressed.
    public var autoHilite: Bool {
        get { return self.autoHiliteProperty.value }
        set { self.autoHiliteProperty.value = newValue }
    }
    public var autoHiliteProperty = Property<Bool>(false)
    
    /// Whether the specified background button is displayed highlighted on all cards
    /// of that background.
    public var sharedHilite: Bool {
        get { return self.sharedHiliteProperty.value }
        set { self.sharedHiliteProperty.value = newValue }
    }
    public var sharedHiliteProperty = Property<Bool>(false)
    
    /// Whether the name of the specified button (if it has one) is displayed in its
    /// rectangle on the screen.
    public var showName: Bool {
        get { return self.showNameProperty.value }
        set { self.showNameProperty.value = newValue }
    }
    public var showNameProperty = Property<Bool>(true)
    
    /// The resource identifier of the icon displayed in the button
    public var iconIdentifier: Int {
        get { return self.iconIdentifierProperty.value }
        set { self.iconIdentifierProperty.value = newValue }
    }
    public var iconIdentifierProperty = Property<Int>(0)
    
    /// Groups two or more buttons together into a family specified by the numbers 1 to
    /// 15, inclusive.
    public var family: Int {
        get { return self.familyProperty.value }
        set { self.familyProperty.value = newValue }
    }
    public var familyProperty = Property<Int>(0)
    
    /// For pop-up buttons: the width of the area in which the button’s name appears.
    public var titleWidth: Int {
        get { return self.titleWidthProperty.value }
        set { self.titleWidthProperty.value = newValue }
    }
    public var titleWidthProperty = Property<Int>(0)
    
    /// For pop-up buttons: the index of the selected item.
    public var selectedItem: Int {
        get { return self.selectedItemProperty.value }
        set { self.selectedItemProperty.value = newValue }
    }
    public var selectedItemProperty = Property<Int>(0)
    
}

