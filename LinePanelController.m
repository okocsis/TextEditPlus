/*
     File: LinePanelController.m
 Abstract: "Select Line" panel controller for TextEdit. 
 Enables selecting a single line, range of lines, from start or relative to current selected range.
  Version: 1.7.1
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 
 */

#import "LinePanelController.h"
#import "TextEditErrors.h"
#import "TextEditMisc.h"
#import "Controller.h"
#import "TETextUtils.h"

@implementation LinePanelController

- (id)init {
    return [super initWithWindowNibName:@"SelectLinePanel"];
}

- (void)windowDidLoad {
    NSWindow *window = [self window];
    [window setIdentifier:@"Line"];
    [window setRestorationClass:[self class]];
    [super windowDidLoad];  // It's documented to do nothing, but still a good idea to invoke...
}

/* Reopen the line panel when the app's persistent state is restored. 
*/
+ (void)restoreWindowWithIdentifier:(NSString *)identifier state:(NSCoder *)state completionHandler:(void (^)(NSWindow *, NSError *))completionHandler {
    completionHandler([[(Controller *)[NSApp delegate] lineController] window], NULL);
}

/* A short and sweet example of use of NSScanner. Parses user's line specification, in the form of N, or N-M, or +N-M, or -N-M. Returns NO on error. Assumes none of the out parameters are NULL!
*/
- (BOOL)parseLineDescription:(NSString *)desc fromLineSpec:(NSInteger *)fromLine toLineSpec:(NSInteger *)toLine relative:(NSInteger *)relative {
    NSScanner *scanner = [NSScanner localizedScannerWithString:desc];
    *relative = [scanner scanString:@"+" intoString:NULL] ? 1 : ([scanner scanString:@"-" intoString:NULL] ? -1 : 0);	    // Look for "+" or "-"; set relative to 1 or -1, or 0 if neither found
    if (![scanner scanInteger:fromLine]) return NO;	// Get the "from" spec
    if ([scanner scanString:@"-" intoString:NULL]) {	// If "-" seen, look for the "to" spec
	if (![scanner scanInteger:toLine] || (*toLine < *fromLine)) return NO;	    // There needs to be a number that is not less than the "from" spec
    } else {
	*toLine = *fromLine;				// If not a range, set the "to" spec to be the same as "from"
    }
    return [scanner isAtEnd] ? YES : NO;		// If more stuff, error. Note that the scanner skips over white space
}

/* getRange:... gets the range to be selected in the specified textView using the indicated start, end, and relative values
    If relative = 0, then select from start of fromLine to end of toLine. The first line of the text is line 1.
    If relative != 0 then select from start of fromLine lines from current selected range to toLine lines from current selected range.
      toLine == fromLine means a one-line selection
*/
- (BOOL)getRange:(NSRange *)rangePtr inTextView:(NSTextView *)textView fromLineSpec:(NSInteger)fromLine toLineSpec:(NSInteger)toLine relative:(NSInteger)relative {
    NSRange newSelection = {0, 0};	// Character locations for the new selection
    NSString *textString = [textView string];

    if (relative != 0) {		// Depending on relative direction, set the starting point to beginning of line at the start or end of the existing selected range
	NSRange curSel = [textView selectedRange];
	if (relative > 0) curSel.location = NSMaxRange(curSel) - ((curSel.length > 0) ? 1 : 0);
	[textString getLineStart:&newSelection.location end:NULL contentsEnd:NULL forRange:NSMakeRange(curSel.location, 0)];
    } else {
	if (fromLine == 0) return NO;	// "0" is not a valid absolute line spec
    }

    // At this point, newSelection.location points at the beginning of the line we want to start from
    if (relative < 0) {	    // Backwards relative from that spot
	for (NSInteger cnt = 1; cnt < fromLine; cnt++) {
	    if (newSelection.location == 0) return NO;	// Invalid specification
	    NSRange lineRange = [textString lineRangeForRange:NSMakeRange(newSelection.location - 1, 0)];
	    newSelection.location = lineRange.location;
	}
	NSInteger end = newSelection.location;	// This now marks the end of the range to be selected
	for (NSInteger cnt = fromLine; cnt <= toLine; cnt++) {
	    if (newSelection.location == 0) return NO;	// Invalid specification
	    NSRange lineRange = [textString lineRangeForRange:NSMakeRange(newSelection.location - 1, 0)];
	    newSelection.location = lineRange.location;
	}
	newSelection.length = end - newSelection.location;
    } else {		    // Forwards
	NSInteger textLength = [textString length];
	for (NSInteger cnt = (relative == 0) ? 1 : 0; cnt < fromLine; cnt++) {	// If not a relative selection, we start counting from 1, since the first line is "line 1" to the user
	    if (newSelection.location == textLength) return NO;	    // Invalid specification
	    NSRange lineRange = [textString lineRangeForRange:NSMakeRange(newSelection.location, 0)];
	    newSelection.location = NSMaxRange(lineRange);
	}
	NSInteger end = newSelection.location;
	for (NSInteger cnt = fromLine; cnt <= toLine; cnt++) {	// If not relative, the end of the range is an absolute line number; otherwise it's relative
	    if (end == textLength) return NO;    // Invalid specification
	    NSRange lineRange = [textString lineRangeForRange:NSMakeRange(end, 0)];
	    end = NSMaxRange(lineRange);
	}
	newSelection.length = end - newSelection.location;
    }
    if (rangePtr) *rangePtr = newSelection;
    return YES;
}

/* selectLinesUsingDescription:error: selects the specified lines. On error it returns NO and sets *error if not NULL.
*/
- (BOOL)selectLinesUsingDescription:(NSString *)desc error:(NSError **)error {
    id firstResponder = [[NSApp mainWindow] firstResponder];
    if ([firstResponder isKindOfClass:[NSTextView class]]) {
	NSInteger fromLine, toLine, relative;
	if (![self parseLineDescription:desc fromLineSpec:&fromLine toLineSpec:&toLine relative:&relative]) {
	    if (error) *error = [NSError errorWithDomain:TextEditErrorDomain code:TextEditInvalidLineSpecification userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Invalid line specification \\U201c%@\\U201d.", @"LinePanel", @"Error message indicating invalid line specification for 'Select Line'"), truncatedString(desc, 100)], NSLocalizedDescriptionKey, NSLocalizedStringFromTable(@"Please enter the line number or numbers (separated by dash) of the line(s) to select.", @"LinePanel", @"Suggestion for correcting invalid line specification"), NSLocalizedRecoverySuggestionErrorKey, nil]];
	    return NO;
	}
	NSRange range;
        if (![self getRange:&range inTextView:firstResponder fromLineSpec:fromLine toLineSpec:toLine relative:relative]) {
	    if (error) *error = [NSError errorWithDomain:TextEditErrorDomain code:TextEditOutOfRangeLineSpecification userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSString stringWithFormat:NSLocalizedStringFromTable(@"Invalid line specification \\U201c%@\\U201d.", @"LinePanel", @"Error message indicating invalid line specification for 'Select Line'"), truncatedString(desc, 100)], NSLocalizedDescriptionKey, NSLocalizedStringFromTable(@"Please enter the line number or numbers (separated by dash) of the line(s) to select.", @"LinePanel", @"Suggestion for correcting invalid line specification"), NSLocalizedRecoverySuggestionErrorKey, nil]];
	    return NO;
	}
	[firstResponder setSelectedRange:range];
	[firstResponder scrollRangeToVisible:range];
    }
    return YES;
}

/* If the user enters a line specification and hits return, we want to order the panel out if successful.  Hence this extra action method.
*/
- (IBAction)lineFieldChanged:(id)sender {
    NSError *error;
    if ([@"" isEqual:[sender stringValue]]) return;	// Don't do anything on empty string
    if ([self selectLinesUsingDescription:[sender stringValue] error:&error]) {
	[[self window] orderOut:nil];
    } else {
	[[self window] presentError:error];
	[[self window] makeKeyAndOrderFront:nil];
    }
}

/* Default action for the "Select" button.
*/
- (IBAction)selectClicked:(id)sender {
    NSError *error;
    if ([@"" isEqual:[lineField stringValue]]) return;	// Don't do anything on empty string
    if (![self selectLinesUsingDescription:[lineField stringValue] error:&error]) {
	[[self window] presentError:error];
	[[self window] makeKeyAndOrderFront:nil];
    }
}

-(void) setLineNumberFromRange:(NSRange) someRange inView: target
{	if (lineField && [target isKindOfClass:[NSTextView class]] && ![target isFieldEditor])
	{	NSRange range = [self TE_lineNumberRangeFromCharacterRange: someRange inString: [target string]];
		[lineField setStringValue:rangeSpecificationFromRange(range) ]; //rangeSpecificationFromRange(someRange)
	}
}

///////////////////////////////////////////////////
// TEGotoPanelController.m
// TextExtras
//
// Copyright © 1996-2006, Mike Ferris.
// All rights reserved.


// A range specification is either a single integer or two colon-separated integers indicating first and last elements in a range.
// A range specification is assumed to be "1" based and inclusive.  So the range specification "1:3" will translate to units 1, 2, and 3, or range {0, 3}.  The range specification "5" will be returned as {4, 1}.

static NSString *rangeSpecificationFromRange(NSRange range) {
    // Given a range, produce a range specification.
    if (range.length < 2) {
        return [NSString stringWithFormat:@"%lu", (range.location + 1)];
    } else {
        return [NSString stringWithFormat:@"%lu:%lu", (range.location + 1), NSMaxRange(range)];  // NSMaxRange(range) is already one bigger than it should be so we don't need to adjust it.
    }
}

static NSRange rangeFromRangeSpecification(NSString *rangeSpec) {
    // Given a range specification (a string containing either a single number or two numbers separated by a colon), return a range.
    NSScanner *scanner = [NSScanner localizedScannerWithString:rangeSpec];
    NSRange range;
    unsigned endLoc;
	
    if (![scanner scanInt:(int *)(&(range.location))]) {
        return NSMakeRange(NSNotFound, 0);
    }
    if ([scanner isAtEnd]) {
        range.location--;
        range.length = 1;
        return range;
    }
	
    if (![scanner scanString:@":" intoString:NULL] || ![scanner scanInt:(int *)(&(endLoc))]) {
        return NSMakeRange(NSNotFound, 0);
    }
	
    range.length = (endLoc + 1) - range.location;
    range.location--;
    return range;
}

#define UNICHAR_BUFF_SIZE 1024

- (NSRange)TE_characterRangeForLineNumberRange:(NSRange)lineNumRange inString:(NSString *)string {
    unsigned stopLineNum = NSMaxRange(lineNumRange);
    unsigned curLineNum = 0;
    unsigned startCharIndex = NSNotFound;
    unichar buff[UNICHAR_BUFF_SIZE];
    unsigned i, buffCount;
    NSRange searchRange = NSMakeRange(0, [string length]);
	
    // Returned char range should start at beginning of line number lineNumRange.location and end at beginning of line number stopLineNum.
    if (lineNumRange.location == 0) {
        // Check for this case first since the loop won't.
        startCharIndex = 0;
    }
    while (searchRange.length > 0) {
        buffCount = ((searchRange.length > UNICHAR_BUFF_SIZE) ? UNICHAR_BUFF_SIZE : searchRange.length);
        [string getCharacters:buff range:NSMakeRange(searchRange.location, buffCount)];
        for (i=0; i<buffCount; i++) {
            // We're counting paragraph separators here.  We want to notice when we hit lineNumRange.location and remember where the starting char index is.  We also want to notice when we reach the stopLineNum and return the result.
            if (TE_IsHardLineBreakUnichar(buff[i], string, searchRange.location + i)) {
                curLineNum++;
                if (curLineNum == lineNumRange.location) {
                    // The next line is the first line we need.
                    startCharIndex = searchRange.location + i + 1;
                }
                if (curLineNum == stopLineNum) {
                    return NSMakeRange(startCharIndex, (searchRange.location + i + 1) - startCharIndex);
                }
            }
        }
        // Skip the search range past the part we just did.
        searchRange.location += buffCount;
        searchRange.length -= buffCount;
    }
	
    // If we're here, we didn't find the end of the line number range.
    // searchRange.location == [string length] at this point.
    if (startCharIndex == NSNotFound) {
        // We didn't find the start of the line number range either, so return {EOT, 0}.
		return NSMakeRange(searchRange.location, 0);
    } else {
        // We found the start, so return from there to the end of the text.
        return NSMakeRange(startCharIndex, searchRange.location - startCharIndex);
    }
}

- (NSRange)TE_lineNumberRangeFromCharacterRange:(NSRange )charRange inString:(NSString *)string {
    unsigned stopCharIndex = NSMaxRange(charRange);
    unsigned curLineNum = 0;
    unsigned startLineNum = NSNotFound;
    unichar buff[UNICHAR_BUFF_SIZE];
    unsigned i, buffCount;
    NSRange searchRange = NSMakeRange(0, [string length]);
	
    while (searchRange.length > 0) {
        buffCount = ((searchRange.length > UNICHAR_BUFF_SIZE) ? UNICHAR_BUFF_SIZE : searchRange.length);
        [string getCharacters:buff range:NSMakeRange(searchRange.location, buffCount)];
        for (i=0; i<buffCount; i++) {
            // We're counting paragraph separators here.  We want to notice when we hit charRange.location and remember what the line number is.  We also want to notice when we reach the stopCharIndex and return the result.
            if (charRange.location == searchRange.location + i) {
                startLineNum = curLineNum;
                if (stopCharIndex == charRange.location) {
                    return NSMakeRange(startLineNum, 1);
                }
            }
            if (stopCharIndex == searchRange.location + i) {
                unsigned stopLineNum;
                if ((searchRange.location + i > 0) && TE_IsHardLineBreakUnichar([string characterAtIndex:searchRange.location + i - 1], string, searchRange.location + i - 1)) {
                    stopLineNum = curLineNum;
                } else {
                    stopLineNum = curLineNum + 1;
                }
                return NSMakeRange(startLineNum, stopLineNum - startLineNum);
            }
            if (TE_IsHardLineBreakUnichar(buff[i], string, searchRange.location + i)) {
                curLineNum++;
            }
        }
        // Skip the search range past the part we just did.
        searchRange.location += buffCount;
        searchRange.length -= buffCount;
    }
	
    // If we're here, we didn't find the end of the line number range.
    // curLineNum == number of last line at this point.
    if (startLineNum == NSNotFound) {
        // We didn't find the start of the line number range either, so return {EOT, 0}.
        return NSMakeRange(curLineNum, 0);
    } else {
        // We found the start, so return from there to the end of the text.
        unsigned stopLineNum;
        if ((searchRange.location > 0) && TE_IsHardLineBreakUnichar([string characterAtIndex:searchRange.location - 1], string, searchRange.location - 1)) {
            stopLineNum = curLineNum;
        } else {
            stopLineNum = curLineNum + 1;
        }
        return NSMakeRange(startLineNum, stopLineNum - startLineNum);
    }
}

@end
