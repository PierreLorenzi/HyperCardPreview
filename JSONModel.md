# Schema of exported stacks in JSON

The exported JSON is just a reproduction of the inner data model of HyperCardPreview, and so it has a structure less complex than the HyperCard file and a more intuitive. For example there is a list of the cards without sub-sections, there is an ordered list of the backgrounds, buttons and fields have contents.

Only the structure of the file is given here. If you want further documentation, see the [stack format description](StackFormat.md).

Strings are converted to UTF-8, but the characters `\p` are not converted to `\n`. If you make that conversion, beware that script can theoretically contain `\n` characters, which don't act as line separators, though it is highly unlikely.

The root object of the file is a Stack object.

## Stack
- "cards": an array of the Card objects, in right order
- "backgrounds": an array of the Background objects, in right order
- "password_hash": an integer. May be null.
- "user_level": an integer from 1 to 5
- "cant_abort": a boolean
- "cant_delete": a boolean
- "cant_modify": a boolean
- "cant_peek": a boolean
- "private_access": a boolean
- "version_at_creation": a Version object. May be null.
- "version_at_last_compacting": a Version object. May be null.
- "version_at_last_modification_since_last_compacting": a Version object. May be null.
- "version_at_last_modification": a Version object. May be null.
- "size": a Size object
- "window_rectangle": a Rectangle object. May be null.
- "screen_rectangle": a Rectangle object. May be null
- "scroll_point": a Point object. May be null.
- "script": a string.
- "font_name_references": an array of FontNameReference objects, containing the Font Name Table of the file

## Card
- "identifier": an integer
- "name": a string
- "show_pict": a boolean
- "dont_search": a boolean
- "cant_delete": a boolean
- "parts": an array of Part objects, in right order
- "next_available_part_identifier": an integer
- "script": a string
- "background_identifier": an integer
- "marked": a boolean
- "background_part_contents": an array of BackgroundPartContent objects, contains the contents of just the background parts

## BackgroundPartContent
- "part_identifier": an integer
- "part_content": a PartContent object

## PartContent

Can be either a string or a Text object.

If it is a string, there is only one key: "string", which is a string.

If it is a text, there is only one key: "text", which is a Text object.

## Text
- "string": a string
- "attributes": an array of FormattingAssociation objects

## FormattingAssociation
- "offset": an integer
- "formatting": a TextFormatting object

## TextFormatting
- "font_family_identifier": an integer. May be null, in that case, same as containing field.
- "size": an integer. May be null, in that case, same as containing field.
- "style": a TextStyle object. May be null, in that case, same as containing field.

## TextStyle
- "bold": a boolean
- "italic": a boolean
- "underline": a boolean
- "outline": a boolean
- "shadow": a boolean
- "condense": a boolean
- "extend": a boolean
- "group": a boolean

## Part

Can be either a Button or a Field object.

If it is a button, there is only one key: "button", which is a Button object.

If it is a field, there is only one key: "field", which is a Field object.

## Button
- "identifier": an integer
- "name": a string
- "style": a PartStyle object
- "rectangle": a Rectangle object
- "visible": a boolean
- "text_align": a TextAlign object
- "text_font_identifier": an integer
- "text_font_size": an integer
- "text_style": a TextStyle object
- "text_height": an integer
- "script": a string
- "content": a string (different from Field's "content" property)
- "enabled": a boolean
- "hilite": a boolean
- "auto_hilite": a boolean
- "shared_hilite": a boolean
- "show_name": a boolean
- "icon_identifier": an integer
- "family": an integer
- "title_width": an integer
- "selected_item": an integer, for popup buttons

## PartStyle
It is a string, one of the values:
- "transparent"
- "opaque"
- "rectangle"
- "round_rect"
- "shadow"
- "check_box"
- "radio"
- "scrolling"
- "standard"
- "default"
- "oval"
- "popup"

## Rectangle
- "top": an integer
- "left": an integer
- "bottom": an integer
- "right": an integer

## Field
- "identifier": an integer
- "name": a string
- "style": a PartStyle object
- "rectangle": a Rectangle object
- "visible": a boolean
- "text_align": a TextAlignment object
- "text_font_identifier": an integer
- "text_font_size": an integer
- "text_style": a TextStyle object
- "text_height": an integer
- "script": a string
- "content": a PartContent object (different from Button's "content" property)
- "lock_text": a boolean
- "auto_tab": a boolean
- "fixed_line_height": a boolean
- "shared_text": a boolean
- "dont_search": a boolean
- "dont_wrap": a boolean
- "multiple_lines": a boolean
- "wide_margins": a boolean
- "show_lines": a boolean
- "auto_select": a boolean
- "selected_line": an integer
- "last_selected_line": an integer
- "scroll: "an integer

## TextAlign
It is a string, one of the values:
- "left"
- "center"
- "right"

## Background
- "identifier": an integer
- "name": a string
- "show_pict": a boolean
- "dont_search": a boolean
- "cant_delete": a boolean
- "parts": an array of Part objects, in right order
- "next_available_part_identifier": an integer
- "script": a string

## Version
- "major": an integer
- "minor1": an integer
- "minor2": an integer
- "state": a VersionState object

## VersionState
It is a string, one of the values:
- "final"
- "beta"
- "development"
- "alpha"

## Size
- "width": an integer
- "height": an integer

## Point
- "x": an integer
- "y": an integer

## FontNameReference
- "identifier": an integer
- "name": a string
