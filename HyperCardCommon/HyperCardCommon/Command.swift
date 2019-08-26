//
//  Command.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public enum Command {
    
    case add(Expression, to: ContainerDescriptor)
    case answer(AnswerCommand)
    case arrowKey(direction: Direction)
    case ask(AskCommand)
    case beep(count: Expression)
    case choose(toolNumber: Expression)
    case click(point: Expression, modifier: KeyModifier)
    case close(CloseCommand)
    case commandKeyDown(character: Expression)
    case controlKey(keyNumber: Expression)
    case convert(ConvertCommand)
    case copyTemplate(name: Expression, toStack: StackDescriptor)
    case create(CreateCommand)
    case debugCheckpoint
    case delete(DeleteCommand)
    case dial(number: Expression, modemCommand: Expression?)
    case disable(EnabledOrDisabledObjet)
    case divide(ContainerDescriptor, by: Expression)
    case doMenu(menuItemName: Expression, menuName: Expression?, withoutDialog: Bool, modifier: KeyModifier)
    case drag(fromPoint: Expression, toPoint: Expression, modifier: KeyModifier)
    case editScript(object: HyperCardObjectDescriptor)
    case enable(EnabledOrDisabledObjet)
    case enterInField
    case enterKey
    case exportPaint(toFileName: Expression)
    case find(FindCommand)
    case functionKey(keyNumber: Expression)
    case get(Expression)
    case go(to: CardDescriptor, inNewWindow: Bool, withoutDialog: Bool)
    case help
    case hide(ShownOrHiddenObjet)
    case importPaint(fromFileName: Expression)
    case keyDown(character: Expression)
    case lock(LockedOrUnlockedObject)
    case mark(MarkedOrUnmarkedObject)
    case multiply(ContainerDescriptor, by: Expression)
    case open(OpenCommand)
    case play(PlayCommand)
    case popCard(intoContainer: ContainerDescriptor?)
    case print(PrintCommand)
    case pushCard(PushCardCommand)
    case put(PutCommand)
    case read(fileName: Expression, startIndex: Expression?, termination: ReadTermination)
    case reply(ReplyCommand)
    case request(RequestCommand)
    case reset(ResetCommand)
    case returnInField
    case returnKey
    case run
    case save(stack: StackDescriptor, asFileName: Expression)
    case select(SelectCommand)
    case set(PropertyDescriptor, to: Expression)
    case show(ShowCommand)
    case sort(SortCommand)
    case startUsing(StackDescriptor)
    case stopUsing(StackDescriptor)
    case subtract(Expression, from: ContainerDescriptor)
    case tabKey
    case type(Expression, modifier: KeyModifier)
    case unlock(UnlockCommand)
    case unmark(MarkedOrUnmarkedObject)
    case visualEffect(VisualEffectCommand)
    case wait(WaitCommand)
    case write(Expression, toFileName: Expression, atPosition: FilePositionExpression?)
}

public enum AnswerCommand {
    case answer(text: Expression, replies: [Expression])
    case answerFile(text: Expression, fileType: Expression) // fileType is a 4-char file type
    case answerProgram(text: Expression, processType: Expression)
}

public enum AskCommand {
    case ask(text: Expression, with: Expression)
    case askPassword(text: Expression, isTextClear: Bool, with: Expression)
    case askFile(text: Expression, withFileName: Expression)
}

public enum CloseCommand {
    case closePrinting
    case closeFile(name: Expression)
    case closeDocument(name: Expression, application: Expression)
    case closeApplication(name: Expression)
    case closeWindow(WindowDescriptor)
}

public enum ConvertCommand {
    case convertExpression(Expression, fromFormat: DateFormat?, toFormat: DateFormat)
    case convertContainer(ContainerDescriptor, fromFormat: DateFormat?, toFormat: DateFormat)
}

public enum CreateCommand {
    case createMenu(name: Expression)
    case createStack(name: Expression, withBackground: BackgroundDescriptor?, inNewWindow: Bool)
}

public enum DeleteCommand {
    case deleteChunk(ContainerChunk)
    case deleteMenu(MenuDescriptor)
    case deleteMenuItem(MenuItemDescriptor)
    case deleteButtonOfField(ButtonOrFieldDescriptor)
}

public enum EnabledOrDisabledObjet {
    case menu(MenuDescriptor)
    case menuItem(MenuItemDescriptor)
    case button(ButtonDescriptor)
}

public struct FindCommand {
    public var textToFind: Expression
    public var method: FindingMethod
    public var international: Bool
    public var inField: FieldDescriptor?
    public var onlyInMarkedCards: Bool
}

public enum ShownOrHiddenObjet {
    case menuBar
    case titleBar
    case groups
    case picture(PictureDescriptor)
    case buttonOrField(ButtonOrFieldDescriptor)
    case window(WindowDescriptor)
}

public enum LockedOrUnlockedObject {
    case recent
    case messages
    case screen
    case errorDialogs
}

public enum MarkedOrUnmarkedObject {
    case allCards
    case card(CardDescriptor)
    case cardsWhere(condition: Expression)
    case cardsByFinding(FindCommand)
}

public enum OpenCommand {
    case openPrinting(withDialog: Bool)
    case openReportPrinting(withDialog: Bool)
    case openReportPrintingWithTemplate(templateName: Expression)
    case openFile(name: Expression)
    case openDocument(name: Expression, application: Expression)
    case openApplication(name: Expression)
}

public enum PlayCommand {
    case playStop
    case play(soundName: Expression, tempo: Expression?, notes: Expression?)
}

public enum PrintCommand {
    case printCard(CardDescriptor, fromPoint: Expression?, toPoint: Expression?)
    case printAllCards(fromPoint: Expression?, toPoint: Expression?)
    case printMarkedCards(fromPoint: Expression?, toPoint: Expression?)
    case printCards(count: Expression, fromPoint: Expression?, toPoint: Expression?)
    case printButtonOrField(ButtonOrFieldDescriptor)
    case printFile(name: Expression, withApplicationName: Expression)
    case printExpression(Expression)
}

public enum PushCardCommand {
    case pushCard(CardDescriptor)
    case pushBackground(BackgroundDescriptor)
    case pushStack(StackDescriptor)
}

public enum PutCommand {
    case put(Expression, intoContainer: ContainerDescriptor, atPosition: ContainerTargetPosition)
    case putMenuItemsIntoMenu(menuItems: Expression, intoMenu: MenuDescriptor, atPosition: ContainerTargetPosition, withMenuMessages: Expression?)
    case putMenuItemsIntoMenuItem(menuItems: Expression, intoMenuItem: MenuItemDescriptor, atPosition: ContainerTargetPosition, withMenuMessages: Expression?)
}

public enum ReadTermination {
    case untilPosition(FilePositionExpression)
    case untilCharacter(Expression)
}

public enum ReplyCommand {
    case reply(Expression, keyWord: Expression?)
    case replyError(Expression)
}

public enum RequestCommand {
    case request(Expression, fromProgram: ProgramDescriptor)
    case requestAppleEventData
    case requestAppleEventClass
    case requestAppleEventId
    case requestAppleEventSender
    case requestAppleEventReturnId
    case requestAppleEventSenderId
    case requestAppleEventDataWithKeyword(appleEventKeyword: Expression)
}

public enum ResetCommand {
    case resetMenuBar
    case resetPrinting
    case resetPaint
}

public enum SelectCommand {
    case selectEmpty
    case selectButtonOrField(ButtonOrFieldDescriptor)
    case selectText(inContainer: ContainerDescriptor, atPosition: ContainerTargetPosition)
}

public enum ShowCommand {
    case showObject(ShownOrHiddenObjet)
    case showAllCards
    case showMarkedCards
    case showCards(count: Expression)
    case showButtonOrFieldAtPoint(ButtonOrFieldDescriptor, atPoint: Expression)
    case showWindowAtPoint(WindowDescriptor, atPoint: Expression)
}

public enum SortCommand {
    case sortCards(by: Expression, inBackground: BackgroundDescriptor?, direction: SortDirection, style: SortStyle, onlyMarkedCards: Bool)
    case sortContainer(ContainerDescriptor, chunk: SortingChunk, by: Expression, direction: SortDirection, style: SortStyle)
}

public enum UnlockCommand {
    case unlockObject(LockedOrUnlockedObject)
    case unlockScreenWithVisualEffect(VisualEffectCommand)
}

public struct VisualEffectCommand {
    public var effect: VisualEffect
    public var speed: VisualEffectSpeed?
    public var destinationImage: VisualEffectImage?
}

public enum WaitCommand {
    case waitForDuration(DurationExpression)
    case waitUntilConditon(Expression)
    case waitWhileConditon(Expression)
}

public enum FindingMethod {
    case normal
    case characters
    case word
    case whole
    case string
}

public enum SortDirection {
    case ascending
    case descending
}

public enum SortStyle {
    case text
    case numeric
    case international
    case dateTime
}

public enum SortingChunk {
    case line
    case item
}

public enum VisualEffect {
    case barnDoor(OpeningStyle)
    case checkerBoard
    case dissolve
    case iris(OpeningStyle)
    case plain
    case push(Direction)
    case scroll(Direction)
    case shrink(to: VerticalPosition)
    case stretch(from: VerticalPosition)
    case venetianBlinds
    case wipe(Direction)
    case zoom(ZoomingStyle)
}

public enum OpeningStyle {
    case open
    case close
}

public enum VerticalPosition {
    case top
    case center
    case bottom
}

public enum ZoomingStyle {
    case open
    case close
    case `in`
    case out
}

public enum VisualEffectSpeed {
    case fast
    case slow
    case slowly
    case veryFast
    case verySlow
    case verySlowly
}

public enum VisualEffectImage {
    case black
    case card
    case gray
    case inverse
    case white
}
