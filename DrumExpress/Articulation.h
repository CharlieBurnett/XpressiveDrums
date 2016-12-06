//
//  Articulation.h
//  Xpressive
//
//  Created by Matthew Prockup on 4/14/13.
//  Copyright (c) 2013 Xpressive Instruments. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>
#import "AudioSample.h"

@interface Articulation : NSObject
{
    
}


-(void) initArticulation:(NSString*)art forDrum:(NSString*) drum withSnares:(int)snaresOn;
-(void) setExpressiveRangePositions:(int) pos forIntensity:(int) intense forHeight:(int) hei forExamples:(int) examps;
-(void) setExpressiveRangeForIntensity:(int) intense forHeight:(int) hei forExamples:(int) examps;
-(void) loadAudio;
-(NSString*) getDrumName;
-(NSString*) getArticulation;
-(AudioSample*) getAudioSampleWithKey:(NSString*)keyJawn;
//keyJawn corresponds to dictionary of samples (see keys definition)
-(SInt32*) getSampleDataWithKey:(NSString*)keyJawn;
-(int)  getNumPosition;
-(int)  getNumIntensity;
-(int)  getNumHeight;
-(int)  getNumExamples;
-(bool) getSnaresOn;


////////////////////////////////////////////////
//
// KEYS DEFINITION
//
//    keys are NSString "siph.e"
//    s = boolean value (1/0) snare on off
//    i = intensity     (1 ... numIntensity )
//    p = position      (1 ... numPosition)
//    h = height        (1 ... numHeight)
//    e = example num   (1 ... numExamples)
//
////////////////////////////////////////////////

@property (nonatomic) int numPosition;
@property (nonatomic) int numIntensity;
@property (nonatomic) int numHeight;
@property (nonatomic) int numExamples;
@property (nonatomic) int snaresOn;
@property (nonatomic,retain) NSString* drumName;
@property (nonatomic,retain) NSString* articulation;
@property (nonatomic,retain) NSMutableDictionary* expressions;



@end
