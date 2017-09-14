**[Screenshot](http://www.hostingpics.net/viewer.php?id=554516HyperCardPreview.png)**

**[Download latest version](https://github.com/PierreLorenzi/HyperCardPreview/releases/download/1.1.0/HyperCardPreview.app.zip)**

This application displays HyperCard stacks in Mac OS X.

The binary format of HyperCard stacks has been retro-engineered by numerous people, and now it is known with pretty good reliability. If you want to learn more about it, see the site [hypercard.org](http://hypercard.org).

HyperCardPreview only displays the stacks, it does not edit them, it does not execute them. To do that you have to use a emulator: SheepShaver, Basilisk or vMac.

But it makes the seeing the stacks a little experience of the old days. The look is very close to the original one, with bitmap fonts, old-style scrollers, aliasing. In the Home stacks the look is accurate to the pixel, as in most Apple stacks, but less so if there are colors or vector fonts, and not at all if there are XCMDs.


Features:
very accurate display,
declares the stacks as its own files, so they have an icon again in the Finder.
can open stacks from both HyperCard v 2.x and v 1.x.
can open stacks with private access by hacking the encryption.

Mac OS 10.12 minimum


**How does it work?**

Command-option click on a button displays the info, content and script. Same for command-option-shift click on a field. The shortcuts are the same as in HyperCard so you’re not lost. By right-clicking somewhere on the card, a pop-up appears with the list of the buttons and fields at that location, so you can reach the ones behind.

You can change card with the arrow key, or by scrolling, or by swiping.

If you pinch the card, or press return, it shrinks and a list of the thumbnails of all the cards of the stack appears. There is also a menu command for that.

Just for fun, there is a Visual Effect menu. If you check one of them, it is applied when you change card.


**Changes since version 1.0**

Now the scroll fields can be scrolled, and the pop-up buttons can be popped up.

The tools to explore the stacks have been added.

Unfortunately, the QuickLook plug-in had to be removed because it is not handled in Swift. A Swift plug-in may work but just if it is the only one plug-in in Swift in the OS, elsewhere it crashes the QuickLook platform, so it is risky.

Glitches corrected in stacks:
vector fonts are now well displayed,
AddColor is partially handled,
stacks with private access can be opened

…plus a lot of other little bug fixes and optimizations.


**The future of the app**

It won’t grow much larger than that.

I don’t intend it to edit stacks and execute scripts, it would make an app several times more complex, and as long as nobody is using the stacks anymore, I don’t see the point.

But if you have bugs with some of your stacks, please send them to me. And if you don’t mind, just send me stacks for no particular reason, I like stacks and I have a too small corpus to make my app reliable.


**Some details of its internal functioning**

All the drawing is handled with 1-bit-per-pixel images and just when all the card is finished being drawn, it is bunch converted to RGB and displayed in the window.

The text layout and display is handled internally, using old Mac OS fonts. In those days, text processing was not as horrifyingly complex as it is now, so it was quite interesting to code.


**Can HyperCard be ported to Mac OS X?**

If you’re into that kind of thing, you’d better check [Stacksmith](https://github.com/uliwitness/Stacksmith).

In my opinion, HyperCard might be re-invented, but with a big restriction on the use cases. HyperCard had too many of them and that’s why it was so difficult to explain when people asked what it did. For example, HyperCard had cards and backgrounds, intended for display of content (text, images, databases), which is now perfectly handled by websites.
