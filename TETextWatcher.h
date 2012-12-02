// TETextWatcher.h
// TextExtras
//
// Copyright © 1996-2006, Mike Ferris.
// All rights reserved.

// This class has mostly factory methods.  It sets itself up to watch various pieces of the new text system and to provide certain features to most text systems.  Its operation is largely hands-off.  It just listens and does stuff.  You never really interact with it directly.

// Several separate new features are provided.
//     Select to matching brace: If you double-click on a opening or closing brace, bracket, or parenthesis, the selection will automatically be extended to include the matching counterpart.  If there is no matching counterpart or there is mismatched nesting of delimiters, the double-clicked character will be left selected alone.  This feature is active only when the SelectToMatchingBrace default is set to YES.
//     Indenting wrapped lines:  If you set the default IndentWrappedLines to YES (either for specific applications or in the NSGlobalDomain), then whenever you have a simple text system (such as in a non-paginating TextEdit window) which is editable and not rich text and not a field editor, then wrapped lines will be automatically indented by the width of a certain number of spaces beyond any leading whitespace in the line.  The extra number of spaces to indent is determined by the WrappedLineIndentWidth default, and is 2 if the default is not set.  For example, if a paragraph started with a tab and four spaces and it was so long it wrapped into multiple lines, then (assuming the TabWidth is 8) all the wrapped lines would be indented the equivalent of (8 (for the tab) + 4 (spaces) + 2 (WrappedLineIndentWidth)) = 14 spaces.  It is important to note that no actual spaces are inserted to accomplish this.  It is done through NSParagraphStyle attributes.

#import <Cocoa/Cocoa.h>

@interface TETextWatcher : NSObject {}


@end
