// NSTextView_TETextExtras.h
// TextExtras
//
// Copyright © 1996-2006, Mike Ferris.
// All rights reserved.

// The TabWidth and IndentWidth defaults: several of the features provided make use of these two defaults.  The TabWidth default is actually used by TextEdit as well.  Basically these defaults determine the number of spaces in a tab and the number of spaces in an indent level.  The default values are 8 for TabWidth and 4 for IndentWidth.
// The TryToInstallExtrasMenu default controls whether the category will actually attempt to insert a new menu into the Format menu.  If YES, it tries to find the Format menu and, if there is a Text menu it puts the new menu below it, otherwise it puts it at the end of the Format menu.  If it can't find the Format menu it gives up.  The menu provides commands for nest/unnest, and bringing up the goto panel.

#import <Cocoa/Cocoa.h>

@interface NSTextView (TETextExtras)

- (IBAction)TE_indentRight:(id)sender;
- (IBAction)TE_indentLeft:(id)sender;
    // These two actions add (indentRight:) or subtract (indentLeft:) IndentWidth spaces from the beginning of each line included (even partially) in the selection.  The resulting leading whitespace in each line is always minimized by using as many tabs as possible (given the TabWidth) and filling the remainder with spaces.  This feature has a simple-minded notion of leading whitespace (' ' and '\t' only).

- (void)TE_insertNewlineAndIndent:(id)sender;
- (void)TE_insertCRLFAndIndent:(id)sender;
- (void)TE_insertCRAndIndent:(id)sender;
- (void)TE_insertParagraphSeparatorAndIndent:(id)sender;
- (void)TE_insertLineSeparatorAndIndent:(id)sender;
 // This is like insertNewline: (or TE_insertCRLF:, etc...) but after the newline (or whatever line ending it is) it also inserts enough whitespace to match the leading whitespace of the previous line.  The resulting leading whitespace in each line is always minimized by using as many tabs as possible (given the TabWidth) and filling the remainder with spaces.  This feature has a simple-minded notion of leading whitespace (' ' and '\t' only).

- (void)TE_gotoPanel:(id)sender;
    // Allows access to the goto panel provided by TEGotoPanelController.  This just brings up the panel and selects the text field so you can type a line or character number and hit return.  This is useful to bind if the TextExtras menu is set not to always install itself.

- (void)TE_preferencesPanel:(id)sender;
    // Allows access to the preferences panel provided by TEPreferencesController.  This is useful to bind if the TextExtras menu is set not to always install itself.

- (void)TE_specialCharactersPanel:(id)sender;
    // Allows access to the special characters panel provided by TESpecialCharactersController.  This is useful to bind if the TextExtras menu is set not to always install itself.

- (void)TE_openQuickly:(id)sender;
    // Allows access to the open quickly panel provided by TEOpenQuicklyController.  This is useful to bind if the TextExtras menu is set not to always install itself.

- (void)TE_executePipe:(id)sender;
    // Brings up the pipe panel.

- (void)TE_executeSelectionAppendingOutput:(id)sender;
- (void)TE_executeSelectionInsertingOutput:(id)sender;
- (void)TE_executeSelectionSendingOutputToPasteboard:(id)sender;
    // These create a user pipe using the selection as the script.  The command has no stdin data and stdout goes to various places for the different methods.

- (void)TE_complete:(id)sender;
- (NSRange)TE_replacementRangeAfterReplacingCharactersInRange:(NSRange)replacementRange withCompletionText:(NSString *)string;

// Debugging utilities
- (void)TE_logTextViewDescriptions:(id)sender;
- (void)TE_logTextContainerDescriptions:(id)sender;
- (void)TE_logLayoutManagerDescription:(id)sender;
- (void)TE_logLayoutManagerContainerDescription:(id)sender;
- (void)TE_logLayoutManagerLineFragmentDescription:(id)sender;
- (void)TE_logLayoutManagerVerboseLineFragmentDescription:(id)sender;
- (void)TE_logLayoutManagerGlyphDescription:(id)sender;
- (void)TE_logTextStorageDescription:(id)sender;

// Control character and end of line stuff
- (void)TE_toggleShowsControlCharacters:(id)sender;
    // Toggles the showsControlCharacters setting for the view's layout manager.

- (void)TE_parseSelectionAsPropertyList:(id)sender;
- (void)TE_parseFileAsPropertyList:(id)sender;
- (void)TE_convertSelectionToXMLPropertyList:(id)sender;
- (void)TE_convertFileToXMLPropertyList:(id)sender;
- (void)TE_convertSelectionToASCIIPropertyList:(id)sender;
- (void)TE_convertFileToASCIIPropertyList:(id)sender;

- (void)TE_standardizeEndOfLineToLF:(id)sender;
- (void)TE_standardizeEndOfLineToCRLF:(id)sender;
- (void)TE_standardizeEndOfLineToCR:(id)sender;
- (void)TE_standardizeEndOfLineToParagraphSeparator:(id)sender;
- (void)TE_standardizeEndOfLineToLineSeparator:(id)sender;
    // Standardize ends of lines.

- (void)TE_insertCRLF:(id)sender;
- (void)TE_insertCR:(id)sender;
- (void)TE_insertLineSeparator:(id)sender;
    // Just like insertNewline: and insertParagraphSeparator: except it inserts different end of line sequences.

- (void)TE_indentFriendlyDeleteBackward:(id)sender;
    // Deletes whitespace at the beginning of a line by IndentWidth.  Same as deleteBackward: when not in the leading whitespace.

- (void)TE_reindentWrappedLines:(id)sender;
    // This really just tweaks the text storage making it think the whole text was edited.  Expensive, but this is a sledge hammer kind of solution to your problems.

- (void)TE_indentFriendlyInsertTab:(id)sender;
    // If selection is in leading whitespace this inserts spaces and or tabs as appropriate to indent by one more indent width.  Same as insertTab: when not in leading whitespace.

- (void)TE_selectNextLineWithSameOrSmallerIndent:(id)sender;
- (void)TE_selectToNextLineWithSameOrSmallerIndent:(id)sender;
- (void)TE_selectPreviousLineWithSameOrSmallerIndent:(id)sender;
- (void)TE_selectToPreviousLineWithSameOrSmallerIndent:(id)sender;
    // Outline navigation helpers.

- (IBAction)TE_toggleShowsNonAsciiCharacters:(id)sender;

@end
