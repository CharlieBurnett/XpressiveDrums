//
//  ViewController.m
//  Xpressive
//
//  Created by Matthew Prockup on 12/4/12.
//  Copyright (c) 2012 Xpressive Instruments. All rights reserved.
//

#import "ViewController.h"
#import <time.h>
#import <AVFoundation/AVFoundation.h>

@implementation ViewController

@synthesize mixerBus0Switch;
@synthesize mixerBus0LevelFader;
@synthesize mixerBus1Switch;
@synthesize mixerBus1LevelFader;
@synthesize mixerOutputLevelFader;
@synthesize BPMLabel;
@synthesize audioObject;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    
    // Release any cached data, images, etc that aren't in use.
}

double taps = 0;
float tapArray[100];

NSMutableArray *timeKeeper;
NSDate *first;
NSDate *last;
int intSeconds = 0;
int metronomeCount = 1;
bool metronomeIsPlaying = false;
BOOL isPlaying = false;
BOOL isRecording = false;


NSString *MixerHostAudioObjectPlaybackStateDidChangeNotification = @"MixerHostAudioObjectPlaybackStateDidChangeNotification";
NSTimer *timer;

- (void) viewDidLoad {
    
    [super viewDidLoad];
    
    [self initDrumViewShit];
    
    drumview0.tag = 0;
    drumview1.tag = 1;
    [[_playButton imageView] setContentMode: UIViewContentModeScaleAspectFit];
    [[_recordButton imageView] setContentMode: UIViewContentModeScaleAspectFit];


    [_ButtonsView.layer setBorderColor:[UIColor colorWithRed:0.302 green:0.314 blue:0.318 alpha:1].CGColor];
    [_ButtonsView.layer setCornerRadius:5];
    [_ButtonsView.layer setBorderWidth:3];
    
    [_bottomView.layer setBorderColor:[UIColor colorWithWhite:.235 alpha:1].CGColor];
    [_bottomView.layer setCornerRadius:5];
    [_bottomView.layer setBorderWidth:3];
    
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Low Seiko SQ50" ofType:@"wav"];
    NSError *error;
    _theAudio=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@",[error localizedDescription]);
    }
    _theAudio.delegate = self;
    _theAudio.volume = 1;
    [_theAudio prepareToPlay];
    
    NSString *highPath = [[NSBundle mainBundle] pathForResource:@"High Seiko SQ50" ofType:@"wav"];
    NSLog(@"path %@", path);
    NSLog(@"url %@", [NSURL fileURLWithPath:path]);
    _highMetronome=[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:highPath] error:&error];
    if (error)
    {
        NSLog(@"Error in audioPlayer: %@",[error localizedDescription]);
    }
    _highMetronome.delegate = self;
    _highMetronome.volume = 1;
    [_highMetronome prepareToPlay];
    
    timeKeeper = [[NSMutableArray alloc] init];
    
    first = [[NSDate alloc] init];
    
    
    GridView *gView = [[GridView alloc]initWithFrame:CGRectMake(0, 0, _gridView.frame.size.width, _gridView.frame.size.height)];
    gView.scrollEnabled = YES;
    
    [_gridView addSubview:gView];
    
    [gView addNote:@"Strike" withTime:0.7 withArticulation:0 withIntensity:0 withPosition:0 withDynamics:0];
    [gView addNote:@"Buzz" withTime:0.1 withArticulation:0 withIntensity:0 withPosition:0 withDynamics:0];
    [gView addNote:@"Cross Stick" withTime:0.5 withArticulation:0 withIntensity:0 withPosition:0 withDynamics:0];
    [gView addNote:@"Rim" withTime:0.5 withArticulation:0 withIntensity:0 withPosition:0 withDynamics:0];
    [gView addNote:@"Strike" withTime:0.1 withArticulation:0 withIntensity:0 withPosition:0 withDynamics:0];
    [gView addNote:@"Long Kick" withTime:0.2 withArticulation:0 withIntensity:0 withPosition:0 withDynamics:0];
    [gView addNote:@"Long Kick" withTime:0.3 withArticulation:0 withIntensity:0 withPosition:0 withDynamics:0];
    
    [gView setDraggableNoteView];
    
    UInt32 inputBus0 = 0;
    AudioUnitParameterValue isOn0 = (AudioUnitParameterValue) turnOn0;
    
    [audioObject enableMixerInput: inputBus0 isOn: isOn0];
    
    UInt32 inputBus1 = 1;
    AudioUnitParameterValue isOn = (AudioUnitParameterValue) turnOn1;
    
    [audioObject enableMixerInput: inputBus1 isOn: isOn];
    
    if (audioObject.isPlaying) {
        
        [audioObject stopAUGraph];
        
    } else {
        
        [audioObject startAUGraph];
    }
    turnOn0 = !turnOn0;
    turnOn1 = !turnOn1;
    
}

# pragma mark User interface methods
// Set the initial multichannel mixer unit parameter values according to the UI state
- (void) initializeMixerSettingsToUI {
    
    // Initialize mixer settings to UI
    
    [audioObject setMixerOutputGain: mixerOutputLevelFader.value];
    NSLog(@"mixerSwitch0: %f, mixerSwitch1: %f ", mixerBus0LevelFader.value, mixerBus1LevelFader.value);
    NSLog(@"mixerSwitch0: %c, mixerSwitch1: %c ", mixerBus0Switch.isOn, mixerBus1Switch.isOn);

    
    [audioObject enableMixerInput: 0 isOn: true];
    [audioObject enableMixerInput: 1 isOn: true];
    
    [audioObject setMixerInput: 0 gain: 1];
    [audioObject setMixerInput: 1 gain: 1];
}

// Handle a change in the mixer output gain slider.
- (IBAction) mixerOutputGainChanged: (UISlider *) sender {
    UInt32 inputBus = (UInt32) sender.tag;
    [audioObject setMixerInput: (UInt32) inputBus gain: (AudioUnitParameterValue) sender.value];
    NSLog(@"Gain %u Changed, new value: %f",(unsigned int)inputBus,sender.value);
    [audioObject setMixerOutputGain: (AudioUnitParameterValue) sender.value];
}

// Handle a change in a mixer input gain slider. The "tag" value of the slider lets this 
//    method distinguish between the two channels.
//- (IBAction) mixerInputGainChanged: (UISlider *) sender {
//    
//    UInt32 inputBus = sender.tag;
//    NSLog(@"Gain %lu Changed, new value: %f",inputBus,sender.value);
//    [audioObject setMixerInput: (UInt32) inputBus gain: (AudioUnitParameterValue) sender.value];
//}
bool turnOn0 = true;
bool turnOn1 = true;

- (IBAction)playPressed:(id)sender {

    if (isPlaying == NO) {
        [sender setImage:[UIImage imageNamed:@"Pause.png"] forState:UIControlStateNormal];
        [sender setSelected:YES];
        isPlaying = YES;
        NSDate * placeholder;
        NSMutableArray * array = [drumview1 drumVals];
        NSMutableArray* playbackArray = [drumview0 drumVals];
    
        [playbackArray addObjectsFromArray:array];
        
        NSSortDescriptor *drumSortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
        NSArray * sortDescriptors = [NSArray arrayWithObject:drumSortDescriptor];
        NSArray * sortedArray = [playbackArray sortedArrayUsingDescriptors:sortDescriptors];
    
        for (int i = 0; i<sortedArray.count; i++) {
            NSDictionary * temp = [sortedArray objectAtIndex:i];
            NSDate * recordDate = [temp objectForKey:@"date"];
            int chan = [[temp objectForKey:@"channel"] intValue];
            unsigned long long data = [[temp objectForKey:@"data"] longLongValue];
            int frames = [[temp objectForKey:@"frames"]intValue];
            float gain = [[temp objectForKey:@"gain"] floatValue];
            
            //dispatch_async(dispatch_get_main_queue(), ^{
            
            if ([temp objectForKey:@"drum"] == 0) {
                [drumview0 addAudioData: data onChannel:chan withFrames:frames withGain:gain];
            }
            else{
                [drumview1 addAudioData: data onChannel:chan withFrames:frames withGain:gain];
            }
                
           // });
            float waitTime = ([recordDate timeIntervalSince1970]-[placeholder timeIntervalSince1970])*1000000;
        
            NSLog(@"first Date %f, temp Date: %f difference: %f", [recordDate timeIntervalSince1970],[placeholder timeIntervalSince1970], waitTime);
            if ([recordDate timeIntervalSince1970]-[placeholder timeIntervalSince1970]>=0 && placeholder != nil) {
                NSLog(@"In wait time: %f",waitTime);
                usleep(floor(waitTime));
            }
            placeholder = recordDate;
        }
        isPlaying = NO;
    }

}

- (IBAction)metronomeWasPressed:(id)sender {
    if (!metronomeIsPlaying&&intSeconds!=0) {
        timer = [NSTimer scheduledTimerWithTimeInterval: (60.0/intSeconds) target: self selector: @selector(loopMetronome:) userInfo: nil repeats: YES];
    }
    else{
        [timer invalidate];
        timer = nil;
        metronomeCount = 1;
    }
    metronomeIsPlaying = !metronomeIsPlaying;
}

- (IBAction)loopMetronome:(id)sender {
    if (metronomeCount == 1) {
        [_highMetronome play];
    }
    else {
        [_theAudio play];
    }
    if (metronomeCount==4) {
        metronomeCount=1;
    }
    else {
        metronomeCount++;
    }
}

// Handle a change in playback state that resulted from an audio session interruption or end of interruption
- (void) handlePlaybackStateChanged: (id) notification {
    
    //[self playOrStop: nil];
}

#pragma mark -
#pragma mark Mixer unit control

// Handle a Mixer unit input on/off switch action. The "tag" value of the switch lets this
//    method distinguish between the two channels.
- (IBAction)recordPressed:(id)sender {
    if ([sender isSelected]) {
        [sender setImage:[UIImage imageNamed:@"Record_Inactive.png"] forState:UIControlStateNormal];
        [sender setSelected:NO];
    }
    else {
        [sender setImage:[UIImage imageNamed:@"Record_Active.png"] forState:UIControlStateSelected];
        [sender setSelected:YES];
    }
    [drumview0 setIsRecording:![drumview0 isRecording]];
    [drumview1 setIsRecording:![drumview1 isRecording]];

}

- (IBAction) enableMixerInput: (UISwitch *) sender {
    
    UInt32 inputBus = (UInt32) sender.tag;
    AudioUnitParameterValue isOn = (AudioUnitParameterValue) sender.isOn;
    
    [audioObject enableMixerInput: inputBus isOn: isOn];
    
}


#pragma mark -
#pragma mark Remote-control event handling
//// Respond to remote control events
//- (void) remoteControlReceivedWithEvent: (UIEvent *) receivedEvent {
//    
//    if (receivedEvent.type == UIEventTypeRemoteControl) {
//        
//        switch (receivedEvent.subtype) {
//                
//            case UIEventSubtypeRemoteControlTogglePlayPause:
//                [self playOrStop: nil];
//                break;
//                
//            default:
//                break;
//        }
//    }
//}


#pragma mark -
#pragma mark Notification registration
// If this app's audio session is interrupted when playing audio, it needs to update its user interface 
//    to reflect the fact that audio has stopped. The MixerHostAudio object conveys its change in state to
//    this object by way of a notification. To learn about notifications, see Notification Programming Topics.
- (void) registerForAudioObjectNotifications {
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    
    [notificationCenter addObserver: self
                           selector: @selector (handlePlaybackStateChanged:)
                               name: MixerHostAudioObjectPlaybackStateDidChangeNotification
                             object: audioObject];
}


#pragma mark -
#pragma mark Application state management

//Initialize drumview parameters and attach drumviews to audio channels
//This should be more dynmaic in the future
-(void) initDrumViewShit
{
    //Set Background image of DrumView
    //UIColor *background1 = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Pad_4Zone.png"]];
   // UIColor *background2 = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"Pad_4Zone.png"]];
    
    //drumview0.backgroundColor = background1;
    //drumview1.backgroundColor = background2;
    
    //Setup first drum pad view
    [drumview0 initializeTrackWithDrum:@"Snare"];
    
    //  Add articulations with the given number of parameters to the view.
    //  Based on these inputs, it dynamically geneates the file names to look for.
    [drumview0 addArticulation:@"Strike" snarePos:1 numIntensities:3 numPositions:3 numHeights:4 numExamples:4 withID:0];
    [drumview0 addArticulation:@"Buzz" snarePos:1 numIntensities:3 numPositions:3 numHeights:4 numExamples:4 withID:0];
    [drumview0 addArticulation:@"Cross Stick" snarePos:1 numIntensities:3 numPositions:2 numHeights:4 numExamples:4 withID:0];
    [drumview0 addArticulation:@"Rim" snarePos:1 numIntensities:3 numPositions:3 numHeights:4 numExamples:4 withID:0];
    
    
    //Setup second drum pad view
    [drumview1 initializeTrackWithDrum:@"Long Kick"];
    
    //  Add articulations with the given number of parameters to the view.
    //  Based on these inputs, it dynamically geneates the file names to look for.
    [drumview1 addArticulation:@"Press" snarePos:1 numIntensities:1 numPositions:1 numHeights:5 numExamples:3 withID:1];
    [drumview1 addArticulation:@"Press" snarePos:1 numIntensities:1 numPositions:1 numHeights:5 numExamples:3 withID:1];//small
    [drumview1 addArticulation:@"Release" snarePos:1 numIntensities:1 numPositions:1 numHeights:5 numExamples:3 withID:1];
    [drumview1 addArticulation:@"Release" snarePos:1 numIntensities:1 numPositions:1 numHeights:5 numExamples:3 withID:1];//small
    
    //create array of drum view objects
    drumViews = [[NSMutableArray alloc] init];
    [drumViews addObject:drumview0];
    [drumViews addObject:drumview1];
    
    //init the audio mixer, setting each view as a mixer channel
    MixerHostAudio *newAudioObject = [[MixerHostAudio alloc] initWithBusses:(int)[drumViews count] withDrumObjects:drumViews];
    self.audioObject = newAudioObject;
    [self registerForAudioObjectNotifications];
    [self initializeMixerSettingsToUI];
}

- (float*)getDataOnChannel:(int)channel withFrames:(int)numFrames
{
    return 0;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}




- (IBAction)TappingDidStart:(id)sender {
    if (taps == 0) {
        [_highMetronome play];
    }
    else {
        [_theAudio play];
    }
    if (taps==3) {
        taps=0;
    }
    else {
        taps++;
    }
    
    last = [[NSDate alloc] init];
    
    //[timeKeeper addObject:d];
    
    //NSLog(@"t: %f taps: %f", [d timeIntervalSince1970], taps);
    [self BPMCalculator];
    
}

-(void)BPMCalculator
{
    double seconds = (1/([last timeIntervalSince1970]-[first timeIntervalSince1970]))*60;
    intSeconds = floor(seconds);
    [BPMLabel setText:[NSString stringWithFormat:@"%d",intSeconds ]];
    NSLog(@"Seconds: %f Taps: %f", seconds, taps);
    first = last;
}



@end
