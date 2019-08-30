//
//  HyperCardObjectDescriptor.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public enum HyperCardObjectDescriptor {
    
    case me
    
    case hyperCard
    
    case stack(StackDescriptor)
    
    case background(BackgroundDescriptor)
    case card(CardDescriptor)
    
    case buttonOrField(ButtonOrFieldDescriptor)
}

public enum ButtonOrFieldDescriptor {
    case field(FieldDescriptor)
    case button(ButtonDescriptor)
    case part(PartDescriptor)
}

public typealias BackgroundDescriptor = LayerDescriptor<StackDescriptor>
public typealias BackgroundCardDescriptor = LayerDescriptor<BackgroundDescriptor>
public typealias StackCardDescriptor = LayerDescriptor<StackDescriptor>

public typealias CardFieldDescriptor = StandardObjectDescriptor<CardDescriptor>
public typealias BackgroundFieldDescriptor = StandardObjectDescriptor<BackgroundDescriptor>
public typealias CardButtonDescriptor = StandardObjectDescriptor<CardDescriptor>
public typealias BackgroundButtonDescriptor = StandardObjectDescriptor<BackgroundDescriptor>
public typealias CardPartDescriptor = StandardObjectDescriptor<CardDescriptor>
public typealias BackgroundPartDescriptor = StandardObjectDescriptor<BackgroundDescriptor>

public enum StackDescriptor {
    case current
    case withName(Expression)
}

public enum CardDescriptor {
    case inBackground(BackgroundCardDescriptor)
    case inStack(StackCardDescriptor)
}

public enum LayerDescriptor<ParentDescriptor> {
    case relative(RelativeOrdinal)
    case absolute(StandardObjectDescriptor<ParentDescriptor>)
}

public enum ButtonDescriptor {
    case inBackground(BackgroundButtonDescriptor)
    case inCard(CardButtonDescriptor)
}

public enum FieldDescriptor {
    case inBackground(BackgroundFieldDescriptor)
    case inCard(CardFieldDescriptor)
}

public enum PartDescriptor {
    case inBackground(BackgroundPartDescriptor)
    case inCard(CardPartDescriptor)
}

public enum StandardObjectDescriptor<ParentDescriptor> {
    case withOrdinal(Ordinal, parent: ParentDescriptor)
    case withIdentifier(Expression, parent: ParentDescriptor)
    case withName(Expression, parent: ParentDescriptor)
}
