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
    case menuBarProperty(PartialKeyPath<MenuBar>, of: ButtonDescriptor)
    case menuProperty(PartialKeyPath<Menu>, of: ButtonDescriptor)
    case menuItemProperty(PartialKeyPath<MenuItem>, of: ButtonDescriptor)
    case windowProperty(PartialKeyPath<Window>, of: ButtonDescriptor)
    case messageBoxProperty(PartialKeyPath<MessageBox>, of: ButtonDescriptor)
}

public enum ExtrinsicProperty {
    case number(NumberProperty)
    case partNumber(of: ButtonOrFieldDescriptor)
    case chunk(ChunkProperty)
}

public enum NumberProperty {
    case numberOfButtonOrField(ButtonOrFieldDescriptor)
    case numberOfCard(CardDescriptor)
    case numberOfBackground(BackgroundDescriptor)
    case numberOfWindow(WindowDescriptor)
}

public enum ChunkProperty {
    case textFont(of: Chunk<FieldDescriptor>)
    case textSize(of: Chunk<FieldDescriptor>)
    case textStyle(of: Chunk<FieldDescriptor>)
}
