//
//  DrumView.h
//  Xpressive
//
//  Created by Matthew Prockup on 12/4/12.
//  Copyright (c) 2012 Xpressive Instruments. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "Articulation.h"


@interface DrumView : UIView
{   
    int objID;
    int audiosize;
    
    //Current audio sample playback "bucket"
    SInt32* playingAudio;
    
    //Accel stuff (not currently implemented)
    float prevX;
    float prevY;
    float prevZ;
    float levelIterate;
    bool useMaxTap;
}

//Touch Geometry funcitons: Convert to polar, (r,theta) rather than (x,y)
- (float)getRad:(CGPoint) point;
- (float)getAng:(CGPoint) point;
- (float)normalizeAngle:(float) angle;
- (float)normalizeDistance:(float) dist;
- (int)getQuadrant:(CGPoint) point;

//Retrive from the "bucket" of audio samples.
- (void)getAudioData:(SInt32*)buffer onChannel:(int)chan withFrames:(int)numFrames;

//Add to the "bucket" of audio samples.
- (void)addAudioData:(SInt32*)buffer onChannel:(int)chan withFrames:(int)numFrames withGain:(float)gain;

//Audio info utilities
//- (NSString *)OSStatusToStr:(OSStatus)st; //(not implemented)
- (void)printAudio:(SInt32*)audio withSize:(int)length;
- (SInt32)maxAudio:(SInt32*)audio withSize:(int)length;

//Add an articulation with snare on/off
- (void)addArticulation:(NSString*)articulation snarePos:(bool)sn numIntensities:(int)ints numPositions: (int)poss numHeights: (int)heightJawn numExamples:(int)examps withID:(int)idJawn;

//Add an articulation without snare on/off
- (void)addArticulation:(NSString*)articulation numIntensities:(int)ints numPositions: (int)poss numHeights: (int)heightJawn numExamples:(int)examps withID:(int)idJawn;

//Name the instrument
- (void)initializeTrackWithDrum:(NSString*)drum;

//playback samplerate of sample "bucket"
@property (nonatomic) double sampleRate;


//Instrument Paramenters
@property (nonatomic,retain) NSString* drumName;
@property (nonatomic,retain) NSMutableArray* articulations; //Array of Articulation Objects
@property (nonatomic) bool snOn;
@property (nonatomic) int numIntensities;
@property (nonatomic) int numPositions;
@property (nonatomic) int numHeights;
@property (nonatomic) int numExamples;
@property (nonatomic) BOOL isRecording;
@property (nonatomic, strong) NSMutableArray * drumVals;
@end
