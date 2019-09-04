//
//  HyperCard.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


/// HyperCard, as a HyperCard object
public struct HyperCard {
    
    /// This read-only property tells you where on the AppleTalk network you are, in the form zone:computer:program. If  zone  is an asterisk (*), either your system is not on a network or the network has just one zone.
    public var address: String
    
    /// The blindTyping global property returns or sets whether you can type into the Message box and send messages from it even when it isn't visible.
    public var blindTyping: Bool
    
    /// Positive integer in the range 1 through 32. The brush property returns or sets the current brush shape used by the Brush tool.
    public var brush: Int
    
    /// The centered property returns or sets whether HyperCard draws shapes from the center rather than from a corner. It corresponds to the Centered command in the Options menu (which appears when you select a Paint tool).
    public var centered: Bool
    
    /// The cursor property sets the image that appears as the pointer on the screen.
    public var cursor: CursorType
    
    /// The debugger property returns or sets  the name of the current HyperTalk debugger.
    public var debugger: String
    
    /// The dialingTime property sets or returns the total length of time (in ticks) that HyperCard leaves the serial port open while dialing a modem.
    public var dialingTime: Int
    
    /// The dialingVolume property sets or returns the volume of the dialing tones generated through the computer speaker by the dial command.
    public var dialingVolume: Int
    
    /// The dragSpeed property returns or sets how many pixels per second the pointer will move when manipulated by all subsequent drag commands. Use 0 to drag as fast as possible.
    public var dragSpeed: Int
    
    /// The editBkgnd property returns or sets the layer where new painting or new buttons and fields will appear––in the card layer or in the background layer. It corresponds to the Background command in the Edit menu, and it’s available only when the user level is Painting (3) or higher.
    public var editBkgnd: Bool
    
    /// This read-only property returns  development when the fully enabled version of HyperCard is running or player when HyperCard Player or a standalone stack is running.
    public var environment: EnvironmentType
    
    /// The filled property returns or sets whether HyperCard fills shapes with the current pattern on the Patterns palette as you draw them. It corresponds to the Filled command in the Options menu (which appears when you select a Paint tool).
    public var filled: Bool
    
    /// The grid property returns or sets whether HyperCard constrains the movement of many Paint tools to eight-pixel intervals. It corresponds to the Grid command in the Options menu (which appears when you select a Paint tool).
    public var grid: Bool
    
    /// The ID of HyperCard returns 'WILD'
    public var identifier: Int
    
    /// The itemDelimiter property sets or retrieves what character HyperCard uses to separate items in a list.
    public var itemDelimiter: HChar
    
    /// The language property returns or sets the language in which HyperCard displays scripts. The default setting is English, and it’s always available.
    public var language: String
    
    /// Can be 1, 2, 3, 4, 6, or 8. The lineSize property returns or sets the thickness, in pixels, of lines drawn by the Paint tools. It corresponds to the line size you select in the Line Size dialog box. (The Line Size dialog box appears when you choose Line Size from the Options menu.)
    public var lineSize: Int
    
    /// The lockErrorDialogs property returns or sets whether HyperCard, on encountering an error, presents an error dialog box.
    public var lockErrorDialogs: Bool
    
    /// The lockMessages property returns or sets whether HyperCard sends certain messages automatically.
    public var lockMessages: Bool
    
    /// The lockRecent property returns or sets whether HyperCard displays miniature pictures for the last 42 cards visited by the user (or a handler) in the Recent card dialog box. (LockRecent does not affect the trail of cards you can go back to.)
    public var lockRecent: Bool
    
    /// The lockScreen property returns or sets whether HyperCard updates the screen when you go to another card. You can use lockScreen to prevent the user from seeing cards as a handler goes to them.
    public var lockScreen: Bool
    
    /// The longWindowTitles returns or sets whether HyperCard displays the full path name of a stack in the title bar of all windows that contain stacks. Its default value is false.
    public var longWindowTitles: Bool
    
    /// The messageWatcher property returns or sets the name of the external command (or XCMD) that displays the Message Watcher window for tracing scripts.  The name of HyperCard’s message watcher is MessageWatcher.
    public var messageWatcher: String
    
    /// The multiple property returns or sets whether HyperCard draws multiple images when the user (or a handler) drags with a Paint tool. It corresponds to the Draw Multiple command in the Options menu (which appears when you select a Paint tool).
    public var multiple: Bool
    
    /// Number from 1 to 100. The multiSpace property returns or sets the minimum amount of space, in pixels, between the edges of multiple shapes drawn when the multiple property is true.
    public var multiSpace: Int
    
    /// The long name of HyperCard returns the full path to HyperCard
    var name: String
    
    /// The numberFormat property returns or sets the precision with which the results of mathematical operations are displayed in fields and the Message box.
    public var numberFormat: String
    
    /// Integer in the range 1 through 40. The pattern property returns or sets the current pattern used to fill shapes or to paint with the Brush tool.
    public var pattern: Int
    
    /// Is 0 or a number from 3 to 50. The polySides property returns or sets the number of sides of a polygon created by the Regular Polygon tool.  Set polySides to 0 to draw a circle.
    public var polySides: Int
    
    /// The powerKeys property returns or sets whether the you can use keyboard shortcuts for painting actions.
    public var powerKeys: Bool
    
    /// The printMargins property returns or sets the value of the default margin spacing used by the print command.
    public var printMargins: Rectangle
    
    /// The printTextAlign property returns or sets the value of the default alignment used by the print command. The default value is left.
    public var printTextAlign: TextAlign
    
    /// The printTextFont property returns or sets the value of the default text font used by the print command. The default value is Geneva.
    public var printTextFont: String
    
    /// The printTextHeight property returns or sets the value of the default text height (or line spacing) used by the print command. The default value is 13.
    public var printTextHeight: Int
    
    /// The printTextSize property returns or sets the value of the default text size (or point size) used by the print command. The default value is 10.
    public var printTextSize: Int
    
    /// The printTextStyle property returns or sets the value of the default text style used by the print command when you print an expression. The default value is plain.
    public var printTextStyle: TextStyle
    
    /// The scriptEditor property returns or sets the name of the current script editor.
    public var scriptEditor: String
    
    /// The scriptTextFont property returns or sets the font used to display scripts in all the script editor windows.
    public var scriptTextFont: String
    
    /// The scriptTextSize property returns or sets the size of font used to display scripts in all the script editor windows.  HyperCard uses 9 as the default size.
    public var scriptTextSize: Int
    
    /// The stacksInUse property returns a return-separated list of stacks that have been inserted into the message-passing path via the start using command.  Each stack appears in the order it will receive messages. The stacksInUse contains the full path names of the stacks being used.
    public var stacksInUse: [String]
    
    /// The suspended property returns whether HyperCard is currently running in the background under MultiFinder® or under System 7.X. You can switch to another program while a handler is running, and scripts will continue to run in the background.
    public var suspended: Bool
    
    /// The textArrows property returns or sets whether the arrow keys move the insertion point in a field or move you through stacks.
    public var textArrows: Bool
    
    /// The textFont property returns or sets the current font of the Paint Text tool.
    public var textFont: Int
    
    /// The textHeight property returns or sets the space, in pixels, between the baselines of Paint text
    public var textHeight: Int
    
    /// The textSize property returns or sets the size, in pixels, of the font for Paint text.
    public var textSize: Int
    
    /// The textStyle property returns or sets the styles in which Paint text appears.
    public var textStyle: TextStyle
    
    /// The traceDelay property returns or sets the number of ticks HyperCard pauses between each statement as it traces a handler while in the debugger.
    public var traceDelay: Int
    
    /// The userLevel property returns or sets the user level
    public var userLevel: UserLevel
    
    /// The userModify property returns or sets whether the user can temporarily type into fields, use the Paint tools, and move or delete objects in a locked stack.
    public var userModify: Bool
    
    /// The variableWatcher property returns or sets the name of the external command (or XCMD) that displays the Variable Watcher window for inspecting the values of local and global variables.
    public var variableWatcher: String
    
    /// The version property returns the version number of the HyperCard application that is currently running. You can’t set the version.
    public var version: Version
}
