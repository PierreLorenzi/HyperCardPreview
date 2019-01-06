
# HyperCard File Format

This is a description of the format of HyperCard stacks.

The HyperCard file format has never been officially published, though originally intended by Bill Atkinson. The instructions in this file were retro-engineered by looking at various stacks and by comparing them, and sometimes by reading the assembly. Several people have contributed to that work: Rebecca Bettencourt, Tyler Vano, Uli Kusterer, myself. With special thanks to Michael Nichols and Bill Atkinson.

This description covers nearly all the data of a stack. But it is not complete enough to update stacks and create new ones.

## Prerequisites

All the integers are big-endian.

In flags, bits are counted from 0.

## File Layout

### Blocks

A HyperCard stack is a sequence of data blocks. Every block has:
* a type, represented as a four-character code, like `STAK`, `CARD`, `BKGD`.
* an ID that makes it unique among all the blocks of the same type in the stack.

### Block types

Here are the possible block types:
* [Stack Block](#stack-block): the global parameters of the stack (one in the file)
* [Master Block](#master-block): the index of the blocks in the file (one in the file)
* [List Block](#list-block): the list of the cards (one in the file)
* [Page Block](#page-block): a sub-section of the list of the cards
* [Card Block](#card-block): a card
* [Background Block](#background-block): a background
* [Bitmap Block](#bitmap-block): a picture of a card or of a background
* [Style Block](#style-block): the table of the text decorations used in the stack (at most one in the file)
* [Font Block](#font-block): the table of the font names used in the stack (at most one in the file)
* [Print Setting Block](#print-setting-block): the printing parameters (at most one in the file)
* [Page Set-Up Block](#page-set-up-block): the Page Setup settings (at most one in the file)
* [Report Template Block](#report-template-block): a report template
* [Free Block](#free-block): a free space inside the file
* [Tail Block](#tail-block): the ending block (one in the file)

### General Structure

The blocks in the stack are in the following order: 

| Blocks |
| --- |
| [Stack Block](#stack-block) |
| [Master Block](#master-block) |
| *Whatever blocks in any order* |
| [Tail Block](#tail-block) |

## Block Layouts

### Stack Block

This block contains the global parameters of the stack. 

Offset | Type | Content
--- | --- | ---
0x0 | [Block Header](#block-header) | Header of the block. Type is `STAK` and ID is `-1`
0x10 | UInt32 | Version of the file format, `1` to `7`: pre-release HyperCard 1.x, `8`: HyperCard 1.x, `9`: pre-release HyperCard 2.x, `10`: HyperCard 2.x
0x14 | UInt32 | Total size of the data fork
0x18 | UInt32 | Offset of the [Master Block](#master-block), counted from the start of the file
0x1C | UInt32 | Number of full tables in the [Master Block](#master-block)
0x20 | UInt32 | Number of tables in the [Master Block](#master-block) - 1
0x24 | UInt32 | Number of backgrounds in the stack
0x28 | SInt32 | ID of the first background
0x2C | UInt32 | Number of cards in the stack
0x30 | SInt32 | ID of the first card
0x34 | SInt32 | ID of the [List Block](#list-block)
0x38 | UInt32 | Number of [Free Blocks](#free-block)
0x3C | UInt32 | Total size of all the [Free Blocks](#free-block) (=`the freeSize of this stack`)
0x40 | SInt32 | ID of the [Print Setting Block](#print-setting-block). If zero, the block doesn't exist.
0x44 | UInt32 | Hash of the password (see the procedures to [check a password](#check-a-password), [open a Private Access stack](#open-a-private-access-stack), and [hack a Private Access stack](#hack-a-private-access-stack)). If zero, there is no password.
0x48 | UInt16 | Maximum user level allowed in the stack, it spans from `1` to `5`. If zero, it is `5`
0x4A | UInt16 | *Alignment bytes, =0*
0x4C | UInt16 | Protection flags, Bit 10: can't peek, Bit 11: can't abort, Bit 13: private access, Bit 14: can't delete, Bit 15: can't modify.
0x4E | UInt16 | *Alignment bytes, =0*
0x50 | SInt32 | *Field not used* (but it is still read during compacting, as a block ID)
0x54 | SInt32 | *Field not used* (but it is still read during compacting, as a block ID)
0x58 | SInt32 | *Field not used* (but it is still read during compacting, as a block ID)
0x5C | SInt32 | *Field not used* (but it is still read during compacting, as a block ID)
0x60 | [Version](#version) | HyperCard version at stack creation. If zero, it is unknown.
0x64 | [Version](#version) | HyperCard version at last compacting. If zero, it is unknown.
0x68 | [Version](#version) | HyperCard version at last modification since last compacting. If zero, it is unknown.
0x6C | [Version](#version) | HyperCard version at last modification. If zero, it is unknown.
0x70 | UInt32 | Checksum of the Stack Block (see [the procedure to check it](#check-the-check-sum-of-the-stack-block))
0x74 | UInt32 | Number of marked cards
0x78 | [Rectangle](#rectangle) | Rectangle of the card window
0x80 | [Rectangle](#rectangle) | Rectangle of the screen when the card window was measured
0x88 | [Point](#point) | Point at the origin of the scroll of the card window
0x8C | *292 bytes* | *=0*
0x1B0 | SInt32 | ID of the [Font Block](#font-block). If zero, the block doesn't exist.
0x1B4 | SInt32 | ID of the [Style Block](#style-block). If zero, the block doesn't exist.
0x1B8 | Size | Size of the stack, in pixels. If zero, it is 512 pixels wide and 342 pixels high.
0x1BC | SInt32 | *Field not used*  (but it is still read sometimes, as a block ID)
0x1C0 | Pascal String | *Field not used* (it is a path, it is still present in the Home stacks but its purpose is not clear at all)
0x2C0 | [Pattern Image](#pattern-image)[40] | The 40 patterns of the stack
0x400 | [Free Block Reference](#free-block-reference)[] | Table of the [Free Blocks](#free-block), there is one reference for every [Free Block](#free-block). The number of [Free Blocks](#free-block) is given earlier.
*variable* | *bytes* | *=0*
0x600 | [String](#string) | Script of the stack

### Master Block

This block is an index of all the blocks present in the file (excluding [Stack Block](#stack-block), [Master Block](#master-block), [Free Blocks](#free-block), and [Tail Block](#tail-block)).

It consists of successive tables which are 0x200 bytes long. The first table starts at offset 0, it encloses the block header so contrary to the others, it doesn't have data on its first 0x20 bytes. The other tables follow at offsets 0x200, 0x400, and so on.

The tables consist of slots which are 4 bytes long. Every slot corresponds to a block in the file: the slot contains the position of the block, and on the other hand, the position of the slot can be computed with the ID of the block. So when a program has a block ID and is looking for the position of the block in the file, it just has to compute the position of the corresponding slot, find it and read the position inside. More information in [the procedure to find a block](#find-a-block-in-the-file).

The number of tables is written in the [Stack Block](#stack-block). There is also the number of full tables, to know the first table with available slots.

Offset | Type | Content
--- | --- | ---
0x0 | [Block Header](#block-header) | Header of the block. Type is `MAST` and ID is `-1`
0x10 | *16 bytes* | *=0*
0x20 | UInt32[] | The slots

### List Block

This block contains the ordered list of the cards. It is unique in the file but has no defined position. To speed up insertions and deletions, the list is segmented in sections called pages. 

Offset | Type | Content
--- | --- | ---
0x0 | [Block Header](#block-header) | Header of the block. Type is `LIST`
0x10 | UInt32 | Number of pages
0x14 | UInt32 | Size of a page, always `0x800`
0x18 | UInt32 |	Total number of cards
0x1C | UInt16 | Size of a card reference in the pages
0x1E | UInt16 | *always 2*
0x20 | UInt16 | Number of hash integers in a card reference in the pages, equal to (reference size - 4)/4
0x22 | UInt16 | Search hash value count, this value is used in search hash computations
0x24 | UInt32 | Checksum (see [the procedure to check it](#check-the-checksum-of-the-list))
0x28 | UInt32 | Total number of cards again. Both values are probably computed differently and checked against each other.
0x2C | *4 bytes* | *=0*
0x30 | [Page Reference](#page-reference)[] | The references of the pages

### Page Block

A page block contains a section of the card list.

Offset | Type | Content
--- | --- | ---
0x0 | [Block Header](#block-header) | Header of the block. Type is `PAGE`
0x10 | SInt32 | ID of the [List Block](#list-block)
0x14 | UInt32 | Checksum (see [the procedure to check it](#check-the-checksum-of-a-page))
0x18 | [Card Reference](#card-reference)[] | The references of the cards

### Card Block

A card block contains the properties of a card.

Offset | Type | Content
--- | --- | ---
0x0 | [Block Header](#block-header) | Header of the block. Type is `CARD`, and the ID of the block is the same as the ID of the card in HyperCard
0x10 | SInt32 | ID of the [Bitmap Block](#bitmap-block) storing the card picture. If zero, the card is transparent.
0x14 | UInt16 | Flags, Bit 14: can't delete, Bit 13: (not show pict), Bit 11: don't search
0x16 | UInt16 | *Alignment bytes, =0*
0x18 | *8 bytes* | *=0*
0x20 | SInt32 | ID of the [Page Block](#page-block) referencing this card
0x24 | SInt32 | ID of the background of this card
0x28 | UInt16 | Number of parts
0x2A | UInt16 | ID available for the next created part
0x2C | UInt32 | Total size of the part list
0x30 | UInt16 | Number of part contents
0x32 | UInt32 | Total size of the part content list
0x36 | [Part](#part)[] | List of the parts, buttons and fields together
*variable* | [Part Content](#part-content)[] | List of the contents of the parts
*variable* | [String](#string) | Name of the card
*variable* | [String](#string) | Script of the card

### Background Block

A background block contains the properties of a background.

Offset | Type | Content
--- | --- | ---
0x0 | [Block Header](#block-header) | Header of the block. Type is `BKGD`, and the ID of the block is the same as the ID of the background in HyperCard
0x10 | SInt32 | ID of the [Bitmap Block](#bitmap-block) storing the background picture. If zero, the background is transparent.
0x14 | UInt16 | Flags, Bit 14: can't delete, Bit 13: (not show pict), Bit 11: don't search
0x16 | UInt16 | *Alignment bytes, =0*
0x18 | UInt32 | Number of cards in this background
0x1C | SInt32 | ID of the next background
0x20 | SInt32 | ID of the previous background
0x24 | UInt16 | Number of parts
0x26 | UInt16 | ID available for the next created part
0x28 | UInt32 | Total size of the part list
0x2C | UInt16 | Number of part contents
0x2E | UInt32 | Total size of the part content list
0x32 | [Part](#part)[] | List of the parts, buttons and fields together
*variable* | [Part Content](#part-content)[] | List of the contents of the parts
*variable* | [String](#string) | Name of the background
*variable* | [String](#string) | Script of the background

### Bitmap Block

A bitmap stores the picture of a card or of a background. It has two layers: an image and a mask. See [the procedure to decode a bitmap](#decompress-a-bitmap-image).

Offset | Type | Content
--- | --- | ---
0x0 | [Block Header](#block-header) | Header of the block. Type is `BMAP`
0x10 | UInt32 | *=0*
0x14 | UInt32 | *=0x10000*
0x18 | [Rectangle](#rectangle) | Rectangle of the whole card
0x20 | [Rectangle](#rectangle) | Rectangle of the mask
0x28 | [Rectangle](#rectangle) | Rectangle of the image
0x30 | UInt32 | *=0*
0x34 | UInt32 | *=0*
0x38 | UInt32 | Size of the mask data
0x3C | UInt32 | Size of the image data
0x40 | *bytes* | Mask data
*variable* | *bytes* | Image data

### Style Block

This block stores a table of the decorations used in the texts of the stack.

Offset | Type | Content
--- | --- | ---
0x0 | [Block Header](#block-header) | Header of the block. Type is `STBL`
0x10 | UInt32 | Number of decorations
0x14 | UInt32 | ID available for the next created decoration
0x18 | [Decoration](#decoration)[] | The list of the decorations

### Font Block

Since font IDs were not consistent across Macintosh installations, HyperCard stores a table of the names of the fonts used in the stack.

Offset | Type | Content
--- | --- | ---
0x0 | [Block Header](#block-header) | Header of the block. Type is `FTBL`
0x10 | UInt32 | Number of font records
0x14 | UInt32 | *=0*
0x18 | [Font Record](#font-record)[] | List of the font records

### Print Setting Block

This block contains the HyperCard print settings and template indexes.

Offset | Type | Content
--- | --- | ---
0x0 | [Block Header](#block-header) | Header of the block. Type is `PRNT`
0x10 | *32 bytes* | *Unknown Data*
0x30 | UInt16 | ID of the [Page Set-Up Block](#page-set-up-block)
0x32 | *258 bytes* | *Unknown Data*
0x134 | UInt16 | Number of report template references
0x136 | [Report Template Reference](#report-template-reference)[] | List of the report template references

### Page Set-Up Block

This block is the Mac OS print setting. 

Offset | Type | Content
--- | --- | ---
0x0 | [Block Header](#block-header) | Header of the block. Type is `PRST`
0x10 | TPrint | TPrint is a QuickDraw structure that stores the settings of a Page Set-Up dialog. It is documented in "Inside Macintosh: Imaging with QuickDraw", at the section "Printing Manager". It is not described here because it contains very specific data, reserved fields and because it wasn't supposed to be used by an application, just given as arguments to the routines of the System.

### Report Template Block

This block contains the setting of a "Print Report" dialog.

The lengths measured in pixels are not always the same in the data and in the dialog. They may be multiplied by a factor in-between.

The following settings of the dialog are not saved in the data: "Print all cards" / "Print marked cards", and "Precision Adjustments".

Offset | Type | Content
--- | --- | ---
0x0 | [Block Header](#block-header) | Header of the block. Type is `PRFT`
0x10 | UInt8 | 	Displayed unit, `0`: centimeters, `1`: millimeters, `2`: inches, `3`: points/pixels
0x11 | UInt8 | *Unknown value*
0x12 | [Rectangle](#rectangle) | Margins of the page, in points
0x1A | [Size](#size) | Spacing between the cells, in points
0x1E | [Size](#size) | Size of a cell, in points
0x22 | UInt16 | Flags, Bit 8: left to right (as opposed to top to bottom), Bit 0: dynamic height
0x24 | [Pascal String](#pascal-string) | Header (string on top of the page). The following control characters can be embedded: `0x01`: date, `0x02`: time, `0x03`: stack name, `0x04`: page number.
*variable* | *bytes* | *Unknown values*
0x124 | UInt16 | Number of report items
0x126 | [Report Item](#report-item)[] | The report items

### Free Block

A Free Block is a space in the file that isn't currently used, it contains garbage and doesn't represent anything.

Offset | Type | Content
--- | --- | ---
0x0 | [Block Header](#block-header) | Header of the block. Type is `FREE`, ID is `0`
0x10 | *bytes* | Unused data

### Tail Block

This block contains no information, it just marks the end of the file. 

Offset | Type | Content
--- | --- | ---
0x0 | [Block Header](#block-header) | Header of the block. Type is `TAIL` and ID is `-1`
0x10 | [Pascal String](#pascal-string) | Tailing string: "Nu är det slut…". This is the closing line of a Swedish children's show called "Five Ants Are More Than Four Elephants", it means "this is the end". In HyperCard 1.x it used to be "That's all folks...", the closing line of Looney Tunes cartoons.

## Other data

### Block Header

The header of the data blocks.

Offset | Type | Content
--- | --- | ---
0x0 | UInt32 | The size of the block, including the header. Don't rely too much on it, it is sometimes corrupted.
0x4 | UInt32 | The type of the block
0x8 | SInt32 | The ID of the block
0xC | UInt32 | *Alignment bytes, =0*

### Card Reference

Offset | Type | Content
--- | --- | ---
0x0 | SInt32 | ID of the referenced [Card Block](#card-block)
0x4 | UInt8 | Flags, Bit 4: marked card, Bit 5: has text content, Bit 6: is the start of a background, Bit 7: has a name
0x5 | *bytes* | Word search hash, see [the procedure to decode it](#check-a-word-in-a-word-search-hash). All the card references in a stack have the same size, which is given in the list, from which the size of this hash can be computed.

### Character

A character is a 8-bit unsigned integer, storing a character from the Mac OS Roman encoding. It spans from 0 to 255.

### Decoration

A text decoration. It is a structure of the TextEdit API.

Offset | Type | Content
--- | --- | ---
0x0 | UInt32 | ID of the decoration
0x4 | UInt32 | Number of runs having this decoration
0x8 | UInt16 | *should be line height, but never used*
0xA | UInt16 | *should be font ascent, but never used*
0xC | SInt16 | ID of the font. If `-1`, same as containing field.
0xE | SInt16 | Style flags, Bit 15: group, Bit 14: extend, Bit 13: condense, Bit 12: shadow, Bit 11: outline, Bit 10: underline, Bit 9: italic, Bit 8: bold. If `-1`, same as containing field.
0x10 | SInt16 | Text size. If `-1`, same as containing field.
0x12 | UInt16 | *should be red component, but never used*
0x14 | UInt16 | *should be green component, but never used*
0x16 | UInt16 | *should be blue component, but never used*

### Font Record

Offset | Type | Content
--- | --- | ---
0x0 | SInt16 | ID of the font
0x2 | [String](#string) | Name of the font
*variable* | *0 or 1 byte* | Alignment to 16 bits

### Free Block Reference

Offset | Type | Content
--- | --- | ---
0x0 | UInt32 | Offset of the [Free Block](#free-block) in the file
0x4 | UInt32 | Size of the [Free Block](#free-block)

### Page Reference

Offset | Type | Content
--- | --- | ---
0x0 | SInt32 | ID of the [Page Block](#page-block)
0x4 | UInt16 | Number of cards in the page

### Part

Represents a button or a field.

Offset | Type | Content
--- | --- | ---
0x0 | UInt16 | Size of the part data, including this field
0x2 | UInt16 | ID of the part
0x4 | UInt16 | Flags, Bit 8: type of the part (`0` is "field", `1` is "button"), Bit 7: (not visible), Bit 5: don't wrap, Bit 4: don't search, Bit 3: shared text, Bit 2: (not fixed line height), Bit 1: auto tab, Bit 0: (not enabled) / lock text
0x6 | [Rectangle](#rectangle) | Rectangle of the part
0xE | UInt8 | Flags, Bit 7: show name / auto select, Bit 6: highlight / show lines, Bit 5: auto highlight / wide margins, Bit 4: (not shared highlight)/ multiple lines, Bits 3-0: family
0xF | UInt8 | Style of the part: `0` is "transparent", `1` is "opaque", `2` is "rectangle", `3` is "round rect", `4` is "shadow", `5` is "check box", `6` is "radio", `7` is "scrolling", `8` is "standard", `9` is "default", `10` is "oval", `11` is "pop-up"
0x10 | UInt16 | `button`: title width, `field`: last of the selected lines
0x12 | SInt16 | `button`: ID of the icon, if zero there is no icon, `pop-up button`: selected line, `field`: first of the selected lines
0x14 | SInt16 | Text alignment: `0` is "left", `1` is "center", `-1` is "right". Sometimes there are other values, which are rendered as "left".
0x16 | SInt16 | ID of the font. For unknown reasons it can be negative, in that case the font ID is `-value-1`
0x18 | UInt16 | Text size, in points
0x1A | UInt8 | Text style flags, Bit 7: group, Bit 6: extend, Bit 5: condense, Bit 4: shadow, Bit 3: outline, Bit 2: underline, Bit 1: italic, Bit 0: bold
0x1B | UInt8 | *Alignment byte, =0*
0x1C | UInt16 | Line height
0x1E | [String](#string) | Name of the part
*variable* | UInt8 | *=0*. If there is no script, this byte is not present and the part data stops after the name.
*variable* | [String](#string) | Script of the part
*variable* | *0 or 1 byte* | Alignment to 16 bits

### Part Content

A part content is a string which can be either plain either decorated. For buttons it is always plain.

There is a special case for a background button with shared hilite set to false. When such a button is hilited in a specific card, the card has a part content associated to the button, equal to plain string "1". As for the real text content of the button, it is stored in the background.

Offset | Type | Content
--- | --- | ---
0x0 | SInt16 | ID of the part that has the content. If the value is < 0, it is a card part with ID (-partID). Otherwise it is a background part.
0x2 | UInt16 | Size of the part content data, not counting the part ID and size fields

If the content is a plain string, the rest is:

Offset | Type | Content
--- | --- | ---
0x4 | UInt8 | *=0*. Plain string marker.
0x5 | [Character](#character)[] | String content, *not null terminated*, finishes at the end of the part content data

If the content is a decorated string, the rest is:

Offset | Type | Content
--- | --- | ---
0x4 | UInt16 | Size of the list of the runs, including this field, that is, equal to the size of the list of the runs + 2. The highest bit is always set, it must be ignored.
0x6 | [Run](#run)[] | List of the runs
*variable* | [Character](#character)[] | String content, *not null terminated*, finishes at the end of the part content data

### Pascal String

A Pascal String is an alternative representation of strings. It was less and less used at the time.

Offset | Type | Content
--- | --- | ---
0x0 | UInt8 | Size of the string
0x1 | [Character](#character)[] | The string, *not null terminated*

### Pattern Image

Offset | Type | Content
--- | --- | ---
0x0 | UInt8[8] | Each of the 8 rows of the image (which is 8 pixels wide), from top to bottom.

### Point

In Quickdraw points, `y` is before `x`.

Offset | Type | Content
--- | --- | ---
0x0 | UInt16 | Y, in pixels
0x2 | UInt16 | X, in pixels

### Rectangle

Offset | Type | Content
--- | --- | ---
0x0 | UInt16 | Top, in pixels
0x2 | UInt16 | Left, in pixels
0x4 | UInt16 | Bottom, in pixels
0x6 | UInt16 | Right, in pixels

### Report Item

An item is an area in a cell that contains text.

Offset | Type | Content
--- | --- | ---
0x0 | UInt16 | Size of the item data, including this field
0x2 | [Rectangle](#rectangle) | Rectangle of the item within the cell
0xA | UInt16 | Number of columns
0xC | UInt16 | Flags, Bit 13: change height, Bit 12: change style, Bit 11: change size, Bit 10: change font, Bit 4: invert, Bit 3: right frame, Bit 2: bottom frame, Bit 1: left frame, Bit 0: top frame
0xE | UInt16 | Text size
0x10 | UInt16 | Text height
0x12 | UInt16 | Text style, Bit 15: group, Bit 14: extend, Bit 13: condense, Bit 12: shadow, Bit 11: outline, Bit 10: underline, Bit 9: italic, Bit 8: bold
0x14 | SInt16 | Text alignment, 0: left, 1: center, -1: right
0x16 | [String](#string) | Content (it is a text string or a HyperTalk expression)
*variable* | [String](#string) | Font name
*variable* | *0 or 1 byte* | *Alignment to 16 bits*


### Report Template Reference

Offset | Type | Content
--- | --- | ---
0x0 | SInt32 | ID of the [Report Template Block](#report-template-block)
0x4 | [Pascal String](#pascal-string) | Name of the template
*variable* | *bytes* | Filling bytes to make the whole entry 36 bytes long

### Run

A run is a contiguous range of characters in a text where the same decoration is applied

Offset | Type | Content
--- | --- | ---
0x0 | UInt16 | Offset of the run in the string
0x2 | UInt16 | ID of the decoration applied to the characters, to be looked in the [Style Block](#style-block)

### Size

In Quickdraw sizes, height is before width.

Offset | Type | Content
--- | --- | ---
0x0 | UInt16 | Height, in pixels
0x2 | UInt16 | Width, in pixels

### String

A string is a null-terminated sequence of characters.

Offset | Type | Content
--- | --- | ---
0x0 | [Character](#character)[] | The characters, null terminated

### Version

Offset | Type | Content
--- | --- | ---
0x0 | UInt8 | Major
0x1 | UInt8 | Minor: first minor in the upper 4 bits, second minor in the lower 4 bits
0x2 | UInt8 | State: `0x80` is "final", `0x60` is "beta", `0x40` is "alpha", `0x20` is "development"
0x3 | UInt8 | Release

For example, `0x02206044` is "version 2.2 beta release 44" (the release is written in hexa), and `0x02418000` is "version 2.4.1 final".

## Procedures

This section contains the procedures to decode some of the data.

### Open a Private Access stack

When a stack is Private Access, a part of the [Stack Block](#stack-block) is encrypted (from offset 0x18 to 0x4A). To decrypt it, you must ask the user for a password (if you want to hack the encryption, see [the procedure about it](#hack-a-private-access-stack)).

First, here are two utility functions: 

```
% This is the 'Random' function of the first Mac OS (not very random)
function hashNumber(x: UInt32):
    h := x * 0x41A7
    h := h + (h >> 31)
    h := h & 0x7FFFFFFF
    return h

% This is the password hash function used by HyperCard
function hash(string: String):
    h: UInt32 := 0

    x: UInt32 := string[0] + string.length
    if x > 0xFF:
        x := x & 0xFF
    else if string[0] > 0x80:
        x := x | 0xFFFFFF00

    foreach character in string:
        foreach bit in character: // from higher to lower bit
            x := hashNumber(x)
            if bit:
                h := h + x

    if h = 0:
        return 0x42696C6C   %'Bill'

    return h
```

To decrypt the [Stack Block](#stack-block), here is the procedure:

```
function decryptStackBlock(password: String):
    h: UInt32 := hash(password)
    repeat 10 times
        h := hashNumber(h)
    for i in {0x18, 0x1A, ..., 0x46}
        h := hashNumber(h)
        (stackBlock[i] as UInt32) := h XOR (stackBlock[i] as UInt32)
```

After this procedure, the password hash is decrypted. It must then be checked against the password given by the user (see [the procedure to do it](#check-a-password)), and only then it can be certified as valid.

### Check a password

If a stack has a password hash different from zero, the password must (theoretically) be asked to the user. A stack can have a password without being Private Access, that is, without being encrypted.

The password given by the user is hashed, and if the result hash not equal to the hash in the stack, the stack can't be opened.

To hash a password, here is the procedure:

```
function hashPassword(password: String):
	h1: UInt32 := hash(password)
	s: String := h1 as 4-character String
	h2: UInt32 := hash(s)
	return h2
```

### Hack a Private Access stack

It is possible to decrypt an encrypted [Stack Block](#stack-block) without the password. We describe roughly how to do it.

The first encrypted 32-bit integer of the [Stack Block](#stack-block), at offset 0x18, is a big weakness because it contains the offset of the [Master Block](#master-block), which is always equal to the size of the [Stack Block](#stack-block), and that one we know because it is written in the header. So by XORing the size of the [Stack Block](#stack-block) with that integer, we get `h`, the value used to XOR the integer.

According to the function `decryptStackBlock`, the value `h` is equal to `x XOR (hashNumber(x) >> 16)`, `x` being an unknown 32-bit integer. But, as we see, the first 16 bits of `h` are the same first 16 bits of `x`, so we already know half of `x`. For the remaining 16 bits, we just have to check them all: for every possible value of `x`, we compute `x XOR (hashNumber(x) >> 16)` and check if it is equal to `h`.

There may be more than one `x` that works (there can be two), so every time a value is found, the consistency of the decrypted header must be checked. The best value to check is the User Level, it must be between `0` and `5`. 

### Check the check-sum of the Stack Block

To check it: cast as `UInt32[384]` the whole [Stack Block](#stack-block) (up to offset 0x600, until the script). The sum of the ints must be zero.

If the stack is Private Access, the checksum must be computed on the decrypted data.

### Find a block in the file

This procedure is to find the position of a block in the file from its ID.

To do that, the slot of the block must be found in the [Master Block](#master-block). The position of that slot is computed with the ID of the block.

In fact, the ID of a block has three parts:
- bits 0-7: a random value, to identify the block a little bit,
- bits 8-14: when multiplied by 4, the offset of the slot in the table,
- bits 15-31: the index of the table where the slot lies.

So the position of the slot is just extracted from the ID.

The lowest byte of the slot must be equal to the lowest byte of the ID.

Then the position of the block is computed by multiplying the three upper bytes of the slot by 0x20.

### Check the checksum of the list

```
function computeListChecksum():
	x: UInt32 := 0
	for pageReference in pageReferences:
		x := x + pageReference.identifier
		x := rotateRight3Bits(x)
		x := x + pageReference.numberOfCards
	return x
```

### Check the checksum of a page

```
function computePageChecksum():
	x: UInt32 := 0
	for cardReference in cardReferences:
		x := x + cardReference.identifier
		x := rotateRight3Bits(x)
	return x
```

### Check a word in a word search hash

The word search hash has been largely retro-engineered but it is complex and there are details I'm not sure about. If you're interested, see the source code of HyperCardPreview.

### Decompress a bitmap image

Bitmaps are compressed in a proprietary format designed by Bill Atkinson. This part is dedicated to Rebecca Bettencourt, who retro-engineered this format and christened it "WOBA", Wrath of Bill Atkinson, for its tortuous complexity.

A bitmap has two layers: an image and a mask. Both are decompressed to a raw data with 1 bit per pixel, aligned to 32 bits. The color of a pixel is given by:
- if the pixel has a value of 1 in the image, it is black.
- elsewhere, if it has a value of 1 in the mask, it is blank.
- elsewhere, it is transparent.

Both the mask and the image have a bounding rectangle (which can be zero) and a content data (which can be present or not). Here is how they interact:
- if the content data is present, it is decompressed and displayed in the bounding rectangle.
- if the content data is not present but the bounding rectangle is not zero, the pixels in the bounding rectangle are 1.
- if the content data is not present and the bounding rectangle is zero, the pixels everywhere are 0.

Before decompressing the data, the bounding rectangles of the mask and of the image must be rounded down to a multiple of 32 bits to the left side, and rounded up to a multiple of 32-bits to the right side. The result rectangles enclose white pixels on each side.

The compressed data is a series of instructions of various lengths. The first byte of an instruction, the opcode, indicates how long the instruction is and what it does. The remaining bytes, if any, are data needed for the instruction. Rows can be compressed with a single instruction (with opcodes in the range 0x80-0x87) or a sequence of multiple instructions (with opcodes in the ranges of 0x00-0x7F and 0xC0-0xFF). Some operations change the manner in which rows are decompressed (opcodes in the range 0x88-0xBF). The end of a row comes either when the row has been filled (when the number of bytes in a row, determined by the mask or image's bounding rectangle, has been reached) or when an opcode in the range 0x80-0xBF is encountered.

The instructions are listed below:

Opcode | Instruction | Description
--- | --- | ---
0x00-0x7F | `dz xx xx xx ...` | `z` zero bytes followed by `d` data bytes
0x80 | `80 xx xx xx ...` | one row of decompressed data
0x81 | `81` | one white row
0x82 | `82` | one black row
0x83 | `83 xx` | one row of a repeated byte of data
0x84 | `84` | one row of a repeated byte of data previously used (see below)
0x85 | `85` | copy the previous row
0x86 | `86` | copy the row before the previous row
0x87 | `87` | *not used*
0x88 | `88` | `dh` = 16, `dv` = 0 (see below)
0x89 | `89` | `dh` = 0, `dv` = 0 (see below)
0x8A | `8A` | `dh` = 0, `dv` = 1 (see below)
0x8B | `8B` | `dh` = 0, `dv` = 2 (see below)
0x8C | `8C` | `dh` = 1, `dv` = 0 (see below)
0x8D | `8D` | `dh` = 1, `dv` = 1 (see below)
0x8E | `8E` | `dh` = 2, `dv` = 2 (see below)
0x8F | `8F` | `dh` = 8, `dv` = 0 (see below)
0x90-0x9F | | *not used*
0xA0-0xBF | `101nnnnn` | repeat the next instruction `n` times
0xC0-0xDF | `110ddddd xx ...` | `d`*8 bytes of data
0xE0-0xFF | `111zzzzz` | `z`*16 bytes of zero

About repeated bytes of data: keep an array of 8 bytes, initialize it at `0xAA55AA55AA55AA55` (gray pattern). When a 0x83 instruction is encountered, take the current y-coordinate modulo 8, and put the byte into that element of the array. When a 0x84 instruction is encountered, take the row y-coordinate modulo 8, and use that element of the array to fill the row.

About `dh` and `dv`: these values are used apply transformations to a row, initially `dh` = 0 and `dv` = 0. Every time a row is completed (except single-instruction rows in the range 0x80-0x87), the following operations are performed:
- Make a copy of the row.
- If `dh` != 0, repeat:
	- Shift the copied row `dh` bits to the right.
	- If the copied row is zero, stop looping
	- XOR the copied row with the original row.
- If `dv` != 0, XOR the copied row with the row `dv` rows back.
- Set the original row to the copied row

## Stacks of HyperCard 1.xx

In HyperCard 1.xx, the stacks have a slightly different format. We list all the differences.

### General Differences

There are no decorated texts in the stacks, so there are neither [Style Block](#style-block) nor [Font Block](#font-block).

Some values are absent, but as they are set to zero, they can be parsed like v2.xx values and then be considered as empty or default.

The block headers are shorter because they don't have the empty alignment integers at 0xC. So, some fields aren't at the same place because at v2.xx they had to move values to let room for the new wider headers, and sometimes it caused a little mess.

### Stack Block

The checksum is at offset 0xC

Note: the card size, window rectangle, screen rectangle, scroll origin, style block, font block, don't exist and are set to zero. But they can be parsed *as is* in v2.xx.

### List Block

All values at offsets between 0x10 and 0x28 are moved 4 bytes to the left. The page references remain at offset 0x30.

### Page Block

Both values at offsets 0x10 and 0x14 are moved 4 bytes to the left. The card references remain at offset 0x18.

### Card Block

Except the header, all the values are shifted 4 bytes to the left.

### Background Block

Except the header, all the values are shifted 4 bytes to the left.

### Part Content

Part contents are always plain strings. They are not aligned to 16-bits, they can be off by 1 byte.

Offset | Type | Content
--- | --- | ---
0x0 | SInt16 | ID of the part that has the content. If the value is < 0, it is a card part with ID (-partID). Otherwise it is a background part.
0x2 | String | String content

### Bitmap Block

Except the header, all the values are shifted 4 bytes to the left.
