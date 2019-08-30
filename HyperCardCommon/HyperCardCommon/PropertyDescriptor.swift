//
//  PropertyDescriptor.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public enum PropertyDescriptor {
    case intrinsic(IntrinsicProperty)
    case extrinsic(ExtrinsicProperty)
}

public enum IntrinsicProperty {
    case hyperCardProperty(PartialKeyPath<HyperCard>)
    case stackProperty(PartialKeyPath<Stack>, of: StackDescriptor)
    case backgroundProperty(PartialKeyPath<Background>, of: BackgroundDescriptor)
    case cardProperty(PartialKeyPath<Card>, of: CardDescriptor)
    case partProperty(PartialKeyPath<Part>, of: PartDescriptor)
    case fieldProperty(PartialKeyPath<Field>, of: FieldDescriptor)
    case buttonProperty(PartialKeyPath<Button>, of: ButtonDescriptor)
    case menuBarProperty(PartialKeyPath<MenuBar>)
    case menuProperty(PartialKeyPath<Menu>, of: MenuDescriptor)
    case menuItemProperty(PartialKeyPath<MenuItem>, of: MenuItemDescriptor)
    case windowProperty(PartialKeyPath<Window>, of: WindowDescriptor)
    case messageBoxProperty(PartialKeyPath<MessageBox>)
}

public enum ExtrinsicProperty {
    case number(NumberProperty)
    case partNumber(of: PartDescriptor)
    case chunk(ChunkProperty)
}

public enum NumberProperty {
    case numberOfButtonOrField(PartDescriptor)
    case numberOfCard(CardDescriptor)
    case numberOfBackground(BackgroundDescriptor)
    case numberOfWindow(WindowDescriptor)
}

public enum ChunkProperty {
    case textFont(of: ChunkContainer)
    case textSize(of: ChunkContainer)
    case textStyle(of: ChunkContainer)
}
