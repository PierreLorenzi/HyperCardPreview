//
//  Browser.swift
//  HyperCard
//
//  Created by Pierre Lorenzi on 03/03/2017.
//  Copyright © 2017 Pierre Lorenzi. All rights reserved.
//



private let trueHiliteContent: HString = "1"


/// Browses through a stack: maintains a current card and current background and draws them.
public class Browser: MouseResponder {
    
    /// The stack being browsed
    public let hyperCardFile: HyperCardFile
    public var stack: Stack {
        return self.hyperCardFile.stack
    }
    
    /// The index of the current card. Set it to browse.
    public var cardIndex: Int {
        get { return cardIndexProperty.value }
        set { if (newValue != cardIndexProperty.value) { cardIndexProperty.value = newValue } }
    }
    public var cardIndexProperty: Property<Int>
    
    /// Activate this flag for the background view: only the background is drawn
    public var displayOnlyBackground: Bool {
        get { return displayOnlyBackgroundProperty.value }
        set { displayOnlyBackgroundProperty.value = newValue }
    }
    public var displayOnlyBackgroundProperty = Property<Bool>(false)
    
    private let drawing: Drawing
    private let imageBuffer: ImageBuffer
    
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
    
    private var refreshNeeds: [RefreshNeed] = []
    
    private struct RefreshNeed {
        var rectangle: Rectangle
        var viewIndex: Int
        var view: View
    }
    
    public var needsDisplay: Bool {
        get { return needsDisplayProperty.value }
        set { needsDisplayProperty.value = newValue }
    }
    public var needsDisplayProperty = Property<Bool>(false)
    
    /// the background before changing card
    private var backgroundBefore: Background? = nil
    
    /// the view used to draw a white background on the window
    private var whiteView: WhiteView
    
    private let areThereColors: Bool
    
    private weak var _selectedField: FieldView? = nil
    
    public var cursorRectanglesProperty = Property<[Rectangle]>([])
    private var doCursorRectanglesChange = false
    
    /// Builds a new browser from the given stack. A starting card index can be given.
    public init(hyperCardFile: HyperCardFile, cardIndex: Int = 0, imageBuffer: ImageBuffer) {
        self.hyperCardFile = hyperCardFile
        let stack = hyperCardFile.stack
        drawing = Drawing(width: stack.size.width, height: stack.size.height)
        
        self.imageBuffer = imageBuffer
        imageBuffer.context.scaleBy(x: CGFloat(imageBuffer.width)/CGFloat(stack.size.width), y: CGFloat(imageBuffer.height)/CGFloat(stack.size.height))
        imageBuffer.context.translateBy(x: 0, y: CGFloat(stack.size.height))
        imageBuffer.context.scaleBy(x: 1, y: -1)
        imageBuffer.context.setBlendMode(CGBlendMode.darken)
        
        var resources = ResourceSystem()
        if let stackResources = hyperCardFile.resources {
            resources.repositories.append(stackResources)
        }
        resources.repositories.append(contentsOf: ResourceRepository.mainRepositories)
        self.resources = resources
        
        self.fontManager = FontManager(resources: resources, fontNameReferences: stack.fontNameReferences)
        
        self.cardIndexProperty = Property<Int>(cardIndex)
        
        self.areThereColors = Browser.areThereColors(inFile: hyperCardFile)
        
        self.whiteView = WhiteView(cardRectangle: Rectangle(x: 0, y: 0, width: stack.size.width, height: stack.size.height))
        
        /* Add a background view */
        self.appendView(self.whiteView)
        
        /* Build the views for the current card */
        self.rebuildViews()
        
        self.cardIndexProperty.startNotifications(for: self, by: { [unowned self] in self.rebuildViews() })
        self.displayOnlyBackgroundProperty.startNotifications(for: self, by: { [unowned self] in self.rebuildViews() })
    }
    
    private static func areThereColors(inFile hyperCardFile: HyperCardFile) -> Bool {
        
        guard let repository = hyperCardFile.resources else {
            return false
        }
        
        return repository.resources.first(where: { $0.typeIdentifier == ResourceTypes.cardColor || $0.typeIdentifier == ResourceTypes.backgroundColor }) != nil
    }
    
    private func rebuildViews() {
        
        self.doCursorRectanglesChange = false
        
        /* If there are colors, we must refresh all because there may be updated colors also that we don't track */
        if areThereColors {
            self.addRefreshNeed(in: Rectangle(x: 0, y: 0, width: stack.size.width, height: stack.size.height), at: 0)
        }
        
        /* If we haven't changed background, keep the background parts */
        if currentBackground === backgroundBefore {
            
            /* Remove all the views except the background views, there are one view per part,
             plus one for the image, plus one for the white view */
            let backgroundViewCount = 1 + currentBackground.parts.count + 1
            removeLastViews(count: self.views.count - backgroundViewCount)
        }
        else {
            
            /* Remove all the views except the white view */
            self.removeLastViews(count: self.views.count - 1)
            
            /* Append background views */
            appendLayerViews(self.currentBackground)
            
        }
        
        /* Update the state */
        backgroundBefore = currentBackground
        
        /* Append card views */
        if !displayOnlyBackground {
            appendLayerViews(self.currentCard)
        }
        
        if self.doCursorRectanglesChange {
            self.cursorRectanglesProperty.value = self.listCursorRectangles()
        }
                
    }
    
    private func listCursorRectangles() -> [Rectangle] {
        
        var rectangles: [Rectangle] = []
        
        /* Function to loop on the cursor rectangles and break them so they
         surround the argument rectangle */
        func excludeRectangle(_ rectangle: Rectangle) {
            
            var i = rectangles.count - 1
            while i >= 0 {
                if let subRectangles = self.buildComplementSubRectangles(of: rectangles[i], around: rectangle) {
                    rectangles.replaceSubrange(i..<(i+1), with: subRectangles)
                }
                i -= 1
            }
        }
        
        for view in self.views {
            
            /* If the view is a field, include it in the cursor rectangles */
            if view is FieldView, let rectangle = view.rectangle {
                rectangles.append(rectangle)
            }
            
            /* If the view is a scrolling field, exclure the scroll from the cursor rectangles */
            if let fieldView = view as? FieldView, fieldView.field.style == .scrolling, let wholeRectangle = view.rectangle {
                let scrollRectangle = Rectangle(top: wholeRectangle.top, left: wholeRectangle.right - scrollWidth, bottom: wholeRectangle.bottom, right: wholeRectangle.right)
                excludeRectangle(scrollRectangle)
            }
            
            /* If the view is a button, exclude it from the cursor rectangles */
            if view is ButtonView, let rectangle = view.rectangle {
                excludeRectangle(rectangle)
            }
        }
        
        return rectangles
    }
    
    private func buildComplementSubRectangles(of baseRectangle: Rectangle, around rectangle: Rectangle) -> [Rectangle]? {
        
        guard baseRectangle.intersects(rectangle) else {
            return nil
        }
        
        /* Build the four sub-rectangles around the rectangle */
        var subRectangles: [Rectangle] = []
        
        /* Top */
        let topSubRectangle = Rectangle(top: baseRectangle.top, left: baseRectangle.left, bottom: rectangle.top, right: baseRectangle.right)
        if topSubRectangle.width > 0 && topSubRectangle.height > 0 {
            subRectangles.append(topSubRectangle)
        }
        
        /* Bottom */
        let bottomSubRectangle = Rectangle(top: rectangle.bottom, left: baseRectangle.left, bottom: baseRectangle.bottom, right: baseRectangle.right)
        if bottomSubRectangle.width > 0 && bottomSubRectangle.height > 0 {
            subRectangles.append(bottomSubRectangle)
        }
        
        let sideRectangleTop = max(rectangle.top, baseRectangle.top)
        let sideRetangleBottom = min(rectangle.bottom, baseRectangle.bottom)
        
        /* Left */
        let leftSubRectangle = Rectangle(top: sideRectangleTop, left: baseRectangle.left, bottom: sideRetangleBottom, right: rectangle.left)
        if leftSubRectangle.width > 0 && leftSubRectangle.height > 0 {
            subRectangles.append(leftSubRectangle)
        }
        
        /* Right */
        let rightSubRectangle = Rectangle(top: sideRectangleTop, left: rectangle.right, bottom: sideRetangleBottom, right: baseRectangle.right)
        if rightSubRectangle.width > 0 && rightSubRectangle.height > 0 {
            subRectangles.append(rightSubRectangle)
        }
        
        return subRectangles
    }
    
    private func doesBackgroundHaveWhiteMask(_ background: Background) -> Bool {
        
        /* This function is a bad optimization, we should implement a opaque properties in views */
        
        /* Check if the background is visible */
        guard background.showPict else {
            return false
        }
        
        /* Check if the background have a rectangular white mask spanning on all the window */
        if let image = currentBackground.image {
            if case MaskedImage.Layer.rectangular(rectangle: let rectangle) = image.mask {
                if rectangle.right == self.image.width && rectangle.bottom == self.image.height {
                    return true
                }
            }
        }
        
        return false
    }
    
    private func removeLastViews(count: Int) {
        
        /* Check if the views to remove are visible */
        let remainingViewCount = views.count - count
        
        for _ in remainingViewCount ..< views.count {
            
            let view = views.last!
            self.removeView(view)
        }
        
    }
    
    private func removeView(_ view: View) {
        
        self.addRefreshNeed(under: view)
        
        let index = self.views.firstIndex(where: { $0 === view })!
        self.views.remove(at: index)
        
        self.doCursorRectanglesChange = true
    }
    
    private func addRefreshNeed(under view: View) {
        
        guard let rectangle = view.rectangle else {
            return
        }
        
        self.addRefreshNeed(in: rectangle, at: 0)
    }
    
    private func addRefreshNeed(above view: View) {
        
        guard let rectangle = view.rectangle else {
            return
        }
        
        /* If we're changing card, the view may have disappeared */
        guard let viewIndex = self.views.firstIndex(where: { $0 === view }) else {
            return
        }
        
        self.addRefreshNeed(in: rectangle, at: viewIndex)
    }
    
    private func addRefreshNeed(in unclippedRectangle: Rectangle, at viewIndex: Int) {
        
        guard let rectangle = computeRectangleIntersection(unclippedRectangle, Rectangle(x: 0, y: 0, width: self.image.width, height: self.image.height)) else {
            return
        }
        
        /* Remove the refresh needs that are not valid anymore */
        self.removeInvalidRefreshNeeds()
        
        /* Check it doesn't enclose or isn't enclosed by another one */
        for i in 0..<self.refreshNeeds.count {
            
            let refreshNeed = self.refreshNeeds[i]
            
            if rectangle.containsRectangle(refreshNeed.rectangle) {
                
                self.refreshNeeds[i].rectangle = rectangle
                if viewIndex < refreshNeed.viewIndex {
                    self.refreshNeeds[i].viewIndex = viewIndex
                    self.refreshNeeds[i].view = self.views[viewIndex]
                }
                return
            }
            
            if refreshNeed.rectangle.containsRectangle(rectangle) {
                
                if viewIndex < refreshNeed.viewIndex {
                    self.refreshNeeds[i].viewIndex = viewIndex
                    self.refreshNeeds[i].view = self.views[viewIndex]
                }
                return
            }
        }
        
        let newRefreshNeed = RefreshNeed(rectangle: rectangle, viewIndex: viewIndex, view: self.views[viewIndex])
        self.refreshNeeds.append(newRefreshNeed)
        self.needsDisplay = true
    }
    
    private func removeInvalidRefreshNeeds() {
        
        self.refreshNeeds.removeAll(where: { $0.viewIndex >= self.views.count || $0.view !== self.views[$0.viewIndex] })
    }
    
    public func refresh() {
        
        /* Remove the refresh needs that are not valid anymore */
        self.removeInvalidRefreshNeeds()
        
        /* If there are colors, it is a separate process */
        guard !self.areThereColors else {
            
            self.refreshWithColors()
            return
        }
        
        /* Refresh the drawing */
        let refreshNeeds = self.refreshNeeds
        self.refreshDrawing()
        
        /* Update the image buffer */
        for refreshNeed in refreshNeeds {
            self.imageBuffer.drawImage(self.image, onlyRectangle: refreshNeed.rectangle)
        }
        
    }
    
    private func refreshWithColors() {
        
        for refreshNeed in self.refreshNeeds {
            
            let rectangle = refreshNeed.rectangle
        
            let cgRect = CGRect(x: rectangle.x, y: rectangle.y, width: rectangle.width, height: rectangle.height)
            
            /* Update all the views in the rectangle */
            drawing.clipRectangle = rectangle
            for view in self.views {
                
                guard let viewRectangle = view.rectangle,
                    viewRectangle.intersects(refreshNeed.rectangle) else {
                        continue
                }
                
                view.draw(in: drawing)
            }
            
            self.imageBuffer.drawImage(self.image, onlyRectangle: rectangle)
            
            /* Draw the colors */
            imageBuffer.context.clip(to: cgRect)
            AddColorPainter.paintAddColor(ofFile: hyperCardFile, atCardIndex: cardIndex, excludeCardParts: self.displayOnlyBackground, onContext: imageBuffer.context)
        }
        
        self.refreshNeeds.removeAll()
    }
    
    private func refreshDrawing() {
        
        for refreshNeed in self.refreshNeeds {
            
            self.drawing.clipRectangle = refreshNeed.rectangle
            
            for i in refreshNeed.viewIndex ..< self.views.count {
                
                let view = self.views[i]
                guard let rectangle = view.rectangle,
                    rectangle.intersects(refreshNeed.rectangle) else {
                    continue
                }
                
                view.draw(in: drawing)
            }
        }
        
        self.refreshNeeds.removeAll()
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
            guard view.refreshNeed != .none && view.rectangle != nil else {
                return
            }
            
            /* Check if the view has changed shape, in that case the views behind must be refreshed */
            let hasChangedShape = (view.refreshNeed == .refreshWithNewShape)
            
            if hasChangedShape || view.usesXorComposition {
                self.addRefreshNeed(under: view)
            }
            else {
                self.addRefreshNeed(above: view)
            }
        })
        
        self.views.append(view)
        self.addRefreshNeed(above: view)
        
        self.doCursorRectanglesChange = true
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
        let contentComputation = retrieveContent(of: field)
        
        let view = FieldView(field: field, contentComputation: contentComputation, fontManager: self.fontManager)
        
        /* Manage the selection */
        view.selectedRangeProperty.startNotifications(for: self) { [unowned self, unowned view] in
            self.respondToViewSelection(view)
        }
        
        return view
        
    }
    
    private func retrieveContent(of field: Field) -> Computation<PartContent> {
        
        /* Special case: bg buttons with not shared hilite */
        if !field.sharedText && isPartInBackground(field) {
            
            let computation = Computation<PartContent> {
                [unowned self, unowned field] () -> PartContent in
            
                /* If we're displaying the background, do not display the card contents */
                if self.displayOnlyBackground {
                    return PartContent.string("")
                }
                
                /* Get the content of the button in the card */
                if let content = self.findContentInCurrentCard(of: field) {
                    return content
                }
                
                return PartContent.string("")
                
            }
            
            /* Dependencies */
            computation.dependsOn(self.cardIndexProperty)
            computation.dependsOn(self.displayOnlyBackgroundProperty)
            
            return computation
            
        }
        
        /* Usual case: just return the content of the parent layer */
        let computation = Computation<PartContent> {
            [unowned field] () -> PartContent in
            return field.content
        }
        computation.dependsOn(field.contentProperty)
        
        return computation
    }
    
    private func respondToViewSelection(_ view: FieldView) {
        
        guard self.selectedField !== view else {
            return
        }
        guard view.selectedRange != nil else {
            return
        }
        
        /* If there was a selected field (and still valid), deselect it */
        if let field = self.selectedField {
            field.selectedRange = nil
        }
        
        self.selectedField = view
    }
    
    public var selectedField: FieldView? {
        
        get {
            guard let field = self._selectedField else {
                return nil
            }
            
            /* If the field doesn't exist anymore because we have changed card,
             forget it */
            guard views.contains(where: { $0 === field }) else {
                self._selectedField = nil
                return nil
            }
            
            return self._selectedField
        }
        
        set {
            self._selectedField = newValue
        }
    }
    
    private func buildButtonView(for button: Button) -> View {
        
        /* Handle families */
        let familyCallback = {
            [unowned self] (view: ButtonView) in
            self.buttonViewDidSetHilite(view)
        }
        
        let hiliteComputation = retrieveHilite(of: button)
        return ButtonView(button: button, hiliteComputation: hiliteComputation, fontManager: fontManager, resources: resources, familyCallback: familyCallback)
    }
    
    private func retrieveHilite(of button: Button) -> Computation<Bool> {
        
        /* Special case: bg buttons with not shared hilite */
        if !button.sharedHilite && isPartInBackground(button) {
            
            let computation = self.buildBackgroundHiliteComputation(for: button)
            return computation
        }
        
        /* Usual case: just return hilite */
        let computation = self.buildHiliteComputation(for: button)
        return computation
    }
    
    private func buildHiliteComputation(for button: Button) -> Computation<Bool> {
        
        let compute = {
            [unowned button] () -> Bool in
            return button.hilite
        }
        let modify = {
            [unowned button] (hilite: Bool) in
            button.hilite = hilite
        }
        let computation = Computation<Bool>(compute: compute, modify: modify)
        computation.dependsOn(button.hiliteProperty)
        return computation
    }
    
    private func buildBackgroundHiliteComputation(for button: Button) -> Computation<Bool> {
        
        let compute = {
            [unowned self, unowned button] () -> Bool in
            
            /* If we're displaying the background, do not display the card contents */
            if self.displayOnlyBackground {
                return false
            }
            
            /* Get the content of the button in the card */
            guard let content = self.findContentInCurrentCard(of: button) else {
                return false
            }
            
            /* If the card content is equal to "1", the button is hilited */
            guard case PartContent.string(let textContent) = content, textContent == trueHiliteContent  else {
                return false
            }
            
            return true
        }
        let modify = {
            [unowned self, unowned button] (hilite: Bool) -> () in
            
            /* Remove the current content */
            self.currentCard.backgroundPartContents.removeAll(where: { $0.partIdentifier == button.identifier })
            
            /* If hilite, add the content to tell it */
            if hilite {
                let newContent = Card.BackgroundPartContent(partIdentifier: button.identifier, partContent: PartContent.string(trueHiliteContent))
                self.currentCard.backgroundPartContents.append(newContent)
            }
        }
        let computation = Computation<Bool>(compute: compute, modify: modify)
        computation.dependsOn(self.cardIndexProperty)
        computation.dependsOn(self.displayOnlyBackgroundProperty)
        return computation
    }
    
    private func buttonViewDidSetHilite(_ buttonView: ButtonView) {
        
        guard self.views.contains(where: { $0 === buttonView }) else {
            return
        }
        guard buttonView.button.family > 0 else {
            return
        }
        
        let backgroundViewCount = 1 + currentBackground.parts.count + 1
        let range: Range<Int> = self.isPartInBackground(buttonView.button) ? 0..<backgroundViewCount : backgroundViewCount..<self.views.count
        
        for i in range {
            let otherView = self.views[i]
            guard otherView !== buttonView else {
                continue
            }
            guard let otherButtonView = otherView as? ButtonView else {
                continue
            }
            guard otherButtonView.button.family == buttonView.button.family else {
                continue
            }
            otherButtonView.hilite = false
        }
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
    
    public func findViewRespondingToMouseEvent(at position: Point) -> MouseResponder {
        
        /* Ask to the views, from the foremost to the outmost */
        for view in views.reversed() {
            
            /* Check if the view responds to the mouse */
            guard let responder = view as? MouseResponder else {
                continue
            }
            
            /* Check if the view responds to that mouse event */
            guard responder.doesRespondToMouseEvent(at: position) else {
                continue
            }
            
            return responder
        }
        
        return self
    }
    
    public func doesRespondToMouseEvent(at position: Point) -> Bool {
        return true
    }
    
    public func respondToMouseEvent(_ mouseEvent: MouseEvent, at position: Point) {
        
        guard case MouseEvent.mouseUp = mouseEvent else {
            return
        }
        
        if let field = self.selectedField {
            field.selectedRange = nil
        }
    }
    
    public func hasSelection() -> Bool {
        return self.selectedField != nil
    }
    
    public func getSelection() -> HString? {
        guard let field = self.selectedField else {
            return nil
        }
        return field.getSelection()
    }
    
    public func selectAll() {
        guard let field = self.selectedField else {
            return
        }
        field.selectAll()
    }
    
    public func getFieldView(of field: Field) -> FieldView {
        
        for view in self.views {
            
            if let fieldView = view as? FieldView, fieldView.field === field {
                return fieldView
            }
        }
        
        fatalError()
    }
    
}
