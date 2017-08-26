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
        set { if (newValue != cardIndexProperty.value) { cardIndexProperty.value = newValue } }
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
    
    private var viewRecords: [ViewRecord] = []
    
    public var needsDisplay: Bool {
        get { return needsDisplayProperty.value }
        set { needsDisplayProperty.value = newValue }
    }
    public let needsDisplayProperty = Property<Bool>(false)
    
    private var backgroundBefore: Background? = nil
    
    private struct ViewRecord {
        
        /// the view
        public let view: View
        
        /// if the view is marked for refresh
        public var willRefresh: Bool
        
        /// if the views behind have been updateed when the view was marked for refresh
        public var didUpdateBehind: Bool
        
        /// if the view accepts to draw sub-rectangles, the rectangles to draw.
        public var rectanglesToRefresh: [Rectangle]?
    }
    
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
        
        self.fontManager = FontManager(resources: resources, fontNameReferences: stack.fontNameReferences)
        
        self.cardIndexProperty = Property<Int>(cardIndex)
        
        /* Add a background view */
        let windowBackgroundView = WhiteView()
        self.appendView(windowBackgroundView)
        
        /* Build the views for the current card */
        self.rebuildViews()
        
        self.cardIndexProperty.startNotifications(for: self, by: { [unowned self] in self.rebuildViews() })
        self.displayOnlyBackgroundProperty.startNotifications(for: self, by: { [unowned self] in self.rebuildViews() })
    }
    
    private func rebuildViews() {
        
        /* If we haven't changed background, keep the background parts */
        if currentBackground === backgroundBefore {
            
            /* There are one view per background part, plus one for the image, plus one for the window background */
            let backgroundViewCount = 2 + currentBackground.parts.count
            
            /* Check if the card is visible */
            let needsUpdate = viewRecords[backgroundViewCount ..< viewRecords.count].map({$0.view.visible}).reduce(false, { (b1: Bool, b2: Bool) -> Bool in
                return b1 || b2
            })
            
            /* Remove the card views */
            let cardViewCount = viewRecords.count - backgroundViewCount
            self.viewRecords.removeLast(cardViewCount)
            
            /* If the card was visible, refresh all the background views (don't loose time looping on all the card views) */
            if needsUpdate {
                for i in 0..<viewRecords.count {
                    if !viewRecords[i].willRefresh {
                        markViewForRefresh(atIndex: i, redrawBehind: true)
                    }
                }
            }
            
            /* Set the scrolls of the background fields to zero, to avoid having a field
             with a scroll higher than maximum */
            for field in currentBackground.fields {
                if field.style == .scrolling {
                    field.scroll = 0
                }
            }
        }
        else {
            
            /* Remove all the views except the window background */
            self.viewRecords.removeLast(self.viewRecords.count - 1)
            
            /* Append background views */
            appendLayerViews(self.currentBackground)
            
        }
        
        /* Update the state */
        backgroundBefore = currentBackground
        
        /* Append card views */
        if !displayOnlyBackground {
            appendLayerViews(self.currentCard)
        }
        
        /* We must refresh */
        self.needsDisplay = true
                
    }
    
    private func markViewForRefresh(atIndex index: Int, redrawBehind: Bool) {
        
        /* Mask the view for refresh */
        viewRecords[index].willRefresh = true
        viewRecords[index].didUpdateBehind = redrawBehind
        
        /* Get the rectangle to update in the other views */
        let dirtyRectangle = viewRecords[index].view.rectangle
        
        /* Refresh all the views in front */
        for i in (index+1) ..< viewRecords.count {
            self.markViewForRefreshIfOverlapsRect(atIndex: i, dirtyRectangle: dirtyRectangle)
        }
        
        /* Refresh the views behind if requested */
        if redrawBehind {
            for i in 0 ..< index {
                self.markViewForRefreshIfOverlapsRect(atIndex: i, dirtyRectangle: dirtyRectangle)
            }
        }
        
        self.needsDisplay = true
    }
    
    private func markViewForRefreshIfOverlapsRect(atIndex index: Int, dirtyRectangle: Rectangle) {
        
        /* Get the view */
        let view = viewRecords[index].view
        
        /* The view must intersects the dirty rect */
        guard view.rectangle.intersects(dirtyRectangle) else {
            return
        }
        
        /* Check if it not already marked for refresh */
        guard !viewRecords[index].willRefresh else {
            return
        }
        
        /* Only mark for refresh if it is visible */
        guard view.visible else {
            return
        }
        
        /* If the view can draw sub-rectangles, mark the rectangle for refresh. Do not check the other
         views because the rectangle is already dirty */
        if view.canDrawSubrectangle {
            
            let rectangleToRefresh = computeRectangleIntersection(dirtyRectangle, view.rectangle)
            var rectanglesToRefresh: [Rectangle] = viewRecords[index].rectanglesToRefresh ?? []
            rectanglesToRefresh.append(rectangleToRefresh)
            viewRecords[index].rectanglesToRefresh = rectanglesToRefresh
            return
        }
        
        /* Mask the view for refresh. Do not draw behind because it still has the same shape */
        self.markViewForRefresh(atIndex: index, redrawBehind: false)
        
    }
    
    public func refresh() {
        
        var index = -1
        
        /* Draw the views */
        for viewRecord in viewRecords {
            
            let view = viewRecord.view
            index += 1
            
            /* The view may be not for refresh but have rectangles to draw */
            if let rectanglesToRefresh = viewRecord.rectanglesToRefresh, !viewRecord.willRefresh {
                for rectangle in rectanglesToRefresh {
                    view.draw(in: drawing, rectangle: rectangle)
                }
                view.refreshNeed = .none
                viewRecords[index].rectanglesToRefresh = nil
                viewRecords[index].didUpdateBehind = false
                continue
            }
            
            /* Check if the view is programmed for refresh */
            guard viewRecord.willRefresh else {
                continue
            }
            
            /* Draw the view */
            view.draw(in: drawing)
            view.refreshNeed = .none
            viewRecords[index].willRefresh = false
            viewRecords[index].didUpdateBehind = false
            viewRecords[index].rectanglesToRefresh = nil
        }
        
    }
    
    private func appendLayerViews(_ layer: Layer) {
        
        /* Image */
        let layerView = LayerView(layer: layer)
        appendView(layerView)
        
        /* Parts */
        for part in layer.parts {
            
            let partView = buildPartView(for: part)
            appendView(partView)
        }
        
    }
    
    private func appendView(_ view: View) {
        
        /* Listen to the view refresh needs */
        view.refreshNeedProperty.startNotifications(for: self, by: { [unowned self, unowned view] in
            
            /* Do not listen to updates with no effect */
            guard view.refreshNeed != .none && view.visible else {
                return
            }
            
            /* Check if the view has changed shape, in that case the views behind must be refreshed */
            let hasChangedShape = (view.refreshNeed == .refreshWithNewShape)
            
            /* Find the record */
            let index = self.viewRecords.index(where: { $0.view === view })!
            let record = self.viewRecords[index]
            if (!hasChangedShape && record.willRefresh) || (hasChangedShape && record.didUpdateBehind) {
                return
            }
            
            /* Refresh */
            self.markViewForRefresh(atIndex: index, redrawBehind: hasChangedShape)
        })
        
        /* Build a view record. Do not mark it as refresh because we're just adding a view on top, just set willRefresh to true  */
        let viewRecord = ViewRecord(view: view, willRefresh: true, didUpdateBehind: false, rectanglesToRefresh: nil)
        self.viewRecords.append(viewRecord)
        self.needsDisplay = true
        
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
    
    public func respondToClick(at position: Point) {
        
        if let view = self.findViewRespondingToMouse(at: position) {
            
            view.respondToClick(at: position)
        }
    }
    
    public func respondToScroll(at position: Point, delta: Double) {
        
        if let view = self.findViewRespondingToMouse(at: position) {
            
            view.respondToScroll(at: position, delta: delta)
        }
    }
    
    private func findViewRespondingToMouse(at position: Point) -> View? {
        
        /* Ask to the views, from the foremost to the outmost */
        for viewRecord in viewRecords.reversed() {
            
            let view = viewRecord.view
            
            if view.respondsToMouseEvent(at: position) {
                return view
            }
        }
        
        return nil
    }
    
}
