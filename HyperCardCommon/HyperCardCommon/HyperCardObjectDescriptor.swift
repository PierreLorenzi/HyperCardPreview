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
    
    public var descriptor: LayerDescriptor
    public var parentBackground: LayerDescriptor?
    
    public init(descriptor: LayerDescriptor, parentBackground: LayerDescriptor?) {
        self.descriptor = descriptor
        self.parentBackground = parentBackground
    }
}

public enum HyperCardObjectIdentification: Equatable {
    
    case withOrdinal(Ordinal)
    case withIdentifier(Expression)
    case withName(Expression)
}

public struct PartDescriptor: Equatable {
    
    public var type: PartDescriptorType
    public var typedPartDescriptor: TypedPartDescriptor
    
    public init(type: PartDescriptorType, typedPartDescriptor: TypedPartDescriptor) {
        self.type = type
        self.typedPartDescriptor = typedPartDescriptor
    }
}

public typealias ButtonDescriptor = TypedPartDescriptor
public typealias FieldDescriptor = TypedPartDescriptor

public struct TypedPartDescriptor: Equatable {
    
    public var layer: LayerType
    public var identification: HyperCardObjectIdentification
    public var card: CardDescriptor
    
    public init(layer: LayerType, identification: HyperCardObjectIdentification, card: CardDescriptor) {
        self.layer = layer
        self.identification = identification
        self.card = card
    }
}

public enum PartDescriptorType: Equatable {
    case field
    case button
    case part
}

