// NSTextView_TETextExtras.m
// TextExtras
//
// Copyright © 1996-2006, Mike Ferris.
// All rights reserved.

#import "NSTextView_TETextExtras.h"
#import "TETextUtils.h"
#import "TEFoundationExtras.h"

#define USES_TABS YES
#define TAB_WIDTH 4
#define INDENT_WIDTH 4

static BOOL _subclassOverridesSelector(Class subclass, Class baseClass, SEL selector);
    // Implemented at the bottom of this file.  Returns YES if the given selector is overridden for the given subclass relative to the given baseClass (or an intervening ancestor of it).

@interface NSLayoutManager (TEPrivatesOnParade)

// MF: Shhh... don't tell anyone about these private methods.  If they stop working, tough luck.
- (NSString *)_containerDescription;
- (NSString *)_lineFragmentDescription:(BOOL)verboseFlag;
- (NSString *)_glyphDescription;

@end

@implementation NSTextView (TETextExtras)

// MF: The ugliness of most of the method names in this category are because the base class and all categories share a namespace for their methods.  All the methods in this category that are prefixed with TE_ are done that way to avoid conflicting with another method in another category (I mean, who else would have such ugly method names?)  There are exceptions.  Category methods without prefixes are inherently unwise in a loadable bundle situation like this.  Where there are exceptions the overriding reasons for them are explained.

// ********************** Nest/Unnest feature **********************

- (void)TE_doUserIndentByNumberOfLevels:(int)levels {
    // Because of the way paragraph ranges work we will add spaces a final paragraph separator only if the selection is an insertion point at the end of the text.
    // We ask for rangeForUserTextChange and extend it to paragraph boundaries instead of asking rangeForUserParagraphAttributeChange because this is not an attribute change and we don't want it to be affected by the usesRuler setting.
    NSRange charRange = [[self string] lineRangeForRange:[self rangeForUserTextChange]];
    NSRange selRange = [self selectedRange];
    if (charRange.location != NSNotFound) {
        NSTextStorage *textStorage = [self textStorage];
        NSAttributedString *newText;
        unsigned tabWidth = TAB_WIDTH;
        unsigned indentWidth = INDENT_WIDTH;
        BOOL usesTabs = USES_TABS;

        selRange.location -= charRange.location;
        newText = TE_attributedStringByIndentingParagraphs([textStorage attributedSubstringFromRange:charRange], levels,  &selRange, [self typingAttributes], tabWidth, indentWidth, usesTabs);
        selRange.location += charRange.location;
        if ([self shouldChangeTextInRange:charRange replacementString:[newText string]]) {
            [textStorage replaceCharactersInRange:charRange withAttributedString:newText];
            [self setSelectedRange:selRange];
            [self didChangeText];
        }
    }
}

- (IBAction)TE_indentRight:(id)sender {
    [self TE_doUserIndentByNumberOfLevels:1];
}

- (IBAction)TE_indentLeft:(id)sender {
    [self TE_doUserIndentByNumberOfLevels:-1];
}


- (void)TE_standardizeEndOfLineToLF:(id)sender {
    NSTextStorage *textStorage = [self textStorage];
    NSMutableString *str = [textStorage mutableString];
    NSRange charRange = NSMakeRange(0, [str length]);
    
    if ([self shouldChangeTextInRange:charRange replacementString:nil]) {
        // -TE_standardizeEndOfLineToLF might do many separate edits, so turn on the batching in textStorage here.
        [textStorage beginEditing];
        [str TE_standardizeEndOfLineToLF];
        [textStorage endEditing];
        [self didChangeText];
    }
}

- (void)TE_standardizeEndOfLineToCRLF:(id)sender {
    NSTextStorage *textStorage = [self textStorage];
    NSMutableString *str = [textStorage mutableString];
    NSRange charRange = NSMakeRange(0, [str length]);

    if ([self shouldChangeTextInRange:charRange replacementString:nil]) {
        // -TE_standardizeEndOfLineToCRLF might do many separate edits, so turn on the batching in textStorage here.
        [textStorage beginEditing];
        [str TE_standardizeEndOfLineToCRLF];
        [textStorage endEditing];
        [self didChangeText];
    }
}

- (void)TE_standardizeEndOfLineToCR:(id)sender {
    NSTextStorage *textStorage = [self textStorage];
    NSMutableString *str = [textStorage mutableString];
    NSRange charRange = NSMakeRange(0, [str length]);

    if ([self shouldChangeTextInRange:charRange replacementString:nil]) {
        // -TE_standardizeEndOfLineToCR might do many separate edits, so turn on the batching in textStorage here.
        [textStorage beginEditing];
        [str TE_standardizeEndOfLineToCR];
        [textStorage endEditing];
        [self didChangeText];
    }
}

- (void)TE_standardizeEndOfLineToParagraphSeparator:(id)sender {
    NSTextStorage *textStorage = [self textStorage];
    NSMutableString *str = [textStorage mutableString];
    NSRange charRange = NSMakeRange(0, [str length]);

    if ([self shouldChangeTextInRange:charRange replacementString:nil]) {
        // -TE_standardizeEndOfLineToParagraphSeparator might do many separate edits, so turn on the batching in textStorage here.
        [textStorage beginEditing];
        [str TE_standardizeEndOfLineToParagraphSeparator];
        [textStorage endEditing];
        [self didChangeText];
    }
}

- (void)TE_standardizeEndOfLineToLineSeparator:(id)sender {
    NSTextStorage *textStorage = [self textStorage];
    NSMutableString *str = [textStorage mutableString];
    NSRange charRange = NSMakeRange(0, [str length]);

    if ([self shouldChangeTextInRange:charRange replacementString:nil]) {
        // -TE_standardizeEndOfLineToLineSeparator might do many separate edits, so turn on the batching in textStorage here.
        [textStorage beginEditing];
        [str TE_standardizeEndOfLineToLineSeparator];
        [textStorage endEditing];
        [self didChangeText];
    }
}

- (void)TE_insertCRLF:(id)sender {
    if (_subclassOverridesSelector([self class], [NSTextView class], @selector(insertNewline:))) {
        // Some text system clients do special things when they see insertNewline:.  If the receiver is a subclass that has an overridden version of insertNewline:, call that.
        [self insertNewline:sender];
        return;
    } else if ([[self delegate] respondsToSelector:@selector(textView:doCommandBySelector:)]) {
        // If the delegate wants a crack at command selectors, give it a crack at the standard selector too.
        if ([[self delegate] textView:self doCommandBySelector:@selector(insertNewline:)]) {
            return;
        }
    }
    if ([self isFieldEditor]) {
        // Field editors needs to do something special with newlines, and we don't know how.  Let insertNewline handle it, because it does know how.
        [self insertNewline:self];
    } else {
        [self insertText:@"\r\n"];
    }
}

- (void)TE_insertCR:(id)sender {
    if (_subclassOverridesSelector([self class], [NSTextView class], @selector(insertNewline:))) {
        // Some text system clients do special things when they see insertNewline:.  If the receiver is a subclass that has an overridden version of insertNewline:, call that.
        [self insertNewline:sender];
        return;
    } else if ([[self delegate] respondsToSelector:@selector(textView:doCommandBySelector:)]) {
        // If the delegate wants a crack at command selectors, give it a crack at the standard selector too.
        if ([[self delegate] textView:self doCommandBySelector:@selector(insertNewline:)]) {
            return;
        }
    }
    if ([self isFieldEditor]) {
        // Field editors needs to do something special with newlines, and we don't know how.  Let insertNewline handle it, because it does know how.
        [self insertNewline:self];
    } else {
        [self insertText:@"\r"];
    }
}

- (void)TE_insertLineSeparator:(id)sender {
    if (_subclassOverridesSelector([self class], [NSTextView class], @selector(insertNewline:))) {
        // Some text system clients do special things when they see insertNewline:.  If the receiver is a subclass that has an overridden version of insertNewline:, call that.
        [self insertNewline:sender];
        return;
    } else if ([[self delegate] respondsToSelector:@selector(textView:doCommandBySelector:)]) {
        // If the delegate wants a crack at command selectors, give it a crack at the standard selector too.
        if ([[self delegate] textView:self doCommandBySelector:@selector(insertNewline:)]) {
            return;
        }
    }
    if ([self isFieldEditor]) {
        // Field editors needs to do something special with newlines, and we don't know how.  Let insertNewline handle it, because it does know how.
        [self insertNewline:self];
    } else {
        unichar lineSeparator[1];

        lineSeparator[0] = NSLineSeparatorCharacter;

        [self insertText:[NSString stringWithCharacters:lineSeparator length:1]];
    }
}

- (void)TE_indentFriendlyDeleteBackward:(id)sender {
    if (_subclassOverridesSelector([self class], [NSTextView class], @selector(deleteBackward:))) {
        // Some text system clients do special things when they see deleteBackward:.  If the receiver is a subclass that has an overridden version of deleteBackward:, call that.
        [self deleteBackward:sender];
        return;
    } else if ([[self delegate] respondsToSelector:@selector(textView:doCommandBySelector:)]) {
        // If the delegate wants a crack at command selectors, give it a crack at the standard selector too.
        if ([[self delegate] textView:self doCommandBySelector:@selector(deleteBackward:)]) {
            return;
        }
    }
    if ([self isRichText]) {
        // This is not appropriate for rich text.
        [self deleteBackward:sender];
    } else {
        NSRange charRange = [self rangeForUserTextChange];
        if (charRange.location != NSNotFound) {
            if (charRange.length > 0) {
                // Non-zero selection.  Delete normally.
                [self deleteBackward:sender];
            } else {
                if (charRange.location == 0) {
                    // At beginning of text.  Delete normally.
                    [self deleteBackward:sender];
                } else {
                    NSString *string = [self string];
                    NSRange paraRange = [string lineRangeForRange:NSMakeRange(charRange.location - 1, 1)];
                    if (paraRange.location == charRange.location) {
                        // At beginning of line.  Delete normally.
                        [self deleteBackward:sender];
                    } else {
                        unsigned tabWidth = TAB_WIDTH;
                        unsigned indentWidth = INDENT_WIDTH;
                        BOOL usesTabs = USES_TABS;
                        NSRange leadingSpaceRange = paraRange;
                        unsigned leadingSpaces = TE_numberOfLeadingSpacesFromRangeInString(string, &leadingSpaceRange, tabWidth);

                        if (charRange.location > NSMaxRange(leadingSpaceRange)) {
                            // Not in leading whitespace.  Delete normally.
                            [self deleteBackward:sender];
                        } else {
                            NSTextStorage *text = [self textStorage];
                            unsigned leadingIndents = leadingSpaces / indentWidth;
                            NSString *replaceString;

                            // If we were indented to an fractional level just go back to the last even multiple of indentWidth, if we were exactly on, go back a full level.
                            if (leadingSpaces % indentWidth == 0) {
                                leadingIndents--;
                            }
                            leadingSpaces = leadingIndents * indentWidth;
                            replaceString = ((leadingSpaces > 0) ? TE_tabbifiedStringWithNumberOfSpaces(leadingSpaces, tabWidth, usesTabs) : @"");
                            if ([self shouldChangeTextInRange:leadingSpaceRange replacementString:replaceString]) {
                                NSDictionary *newTypingAttributes;
                                if (charRange.location < [string length]) {
                                    newTypingAttributes = [[text attributesAtIndex:charRange.location effectiveRange:NULL] retain];
                                } else {
                                    newTypingAttributes = [[text attributesAtIndex:(charRange.location - 1) effectiveRange:NULL] retain];
                                }

                                [text replaceCharactersInRange:leadingSpaceRange withString:replaceString];

                                [self setTypingAttributes:newTypingAttributes];
                                [newTypingAttributes release];

                                [self didChangeText];
                            }
                        }
                    }
                }
            }
        }
    }
}

static NSRange TEIntersectionRange(NSRange r1, NSRange r2) {
    // This is different from NSIntersectionRange() in its handling of zero-length ranges.  This does what I consider to make sense while Foundation kind of punts and tends to return 0, 0 for zero-length inputs sometimes.  It returns NSNotFound, 0 when there is no intersection also, where Foundation returns 0, 0.
    unsigned max1 = NSMaxRange(r1);
    unsigned max2 = NSMaxRange(r2);
    unsigned smallestMax = ((max1 < max2) ? max1 : max2);
    unsigned biggestMin = ((r1.location > r2.location) ? r1.location : r2.location);

    if (smallestMax < biggestMin) {
        // No intersection
        return NSMakeRange(NSNotFound, 0);
    } else {
        return NSMakeRange(biggestMin, smallestMax - biggestMin);
    }
}

- (void)TE_indentFriendlyInsertTab:(id)sender {
    if (_subclassOverridesSelector([self class], [NSTextView class], @selector(insertTab:))) {
        // Some text system clients do special things when they see insertTab:.  If the receiver is a subclass that has an overridden version of insertTab:, call that.
        [self insertTab:sender];
        return;
    } else if ([[self delegate] respondsToSelector:@selector(textView:doCommandBySelector:)]) {
        // If the delegate wants a crack at command selectors, give it a crack at the standard selector too.
        if ([[self delegate] textView:self doCommandBySelector:@selector(insertTab:)]) {
            return;
        }
    }
    if ([self isRichText] || [self isFieldEditor]) {
        // This is not appropriate for rich text or field editors.
        [self insertTab:sender];
    } else {
        NSRange charRange = [self rangeForUserTextChange];
        if (charRange.location != NSNotFound) {
            NSString *string = [self string];
            unsigned stringLen = [string length];
            NSRange paraRange, leadingSpaceRange;
            unsigned tabWidth = TAB_WIDTH;
            unsigned indentWidth = INDENT_WIDTH;
            BOOL usesTabs = USES_TABS;
            unsigned leadingSpaces;
            
            // Find range of paragraph where selection starts
            if (charRange.location < stringLen) {
                paraRange = [string lineRangeForRange:NSMakeRange(charRange.location, 1)];
            } else {
                if (charRange.location == 0) {
                    // Empty text.
                    paraRange = NSMakeRange(0, 0);
                } else {
                    // At end of text.
                    if (TE_IsParagraphSeparator([string characterAtIndex:charRange.location - 1], string, charRange.location - 1)) {
                        // Extra line frag
                        paraRange = NSMakeRange(charRange.location, 0);
                    } else {
                        // End of last line
                        paraRange = [string lineRangeForRange:NSMakeRange(charRange.location - 1, 1)];
                    }
                }
            }
            // Find the range of leading whitespace for the paragraph we are in.
            leadingSpaceRange = paraRange;
            leadingSpaces = TE_numberOfLeadingSpacesFromRangeInString(string, &leadingSpaceRange, tabWidth);
            
            // Now, see if the selection range is totally inside the leading whitespace
            if (!NSEqualRanges(charRange, TEIntersectionRange(charRange, leadingSpaceRange))) {
                // Range was not entirely in whitespace.
                [self insertTab:sender];
            } else {
                NSTextStorage *text = [self textStorage];
                unsigned leadingIndents = leadingSpaces / indentWidth;
                NSString *replaceString;

                leadingIndents++;  // This will go forward to the next level even if we had a partial level to begin with.
                leadingSpaces = leadingIndents * indentWidth;
                replaceString = ((leadingSpaces > 0) ? TE_tabbifiedStringWithNumberOfSpaces(leadingSpaces, tabWidth, usesTabs) : @"");
                if ([self shouldChangeTextInRange:leadingSpaceRange replacementString:replaceString]) {
                    [text beginEditing];
                    [text replaceCharactersInRange:leadingSpaceRange withString:replaceString];
                    [text setAttributes:[self typingAttributes] range:NSMakeRange(leadingSpaceRange.location, [replaceString length])];
                    [text endEditing];

                    [self didChangeText];
                }
            }
        }
    }
}

- (void)TE_reindentWrappedLines:(id)sender {
    NSTextStorage *text = [self textStorage];
    unsigned textLength = ((text != nil) ? [text length] : 0);

    if ((textLength == 0) || [self isRichText] || [self isFieldEditor]) {
        // Forget it.
        return;
    }
    // Just tickle the text storage to trick it into fixing attributes and notifying everybody.
    [text beginEditing];
    [text edited:NSTextStorageEditedCharacters range:NSMakeRange(0, textLength) changeInLength:0];
    [text endEditing];
}

- (NSRange)TE_rangeOfLineWithSameOrSmallerIndentSearchingBackwards:(BOOL)backwardsFlag {
    NSRange charRange = [[self string] lineRangeForRange:[self selectedRange]];
    NSRange tempRange = charRange;
    unsigned tabWidth = TAB_WIDTH;
    unsigned leadingSpaces = TE_numberOfLeadingSpacesFromRangeInString([self string], &tempRange, tabWidth);

    // Bump it up by one so we can do a less-than-or-equal search
    leadingSpaces++;
    charRange = TE_rangeOfLineWithLeadingWhiteSpace([self string], charRange, leadingSpaces, NSOrderedDescending, backwardsFlag, tabWidth);
    return charRange;
}

- (void)TE_selectNextLineWithSameOrSmallerIndent:(id)sender {
    NSRange newRange = [self TE_rangeOfLineWithSameOrSmallerIndentSearchingBackwards:NO];
    [self setSelectedRange:newRange];
    [self scrollRangeToVisible:newRange];
}

- (void)TE_selectToNextLineWithSameOrSmallerIndent:(id)sender {
    NSRange charRange = [[self string] lineRangeForRange:[self selectedRange]];
    NSRange newRange = [self TE_rangeOfLineWithSameOrSmallerIndentSearchingBackwards:NO];

    [self setSelectedRange:NSMakeRange(charRange.location, newRange.location - charRange.location)];
    [self scrollRangeToVisible:NSMakeRange(NSMaxRange(newRange), 0)];
}

- (void)TE_selectPreviousLineWithSameOrSmallerIndent:(id)sender {
    NSRange newRange = [self TE_rangeOfLineWithSameOrSmallerIndentSearchingBackwards:YES];
    [self setSelectedRange:newRange];
    [self scrollRangeToVisible:newRange];
}

- (void)TE_selectToPreviousLineWithSameOrSmallerIndent:(id)sender {
    NSRange charRange = [[self string] lineRangeForRange:[self selectedRange]];
    NSRange newRange = [self TE_rangeOfLineWithSameOrSmallerIndentSearchingBackwards:YES];

    [self setSelectedRange:NSMakeRange(newRange.location, charRange.location - newRange.location)];
    [self scrollRangeToVisible:NSMakeRange(newRange.location, 0)];
}

- (IBAction)TE_toggleShowsNonAsciiCharacters:(id)sender {
    [[self textStorage] TE_setShowsNonAsciiCharacters:![[self textStorage] TE_showsNonAsciiCharacters]];
    [self TE_reindentWrappedLines:self];
}

@end

@implementation NSResponder (TETextExtras)

// This NSResponder category implements the various selectors that we add to NSTextView that are often used to replace standard key bindings like -insertNewline:.  These implementations all simply call the standard method they are a replacement for (if it is implemented).

- (void)TE_responderImplementationForSelector:(SEL)realSelector standardSelector:(SEL)standardSelector sender:(id)sender {
    if ([self respondsToSelector:standardSelector]) {
        [self performSelector:standardSelector withObject:sender];
    } else {
        // Pass it up the chain
        [[self nextResponder] doCommandBySelector:realSelector];
    }
}

// Replacement methods for insertNewline:
- (void)TE_insertNewlineAndIndent:(id)sender {
    [self TE_responderImplementationForSelector:_cmd standardSelector:@selector(insertNewline:) sender:sender];
}

- (void)TE_insertCRLFAndIndent:(id)sender {
    [self TE_responderImplementationForSelector:_cmd standardSelector:@selector(insertNewline:) sender:sender];
}

- (void)TE_insertCRAndIndent:(id)sender {
    [self TE_responderImplementationForSelector:_cmd standardSelector:@selector(insertNewline:) sender:sender];
}

- (void)TE_insertParagraphSeparatorAndIndent:(id)sender {
    [self TE_responderImplementationForSelector:_cmd standardSelector:@selector(insertNewline:) sender:sender];
}

- (void)TE_insertLineSeparatorAndIndent:(id)sender {
    [self TE_responderImplementationForSelector:_cmd standardSelector:@selector(insertNewline:) sender:sender];
}

- (void)TE_insertCRLF:(id)sender {
    [self TE_responderImplementationForSelector:_cmd standardSelector:@selector(insertNewline:) sender:sender];
}

- (void)TE_insertCR:(id)sender {
    [self TE_responderImplementationForSelector:_cmd standardSelector:@selector(insertNewline:) sender:sender];
}

- (void)TE_insertLineSeparator:(id)sender {
    [self TE_responderImplementationForSelector:_cmd standardSelector:@selector(insertNewline:) sender:sender];
}

// Replacement method for deleteBackward:
- (void)TE_indentFriendlyDeleteBackward:(id)sender {
    [self TE_responderImplementationForSelector:_cmd standardSelector:@selector(deleteBackward:) sender:sender];
}

// Replacement method for insertTab:
- (void)TE_indentFriendlyInsertTab:(id)sender {
    [self TE_responderImplementationForSelector:_cmd standardSelector:@selector(insertTab:) sender:sender];
}

@end


#import <objc/objc-class.h>

static BOOL _subclassOverridesSelector(Class subclass, Class baseClass, SEL selector) {
    // This function returns YES if the given selector has different implementations for subclass and baseClass.  In other words, it returns whether, somewhere between baseClass and subclass, the given selector was overridden.
    Method baseMethod;
    Method subclassMethod;

    baseMethod = class_getInstanceMethod(baseClass, selector);
    subclassMethod = class_getInstanceMethod(subclass, selector);
   // return ((baseMethod->method_imp == subclassMethod->method_imp) ? NO : YES);
	return NO;
}
