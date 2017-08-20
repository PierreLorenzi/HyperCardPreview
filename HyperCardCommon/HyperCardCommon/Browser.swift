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
        didSet {
            refresh()
        }
    }
    
    /// Activate this flag for the background view: only the background is drawn
    public var displayOnlyBackground = false {
        didSet {
            refresh()
        }
    }
    
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
    
    private let stackView: StackView
    
    /// Builds a new browser from the given stack. A starting card index can be given.
    public init(stack: Stack, cardIndex: Int = 0) {
        self.stack = stack
        drawing = Drawing(width: stack.size.width, height: stack.size.height)
        self.stackView = StackView()
        
        var resources = ResourceSystem()
        if let stackResources = stack.resources {
            resources.repositories.append(stackResources)
        }
        resources.repositories.append(ResourceRepository.mainRepository)
        self.resources = resources
        
        self.fontManager = FontManager(resources: resources)
        
        self.cardIndex = cardIndex
    }
    
    private func refresh() {
        
        /* Build the view hierarchy */
        displayLayer(self.currentBackground, on: stackView.backgroundView)
        displayLayer(self.currentCard, on: stackView.cardView)
        
        drawing.clear()
        
        /* Special case: background view */
        if displayOnlyBackground {
            stackView.backgroundView.draw(in: drawing)
            return
        }
        
        /* Draw the stack */
        stackView.draw(in: drawing)
                
    }
    
    private func displayLayer(_ layer: Layer, on view: LayerView) {
        
        /* Image */
        view.image = layer.image
        view.showImage = layer.showPict
        
        /* Parts */
        view.partViews = layer.parts.map(buildPartView)
        
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
            
            return Property<PartContent>(compute: {
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
        }
        
        /* Usual case: just return the content of the parent layer */
        return field.contentProperty
        
    }
    
    private func buildButtonView(for button: Button) -> View {
        
        switch button.style {
            
        case .transparent, .opaque, .rectangle, .shadow, .roundRect, .standard, .`default`, .oval:
            return buildRegularButtonView(for: button)
            
        case .checkBox, .radio:
            return buildCheckBoxButtonView(for: button)
            
        case .popup:
            return buildPopupButtonView(for: button)
            
        default:
            return View()
        }
    }
    
    private func buildRegularButtonView(for button: Button) -> RegularButtonView {
        
        let view = RegularButtonView()
        
        view.name = button.name
        view.rectangle = button.rectangle
        view.icon = button.iconIdentifier == 0 ? nil : findIcon(withIdentifier: button.iconIdentifier)
        view.style = button.style
        view.hilite = retrieveHilite(of: button)
        view.visible = button.visible
        view.enabled = button.enabled
        view.showName = button.showName
        view.alignment = button.textAlign
        
        /* Font */
        let fontIdentifier = (button.iconIdentifier != 0) ? iconButtonFontIdentifier : button.textFontIdentifier
        let fontSize = (button.iconIdentifier != 0) ? iconButtonFontSize : button.textFontSize
        let fontStyle = (button.iconIdentifier != 0) ? iconButtonFontStyle : button.textStyle
        view.font = fontManager.findFont(withIdentifier: fontIdentifier, size: fontSize, style: fontStyle)
        
        return view
    }
    
    private func retrieveHilite(of button: Button) -> Bool {
        
        /* Special case: bg buttons with not shared hilite */
        if !button.sharedHilite && isPartInBackground(button) {
            
            /* If we're displaying the background, do not display the card contents */
            if displayOnlyBackground {
                return false
            }
            
            /* Get the content of the button in the card */
            guard let content = findContentInCurrentCard(of: button) else {
                return false
            }
            
            /* If the card content is equal to "1", the button is hilited */
            guard case PartContent.string(trueHiliteContent) = content  else {
                return false
            }
            
            return true
        }
        
        /* Usual case: just return hilite */
        return button.hilite
        
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
    
    private func buildCheckBoxButtonView(for button: Button) -> CheckBoxButtonView {
        
        let view = CheckBoxButtonView()
        
        view.name = button.name
        view.rectangle = button.rectangle
        view.style = button.style
        view.font = fontManager.findFont(withIdentifier: button.textFontIdentifier, size: button.textFontSize, style: button.textStyle)
        view.hilite = retrieveHilite(of: button)
        view.visible = button.visible
        view.enabled = button.enabled
        view.showName = button.showName
        
        return view
    }
    
    private func buildPopupButtonView(for button: Button) -> PopupButtonView {
        
        let view = PopupButtonView()
        
        view.rectangle = button.rectangle
        view.font = fontManager.findFont(withIdentifier: button.textFontIdentifier, size: button.textFontSize, style: button.textStyle)
        view.visible = button.visible
        view.enabled = button.enabled
        view.selectedIndex = button.selectedItem - 1
        view.title = button.name
        view.titleWidth = button.titleWidth
        view.items = separateStringLines(in: button.content)
        
        /* Set the condensed font */
        var consensedStyle = button.textStyle
        consensedStyle.condense = true
        view.condensedFont = fontManager.findFont(withIdentifier: button.textFontIdentifier, size: button.textFontSize, style: consensedStyle)
        
        return view
    }
    
    private func separateStringLines(in string: HString) -> [HString] {
        
        guard string.length > 0 else {
            return []
        }
        
        var lines = [HString]()
        
        var lineStart = 0
        let carriageReturn = HChar(13)
        
        for i in 0..<string.length {
            if string[i] == carriageReturn {
                let line = string[lineStart..<i]
                lines.append(line)
                lineStart = i+1
            }
        }
        
        /* Add the last line */
        let lastLine = string[lineStart..<string.length]
        lines.append(lastLine)
        
        return lines
    }
    
    private func findIcon(withIdentifier identifier: Int) -> MaskedImage? {
        
        if let iconResource = resources.findResource(ofType: ResourceTypes.icon, withIdentifier: identifier) {
            return maskIcon(iconResource.content)
        }
        
        return nil
    }
    
}
