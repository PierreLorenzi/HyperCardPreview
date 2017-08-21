//
//  Browser.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 03/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



private let trueHiliteContent: HString = "1"

private let iconButtonFontIdentifier = FontIdentifiers.geneva
private let iconButtonFontSize = 9
private let iconButtonFontStyle = PlainTextStyle


/// Browses through a stack: maintains a current card and current background and draws them.
public class Browser {
    
    /// The stack being browsed
    public let stack: Stack
    
    /// The index of the current card. Set it to browse.
    public var cardIndex: Int {
        get { return cardIndexProperty.value }
        set { cardIndexProperty.value = newValue }
    }
    public let cardIndexProperty: Property<Int>
    
    /// Activate this flag for the background view: only the background is drawn
    public var displayOnlyBackground: Bool {
        get { return displayOnlyBackgroundProperty.value }
        set { displayOnlyBackgroundProperty.value = newValue }
    }
    public let displayOnlyBackgroundProperty = Property<Bool>(false)
    
    private let drawing: Drawing
    
    private let resources: ResourceSystem
    private let fontManager: FontManager
    
    /// The image of the current card with its background
    public var image: Image {
        return drawing.image
    }
    
    /// The current card
    public var currentCard: Card {
        return self.stack.cards[cardIndex]
    }
    
    /// The current background
    public var currentBackground: Background {
        return self.currentCard.background
    }
    
    private var views: [View] = []
    
    public var needsDisplay: Bool {
        get { return needsDisplayProperty.value }
        set { needsDisplayProperty.value = newValue }
    }
    public let needsDisplayProperty = Property<Bool>(false)
    
    private var backgroundBefore: Background? = nil
    
    /// Builds a new browser from the given stack. A starting card index can be given.
    public init(stack: Stack, cardIndex: Int = 0) {
        self.stack = stack
        drawing = Drawing(width: stack.size.width, height: stack.size.height)
        
        var resources = ResourceSystem()
        if let stackResources = stack.resources {
            resources.repositories.append(stackResources)
        }
        resources.repositories.append(ResourceRepository.mainRepository)
        self.resources = resources
        
        self.fontManager = FontManager(resources: resources)
        
        self.cardIndexProperty = Property<Int>(cardIndex)
        
        self.cardIndexProperty.startNotifications(for: self, by: { [unowned self] in self.rebuildViews() })
        self.displayOnlyBackgroundProperty.startNotifications(for: self, by: { [unowned self] in self.rebuildViews() })
    }
    
    private func rebuildViews() {
        
        /* If we haven't changed background, keep the background parts */
        if currentBackground === backgroundBefore {
            
            /* There are one view per background part, plus one for the image */
            let backgroundViewCount = 1 + currentBackground.parts.count
            self.views.removeLast(views.count - backgroundViewCount)
        }
        else {
            
            /* Build the view hierarchy */
            self.views.removeAll()
            
            /* Append background views */
            appendLayerViews(self.currentBackground)
            
        }
        
        /* Update the background state */
        backgroundBefore = currentBackground
        
        /* Append card views */
        if !displayOnlyBackground {
            appendLayerViews(self.currentCard)
        }
        
        /* Listen to the views updates */
        let notification = { [unowned self] in self.needsDisplay = true }
        for view in views {
            view.needsDisplayProperty.startNotifications(for: self, by: notification)
        }
        
        /* We must refresh */
        self.needsDisplay = true
                
    }
    
    public func refresh() {
        
        /* Draw the views */
        drawing.clear()
        for view in views {
            view.draw(in: drawing)
        }
        
    }
    
    private func appendLayerViews(_ layer: Layer) {
        
        /* Image */
        let layerView = LayerView(layer: layer)
        self.views.append(layerView)
        
        /* Parts */
        for part in layer.parts {
            
            let partView = buildPartView(for: part)
            self.views.append(partView)
        }
        
    }
    
    private func buildPartView(for part: LayerPart) -> View {
        
        switch part {
        case .field(let field):
            return buildFieldView(for: field)
        case .button(let button):
            return buildButtonView(for: button)
        }
        
    }
    
    private func buildFieldView(for field: Field) -> View {
        
        /* Content */
        let content = retrieveContent(of: field)
        
        let view = FieldView(field: field, contentProperty: content, fontManager: self.fontManager)
        
        return view
        
    }
    
    private func retrieveContent(of field: Field) -> Property<PartContent> {
        
        /* Special case: bg buttons with not shared hilite */
        if !field.sharedText && isPartInBackground(field) {
            
            let property = Property<PartContent>(compute: {
                [unowned self, unowned field] in
            
                /* If we're displaying the background, do not display the card contents */
                if self.displayOnlyBackground {
                    return PartContent.string("")
                }
                
                /* Get the content of the button in the card */
                if let content = self.findContentInCurrentCard(of: field) {
                    return content
                }
                
                return PartContent.string("")
                
            })
            
            /* Dependencies */
            property.dependsOn(self.cardIndexProperty)
            property.dependsOn(self.displayOnlyBackgroundProperty)
            
            return property
            
        }
        
        /* Usual case: just return the content of the parent layer */
        return field.contentProperty
        
    }
    
    private func buildButtonView(for button: Button) -> View {
        
        let hiliteProperty = retrieveHilite(of: button)
        
        return ButtonView(button: button, hiliteProperty: hiliteProperty, fontManager: fontManager, resources: resources)
    }
    
    private func retrieveHilite(of button: Button) -> Property<Bool> {
        
        /* Special case: bg buttons with not shared hilite */
        if !button.sharedHilite && isPartInBackground(button) {
            
            let property = Property<Bool>(compute: {
                [unowned self, unowned button] in
            
                /* If we're displaying the background, do not display the card contents */
                if self.displayOnlyBackground {
                    return false
                }
                
                /* Get the content of the button in the card */
                guard let content = self.findContentInCurrentCard(of: button) else {
                    return false
                }
                
                /* If the card content is equal to "1", the button is hilited */
                guard case PartContent.string(trueHiliteContent) = content  else {
                    return false
                }
            
                return true
            })
            
            /* Dependencies */
            property.dependsOn(self.cardIndexProperty)
            property.dependsOn(self.displayOnlyBackgroundProperty)
            
            return property
        }
        
        /* Usual case: just return hilite */
        return button.hiliteProperty
        
    }
    
    private func isPartInBackground(_ part: Part) -> Bool {
        
        return self.currentBackground.parts.contains(where: {$0.part === part})
    }
    
    private func findContentInCurrentCard(of part: Part) -> PartContent? {
        
        let contents = self.currentCard.backgroundPartContents
        
        /* Find the content of the part */
        guard let content = contents.first(where: { $0.partIdentifier == part.identifier }) else {
            return nil
        }
        
        return content.partContent
    }
    
}
