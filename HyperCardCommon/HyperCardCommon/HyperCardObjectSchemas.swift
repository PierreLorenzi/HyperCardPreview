//
//  HyperCardObjectSchemas.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 30/08/2019.
//  Copyright © 2019 Pierre Lorenzi. All rights reserved.
//


public extension Schemas {
    
    
    static let hyperCardObjectDescriptor = Schema<HyperCardObjectDescriptor>("\(me)\(or: hyperCard)\(or: stack)\(or: background)\(or: card)\(or: part)")
    
    
    
    static let me = Schema<HyperCardObjectDescriptor>("me")
    
        .returns(HyperCardObjectDescriptor.me)
    
    static let hyperCard = Schema<HyperCardObjectDescriptor>("hyperCard")
        
        .returns(HyperCardObjectDescriptor.hyperCard)
    
    static let background = buildLayerDescriptor(typeName: Vocabulary.background)
}

public extension Schemas {
    
    
    static let stack = Schema<StackDescriptor>("\(currentStack)\(or: stackWithName)")
    
    
    
    static let currentStack = Schema<StackDescriptor>("this \(Vocabulary.stack)")
        
        .returns(StackDescriptor.current)
    
    static let stackWithName = Schema<StackDescriptor>("\(Vocabulary.stack) \(expressionAgain)")
        
        .returnsSingle { StackDescriptor.withName($0) }
    
}

public extension Schemas {
    
    
    static let card = Schema<CardDescriptor>("\(cardWithLayerIdentification) \(maybe: parentBackground)")
    
        .returns { CardDescriptor(descriptor: $0, parentBackground: $1) }
    
    
    
    static let cardWithLayerIdentification = buildLayerDescriptor(typeName: Vocabulary.card)
    
    static let parentBackground = Schema<BackgroundDescriptor>("\(Vocabulary.of) \(background)")
}

public extension Schemas {
    
    
    static let part = Schema<PartDescriptor>("\(layerPart) \(maybe: parentCard)")
    
        .returns { (layerPart: (PartDescriptorType, LayerType, HyperCardObjectIdentification), parentCard: CardDescriptor?) in
            
            return PartDescriptor(type: layerPart.0, typedPartDescriptor: TypedPartDescriptor(layer: layerPart.1, identification: layerPart.2, card: parentCard ?? CardDescriptor(descriptor: LayerDescriptor.relative(RelativeOrdinal.current), parentBackground: nil)))
    }
    
    
    
    static let layerPart = Schema<(PartDescriptorType, LayerType, HyperCardObjectIdentification)>("\(cardPart)\(or: backgroundPart)\(or: cardButton)\(or: backgroundButton)\(or: cardField)\(or: backgroundField)")
    
    static let parentCard = Schema<CardDescriptor>("\(Vocabulary.of) \(card)")
    
    static let cardPart: Schema<(PartDescriptorType, LayerType, HyperCardObjectIdentification)> = buildHyperCardObjectIdentification(typeName: Vocabulary.cardPart) {
        
        return (PartDescriptorType.part, LayerType.card, $0)
    }
    
    static let backgroundPart: Schema<(PartDescriptorType, LayerType, HyperCardObjectIdentification)> = buildHyperCardObjectIdentification(typeName: Vocabulary.backgroundPart) {
        
        return (PartDescriptorType.part, LayerType.background, $0)
    }
    
    static let cardButton: Schema<(PartDescriptorType, LayerType, HyperCardObjectIdentification)> = buildHyperCardObjectIdentification(typeName: Vocabulary.cardButton) {
        
        return (PartDescriptorType.button, LayerType.card, $0)
    }
    
    static let backgroundButton: Schema<(PartDescriptorType, LayerType, HyperCardObjectIdentification)> = buildHyperCardObjectIdentification(typeName: Vocabulary.backgroundButton) {
        
        return (PartDescriptorType.button, LayerType.background, $0)
    }
    
    static let cardField: Schema<(PartDescriptorType, LayerType, HyperCardObjectIdentification)> = buildHyperCardObjectIdentification(typeName: Vocabulary.cardField) {
        
        return (PartDescriptorType.field, LayerType.card, $0)
    }
    
    static let backgroundField: Schema<(PartDescriptorType, LayerType, HyperCardObjectIdentification)> = buildHyperCardObjectIdentification(typeName: Vocabulary.backgroundField) {
        
        return (PartDescriptorType.field, LayerType.background, $0)
    }
}

private extension Schemas {
    
    static func buildLayerDescriptor(typeName: Schema<Void>) -> Schema<LayerDescriptor> {
        
        let relativeLayer = buildRelativeOrdinalSchema(typeName: Vocabulary.background) {
            
            return BackgroundDescriptor.relative($0)
        }
        
        let layerWithIdentification = buildHyperCardObjectIdentification(typeName: Vocabulary.background) {
            
            return BackgroundDescriptor.absolute($0)
        }
        
        let layer = Schema<LayerDescriptor>("\(relativeLayer)\(or: layerWithIdentification)")
        
        return layer
    }
    
    private static func buildRelativeOrdinalSchema<T>(typeName: Schema<Void>, returns compute: @escaping (RelativeOrdinal) -> T) -> Schema<T> {
        
        let schema = Schema<T>("\(maybe: "the") \(relativeOrdinal) \(typeName)")
        
            .returnsSingle { compute($0) }
        
        return schema
    }
}

public extension Schemas {
    
    
    static let relativeOrdinal = Schema<RelativeOrdinal>("\(current)\(or: next)\(or: previous)")
    
    
    
    static let current = Schema<RelativeOrdinal>("this")
    
        .returns(RelativeOrdinal.current)
    
    static let next = Schema<RelativeOrdinal>("next")
        
        .returns(RelativeOrdinal.next)
    
    static let previous = Schema<RelativeOrdinal>("\(either: "previous", "prev")")
        
        .returns(RelativeOrdinal.previous)
    
}
