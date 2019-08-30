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
    
    case buttonOrField(PartDescriptor)
}

public enum StackDescriptor {
    
    case current
    case withName(Expression)
}

public enum LayerDescriptor {
    
    case relative(RelativeOrdinal)
    case absolute(HyperCardObjectIdentification)
}

public typealias BackgroundDescriptor = LayerDescriptor

public struct CardDescriptor {
    
    var descriptor: LayerDescriptor
    var parentBackground: LayerDescriptor?
}

public enum HyperCardObjectIdentification {
    
    case withOrdinal(Ordinal)
    case withIdentifier(Expression)
    case withName(Expression)
}

public struct PartDescriptor {
    
    var type: PartDescriptorType
    var typedPartDescriptor: TypedPartDescriptor
}

public typealias ButtonDescriptor = TypedPartDescriptor
public typealias FieldDescriptor = TypedPartDescriptor

public struct TypedPartDescriptor {
    
    var layer: LayerType
    var identification: HyperCardObjectIdentification
    var card: CardDescriptor
}

public enum PartDescriptorType {
    case field
    case button
    case part
}

