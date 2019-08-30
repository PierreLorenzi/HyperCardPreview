//
//  HyperCardObjectDescriptor.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public enum HyperCardObjectDescriptor: Equatable {
    
    case me
    
    case hyperCard
    
    case stack(StackDescriptor)
    
    case background(BackgroundDescriptor)
    case card(CardDescriptor)
    
    case part(PartDescriptor)
}

public enum StackDescriptor: Equatable {
    
    case current
    case withName(Expression)
}

public enum LayerDescriptor: Equatable {
    
    case relative(RelativeOrdinal)
    case absolute(HyperCardObjectIdentification)
}

public typealias BackgroundDescriptor = LayerDescriptor

public struct CardDescriptor: Equatable {
    
    var descriptor: LayerDescriptor
    var parentBackground: LayerDescriptor?
}

public enum HyperCardObjectIdentification: Equatable {
    
    case withOrdinal(Ordinal)
    case withIdentifier(Expression)
    case withName(Expression)
}

public struct PartDescriptor: Equatable {
    
    var type: PartDescriptorType
    var typedPartDescriptor: TypedPartDescriptor
}

public typealias ButtonDescriptor = TypedPartDescriptor
public typealias FieldDescriptor = TypedPartDescriptor

public struct TypedPartDescriptor: Equatable {
    
    var layer: LayerType
    var identification: HyperCardObjectIdentification
    var card: CardDescriptor
}

public enum PartDescriptorType: Equatable {
    case field
    case button
    case part
}

