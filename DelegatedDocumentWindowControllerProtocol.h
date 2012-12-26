//
//  DelegatedDocumentWindowControllerProtocol.h
//  TextEdit
//
//  Created by Kocsis Olivér on 2012.12.26..
//
//

#import <Foundation/Foundation.h>
@class DocumentWindowController, SpeakController;
@protocol DelegatedDocumentWindowControllerProtocol <NSObject>
-(void)setDelegatedDocumentWindowController:(DocumentWindowController*) inDelegatedDocumentWindowController;

@property (assign) IBOutlet NSView* segmentView;
@property (assign) IBOutlet NSView* pullDownView;
@property (assign) IBOutlet SpeakController* sharedSpeakController;

@end
