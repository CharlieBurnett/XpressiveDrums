//
//  ViewController.h
//  Xpressive
//
//  Created by Matthew Prockup on 12/4/12.
//  Copyright (c) 2012 Xpressive Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "DrumView.h"
#import "MixerHostAudio.h"
#import<AVFoundation/AVAudioPlayer.h>
#import "GridView.h"

@class MixerHostAudio;
@interface ViewController : UIViewController <AVAudioPlayerDelegate>
{
    IBOutlet DrumView* drumview0;
    IBOutlet DrumView* drumview1;
    
    AudioComponentInstance toneUnit;
        
    UISwitch *mixerBus0Switch;
    UISwitch *mixerBus1Switch;

    UISlider *mixerBus0LevelFader;
    UISlider *mixerBus1LevelFader;
    UISlider *mixerOutputLevelFader;
    NSMutableArray *drumViews;
    
@public
    double sampleRate;
}
- (float*)getDataOnChannel:(int)channel withFrames:(int)numFrame;
- (IBAction)TappingDidStart:(id)sender;

@property (weak, nonatomic) IBOutlet UIView *ButtonsView;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
@property (weak, nonatomic) IBOutlet UIButton *metronome;
@property (weak, nonatomic) IBOutlet UILabel *BPMLabel;
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (nonatomic, retain) IBOutlet UISlider *mixerBus0LevelFader;
@property (nonatomic, retain) IBOutlet UISlider *mixerBus1LevelFader;
@property (nonatomic, retain) IBOutlet UISlider *mixerOutputLevelFader;

@property (nonatomic, retain) IBOutlet UIButton *loadButton;

@property (nonatomic, retain) IBOutlet UISwitch *mixerBus0Switch;
@property (nonatomic, retain) IBOutlet UISwitch *mixerBus1Switch;

@property (nonatomic, retain) AVAudioPlayer* theAudio;
@property (nonatomic, retain) AVAudioPlayer* highMetronome;

@property (weak, nonatomic) IBOutlet UIView *gridView;

- (IBAction)recordPressed:(id)sender;
- (IBAction) mixerOutputGainChanged:    (UISlider *) sender;

- (IBAction)playPressed:(id)sender;

- (IBAction)metronomeWasPressed:(id)sender;

@property (nonatomic, retain) MixerHostAudio *audioObject;

@end
