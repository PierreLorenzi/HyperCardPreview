**[Screenshot](http://pierrelorenzi.fr/hypercard/screenshot.png)**

**[Download v1.4](https://github.com/PierreLorenzi/HyperCardPreview/releases/download/1.4/HyperCardPreview.app.zip)** (September 16, 2019)

Mac OS 10.12 minimum

This application displays HyperCard stacks in Mac OS X.

The binary format of HyperCard stacks has been retro-engineered by numerous people, and now it is known with pretty good reliability. If you want to learn more about it, see the [format description](StackFormat.md).

HyperCardPreview only displays the stacks, it does not edit them, it does not execute them. To do that you have to use a emulator: SheepShaver, Basilisk or vMac. For more information, you can go to [hypercard.org](http://hypercard.org/). Another option is to play with stacks in the [HyperCard Stack Archive](https://archive.org/details/hypercardstacks).

It makes the seeing the stacks an experience of the old days. The look is very close to the original one, with bitmap fonts, old-style scrollers, aliasing. In the Home stacks the look is accurate to the pixel, as in most Apple stacks, but less so if there are colors, and not at all if there are XCMDs.

Features:
- very accurate display,
- declares the stacks as its own files, so they have an icon again in the Finder,
- can open stacks from both HyperCard v 2.x and v 1.x,
- can open stacks with private access by hacking the encryption.
- can export texts, images and sounds.

## How to use it

**Browse with Keyboard**

Change Card: press an arrow key, or page up / page down / home / end

Show/Hide All Cards: press enter or return

**Browse with Trackpad**

Change Card: scroll left or right, or swipe

Show/Hide All Cards: pinch

**Display Button/Field Info**

Get Button Info: press command-option (like in HyperCard), buttons are colored in blue and you can click on one to display the info.

Get Field Info: press command-option-shift (like in HyperCard), both fields and buttons are colored in blue and you can click on one to display the info.

Get Info of a Covered Button or Field: right-click somewhere on the card, the list of the buttons and fields at that location appears, from the frontmost to the outmost. That way you can get info about a button or field even if it is covered by the others.

## Changes in version 1.4

Several new features, that make the app more lively:
- stack windows can be resized,
- text can be searched in the stacks,
- text fields can be selected and copied,
- auto-hilite buttons react to click,
- images of cards and backgrounds can be seen and copied from the info panel,
- info panels are more complete,
- compressed sound resources can be played.

Besides, performance has been improved. I thank FFMpeg (Laszlo Torok and Francois Revol) for retro-engineering the compression algorithm used by Apple in the sound resources, I now handle MACE 3-to-1 and 6-to-1 compressions.

## Technical details

**JSON Export**

The format of the JSON file is [here](JSONModel.md).

**Sounds**

Some sounds can't be read: they beep instead of play, and they can't be exported. That's because HyperCardPreview can't read compressed sound resources, only uncompressed ones.

**Colors**

Colors of the AddColor XCMD are technically handled but cause troubles. For example the stack "Color Tools" is not good at all because the display is managed partly by scripts, which are not executed. Besides, macintosh pictures (`PICT` resources, which have a complex format designed by Apple) are still accepted by Mac OS X but with restrictions, especially there is no transparency.

**Stacks v1.xx**

Stacks of HyperCard 1.xx are handled but not accurarely displayed. The problem is that HyperCard changed some display settings between versions 1.xx and 2.xx, for example the text field margins, and HyperCardPreview doesn't handle that. In fact, HyperCardPreview displays v1.xx stacks as if they were just converted to v2.xx and were displayed the v2.xx way.

**Scripts**

HyperCardPreview doesn't display other scripts that HyperTalk.

It doesn't execute any script or any XCMD or XFNC.

**Deprecation**

HyperCardPreview doesn't use any deprecated API, so its future is bright.

That means that old APIs had to be partially re-coded: resource fork reading, resource management, text display, bitmap fonts, 1-bit imaging.

**HyperCardPreview signing**

It seems that I can't have a developer ID without paying a fee to Apple. And I'm not ready to do it just for that little soft.

## The future of the app

It won’t grow much larger than that.

I don’t intend it to edit stacks and execute scripts, it would make an app several times more complex, and as long as nobody is using the stacks anymore, I don’t see the point.

But if you have bugs with some of your stacks, please inform me.

## Can HyperCard be ported to Mac OS X?

If you have that in mind, check out [LiveCode](https://github.com/livecode/livecode) or [Stacksmith](https://github.com/uliwitness/Stacksmith).

In my opinion, HyperCard might be re-invented, but with a big restriction on the use cases. HyperCard had too many of them and that’s why it was so difficult to explain when people asked what it did. For example, HyperCard had cards and backgrounds, intended for display of content (text, images, databases), which is now perfectly handled by websites.


