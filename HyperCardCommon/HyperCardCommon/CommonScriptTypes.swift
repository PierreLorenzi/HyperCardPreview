//
//  CommonScriptTypes.swift
//  HyperCardCommon
//
//  Created by Pierre Lorenzi on 09/06/2018.
//  Copyright © 2018 Pierre Lorenzi. All rights reserved.
//


public enum Ordinal {
    case any
    case middle
    case last
    case number(Expression)
}

public enum RelativeOrdinal {
    case current
    case next
    case previous
}

public enum Direction {
    case left
    case right
    case up
    case down
}

public struct KeyModifier {
    public var commandKey: Bool
    public var optionKey: Bool
    public var shiftKey: Bool
}

public enum DateFormat {
    case seconds
    case dateItems
    case userReadable(Exactness: Exactness?, timeExactness: Exactness?)
}

public enum Exactness {
    case long
    case short
    case abbreviated
    case english // exists but doesn't work well
}

public enum DurationExpression {
    case seconds(Expression)
    case ticks(Expression)
}

public enum FilePositionExpression {
    case offset(Expression)
    case endOfFile
}

public enum ContainerTargetPosition {
    case into
    case before
    case after
}

public enum CursorType {
    case iBeam
    case cross
    case plus
    case watch
    case hand
    case arrow
    case busy
    case none
}

public enum EnvironmentType {
    case player
    case development
}
