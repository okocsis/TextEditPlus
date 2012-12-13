// TEFoundationExtras.h
// TextExtras
//
// Copyright © 1996-2006, Mike Ferris.
// All rights reserved.

#import <Cocoa/Cocoa.h>

@interface NSString (TEFoundationExtras)

- (NSString *)TE_stringByReplacingBackslashWithSlash;

@end

@interface NSMutableString (TEFoundationExtras)

- (void)TE_standardizeEndOfLineToLF;
- (void)TE_standardizeEndOfLineToCRLF;
- (void)TE_standardizeEndOfLineToCR;
- (void)TE_standardizeEndOfLineToParagraphSeparator;
- (void)TE_standardizeEndOfLineToLineSeparator;

@end

@interface NSArray (TEFoundationExtras)

- (NSString *)TE_longestCommonPrefixForStrings;

@end
