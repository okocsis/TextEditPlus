// TEFoundationExtras.m
// TextExtras
//
// Copyright © 1996-2006, Mike Ferris.
// All rights reserved.

#import "TEFoundationExtras.h"

@implementation NSString (TEFoundationExtras)

- (NSString *)TE_stringByReplacingBackslashWithSlash {
    NSMutableString *newStr = [self mutableCopy];
    NSRange searchRange, foundRange;

    searchRange = NSMakeRange(0, [self length]);
    while ((searchRange.length > 0) && ((foundRange = [newStr rangeOfString:@"\\" options:NSLiteralSearch range:searchRange]).length > 0)) {
        [newStr replaceCharactersInRange:foundRange withString:@"/"];
        searchRange = NSMakeRange(NSMaxRange(foundRange), NSMaxRange(searchRange) - NSMaxRange(foundRange));
    }

    return [newStr autorelease];
}

@end

@implementation NSMutableString (TEFoundationExtras)

static void standardizeEndOfLineInString(NSMutableString *str, NSString *newEOL) {
    // This function works by replacing ParagraphSeparator, CRLF, CR, or LF with newEOL.  Note that CRLF is replaced by a single newEOL.
    unsigned newEOLLen;
    unichar newEOLStackBuf[2];
    unichar *newEOLBuf;
    BOOL freeNewEOLBuf = NO;

    unsigned length = [str length];
    unsigned curPos = 0;
    unsigned start, end, contentsEnd;


    newEOLLen = [newEOL length];
    if (newEOLLen > 2) {
        newEOLBuf = NSZoneMalloc(NULL, sizeof(unichar) * newEOLLen);
        freeNewEOLBuf = YES;
    } else {
        newEOLBuf = newEOLStackBuf;
    }
    [newEOL getCharacters:newEOLBuf];

    while (curPos < length) {
        [str getLineStart:&start end:&end contentsEnd:&contentsEnd forRange:NSMakeRange(curPos, 1)];
        if (contentsEnd < end) {
            int changeInLength = newEOLLen - (end - contentsEnd);
            BOOL alreadyNewEOL = YES;
            if (changeInLength == 0) {
                unsigned i;
                for (i=0; i<newEOLLen; i++) {
                    // Multiple characterAtIndex: calls may be expensive.  But for any normal case, it will be called either one or two times only.  Still, it probably ought to be meaured whether it is faster to just do the no-op replace instead of detecting it and avoiding it.
                    if ([str characterAtIndex:contentsEnd+i] != newEOLBuf[i]) {
                        alreadyNewEOL = NO;
                        break;
                    }
                }
            } else {
                alreadyNewEOL = NO;
            }
            if (!alreadyNewEOL) {
                [str replaceCharactersInRange:NSMakeRange(contentsEnd, end - contentsEnd) withString:newEOL];
                end += changeInLength;
                length += changeInLength;
            }
        }
        curPos = end;
    }

    if (freeNewEOLBuf) {
        NSZoneFree(NSZoneFromPointer(newEOLBuf), newEOLBuf);
    }
}

- (void)TE_standardizeEndOfLineToLF {
    standardizeEndOfLineInString(self, @"\n");
}

- (void)TE_standardizeEndOfLineToCRLF {
    standardizeEndOfLineInString(self, @"\r\n");
}

- (void)TE_standardizeEndOfLineToCR {
    standardizeEndOfLineInString(self, @"\r");
}

- (void)TE_standardizeEndOfLineToParagraphSeparator {
    unichar paragraphSeparator[1];

    paragraphSeparator[0] = NSParagraphSeparatorCharacter;

    standardizeEndOfLineInString(self, [NSString stringWithCharacters:paragraphSeparator length:1]);
}

- (void)TE_standardizeEndOfLineToLineSeparator {
    unichar lineSeparator[1];

    lineSeparator[0] = NSLineSeparatorCharacter;

    standardizeEndOfLineInString(self, [NSString stringWithCharacters:lineSeparator length:1]);
}

@end

@implementation NSArray (TEFoundationExtras)

- (NSString *)TE_longestCommonPrefixForStrings {
    unsigned charIndex = 0;
    unsigned i, c;
    NSString *curString;
    unichar curChar = 0;
    BOOL done = NO;

    if ((c = [self count]) == 0) {
        return @"";
    }
    if (c == 1) {
        return [self objectAtIndex:0];
    }
    while (1) {
        for (i=0; i<c; i++) {
            curString = [self objectAtIndex:i];
            if (charIndex < [curString length]) {
                if (i==0) {
                    curChar = [curString characterAtIndex:charIndex];
                } else {
                    if (curChar != [curString characterAtIndex:charIndex]) {
                        done = YES;
                        break;
                    }
                }
            } else {
                done = YES;
                break;
            }
        }
        if (done) {
            break;
        }
        charIndex++;
    }
    // charIndex is one past the end of the common prefix all the strings share
    return ((charIndex > 0) ? [[self objectAtIndex:0] substringWithRange:NSMakeRange(0, charIndex)] : @"");
}

@end
