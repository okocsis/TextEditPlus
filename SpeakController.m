//
//  SpeakController.m
//  TextEdit
//
//  Created by Kocsis Olivér on 2012.12.26..
//
//

#import "SpeakController.h"

@implementation SpeakController
@synthesize currentTextView = _currentTextView;

- (id)init
{
    self = [super init];
    if (self) {
        synth = [[NSSpeechSynthesizer alloc] init]; //start with default voice
        //synth is an ivar
        [synth setDelegate:self];
        _isPaused = NO;
        _speechBoundary = NSSpeechWordBoundary;
    }
    return self;
}


- (void)dealloc
{
    [synth release];
    [super dealloc];
}


#pragma mark Notification center protocol implementation
-(void)textViewDidChangeSelection:(NSNotification *)notification
{
//    NSTextView *textView = [notification object];
//    [textView startSpeaking:nil];
    //NSRange selRange = [textView selectedRange];
    
}
- (IBAction)speak:(id)sender
{
    
    //    NSString *voiceID =[[NSSpeechSynthesizer availableVoices] objectAtIndex:0];
    //    [synth setVoice:voiceID];
    if (_isPaused) {
        [synth continueSpeaking];
        _isPaused = NO;
    } else {
        [synth startSpeakingString:[[_currentTextView textStorage] string]];
    }
    
}
- (IBAction)pauseSpeak:(id)sender
{
    if (_isPaused) {
        [synth continueSpeaking];
        _isPaused = NO;
    } else {
        [synth pauseSpeakingAtBoundary:_speechBoundary];
        _isPaused = YES;
    }

}
- (IBAction)stopSpeak:(id)sender
{
    [synth stopSpeaking];
    if (_isPaused) {
        _isPaused = NO;
    }
}
- (IBAction)segmentPushed:(NSSegmentedControl*)sender
{
    switch ([sender selectedSegment])
    {
        case 0:
            [self speak:sender];
            break;
        case 1:
            [self pauseSpeak:sender];
            break;
        case 2:
            [self stopSpeak:sender];
            break;
        default:
            break;
    }
}
- (IBAction)pauseByWord:(id)sender
{
    _speechBoundary = NSSpeechWordBoundary;
    NSLog(@"%d",_speechBoundary);
}
- (IBAction)pauseBysentece:(id)sender
{
    _speechBoundary = NSSpeechSentenceBoundary;
    NSLog(@"%d",_speechBoundary);
}
- (IBAction)pauseImmediately:(id)sender
{
    _speechBoundary = NSSpeechImmediateBoundary;
    NSLog(@"%d",_speechBoundary);
}

@end
