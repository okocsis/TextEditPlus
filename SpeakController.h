//
//  SpeakController.h
//  TextEdit
//
//  Created by Kocsis Olivér on 2012.12.26..
//
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>


@interface SpeakController : NSObject <NSSpeechSynthesizerDelegate, NSTextViewDelegate>
{
    NSSpeechSynthesizer* synth;
    BOOL _isPaused;
    char _speechBoundary;
    
    IBOutlet NSTextView* currentTextView;
}


@property (nonatomic,retain) IBOutlet NSTextView* currentTextView;
- (IBAction)speak:(id)sender;
- (IBAction)pauseSpeak:(id)sender;
- (IBAction)stopSpeak:(id)sender;
- (IBAction)segmentPushed:(id)sender;
- (IBAction)pauseByWord:(id)sender;
- (IBAction)pauseBysentece:(id)sender;
- (IBAction)pauseImmediately:(id)sender;

@end
