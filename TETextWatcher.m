// TETextWatcher.m
// TextExtras
//
// Copyright © 1996-2006, Mike Ferris.
// All rights reserved.

#import "TETextWatcher.h"
#import "TETextUtils.h"

@implementation TETextWatcher


// ********************** Select to/Show matching brace features **********************
// ************************ Plus fancy escape completion stuff ************************

+ (void)textViewDidChangeSelection:(NSNotification *)notification {
    NSTextView *textView = [notification object];
    NSRange selRange = [textView selectedRange];

    if (1) {	// [prefs selectToMatchingBrace]
        // The NSTextViewDidChangeSelectionNotification is sent before the selection granularity is set.  Therefore we can't tell a double-click by examining the granularity.  Fortunately there's another way.  The mouse-up event that ended the selection is still the current event for the app.  We'll check that instead.  Perhaps, in an ideal world, after checking the length we'd do this instead: ([textView selectionGranularity] == NSSelectByWord).
        if ((selRange.length == 1) && ([[NSApp currentEvent] type] == NSLeftMouseUp) && ([[NSApp currentEvent] clickCount] == 2)) {
            NSRange matchRange = TE_findMatchingBraceForRangeInString(selRange, [textView string]);

            if (matchRange.location != NSNotFound) {
                selRange = NSUnionRange(selRange, matchRange);
                [textView setSelectedRange:selRange];
                [textView scrollRangeToVisible:matchRange];
            }
        }
    }
    if (1) {	//[prefs showMatchingBrace]
        NSRange oldSelRangePtr;
        
        [[[notification userInfo] objectForKey:@"NSOldSelectedCharacterRange"] getValue:&oldSelRangePtr];

        // This test will catch typing sel changes, also it will catch right arrow sel changes, which I guess we can live with.  MF:??? Maybe we should catch left arrow changes too for consistency...
        if ((selRange.length == 0) && (selRange.location > 0) && ([[NSApp currentEvent] type] == NSKeyDown) && (oldSelRangePtr.location == selRange.location - 1)) {
            NSRange origRange = NSMakeRange(selRange.location - 1, 1);
            unichar origChar = [[textView string] characterAtIndex:origRange.location];

            if (TE_isClosingBrace(origChar)) {
                NSRange matchRange = TE_findMatchingBraceForRangeInString(origRange, [textView string]);
                if (matchRange.location != NSNotFound) {
                    NSLayoutManager *layout = [textView layoutManager];

                    // Force layout
                    (void)[layout textContainerForGlyphAtIndex:[layout glyphRangeForCharacterRange:matchRange actualCharacterRange:NULL].location effectiveRange:NULL];
                    // Set selection
                    [textView setSelectedRange:matchRange];
                    // Force display
                    [textView displayIfNeeded];
                    // Force flush
                    [[textView window] flushWindow];
                    // Ping
                    //PSWait();
                    // Pause
                    [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.125]];

                    // Reset the selection
                    [textView setSelectedRange:selRange];
                }
            }
        }
    }
	if(1) // autoupdate linenumber
	{	id lpc=[[NSApp delegate] lineController];
		if(lpc) [lpc setLineNumberFromRange: selRange inView: textView];
	}
}

@end
