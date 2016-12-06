//
//  AudioSample.h
//  Xpressive
//
//  Created by Matthew Prockup on 4/14/13.
//  Copyright (c) 2013 Xpressive Instruments. All rights reserved.
//
#import <AudioToolbox/AudioToolbox.h>
#import <Foundation/Foundation.h>
//#import "MBProgressHUD.h"
#define MAXBUFS  1
#define NUMFILES 1

typedef struct {
    AudioStreamBasicDescription asbd;
    SInt32 *data;
	UInt32 numFrames;
} SoundBuffer;

typedef struct {
	UInt32 frameNum;
    UInt32 maxNumFrames;
    SoundBuffer soundBuffer[MAXBUFS];
}SourceAudioBufferData;


@interface AudioSample : NSObject
{
    SInt32* audioData;
    int audioSize;
    NSString* fileName;
    NSString* drumName;
    NSString* articulation;
    
    int numArticulation;
    
    bool snareOnOff;
    
    int position;
    int numPosition;
    
    int intensity;
    int numIntensity;
    
    int height;
    int numHeight;

    int example;
    int numExamples;
    
    
    SourceAudioBufferData *SourceAudioBufferDataPtr;
    
    SoundBuffer *SoundBufferPtr;
    CFURLRef sourceURL[NUMFILES];
    SourceAudioBufferData mUserData;
    AudioStreamBasicDescription mClientFormat;
    AudioStreamBasicDescription mOutputFormat;
    
}


-(void) initSampleFile:(NSString*) fileJawn forDrum:(NSString*) drum withArticulation:(NSString*)art;
-(void) setExpressionForPosition:(int) pos forIntensity:(int) intense forHeight:(int) hei forExamples:(int) examps;
-(void) setMaxExpressionsNums: (int)arts forPosition:(int) pos forIntensity:(int) intense forHeight:(int) hei forExamples:(int) examps;

-(void) loadAudio;
- (NSString *)OSStatusToStr:(OSStatus)st;
-(SInt32 *) getSampleData;
-(int) getAudioSize;
- (SInt32)maxAudio:(SInt32*)audio withSize:(int)length;

-(NSString*) getFileName;
-(NSString*) getDrumName;
-(NSString*) getArticulation;
-(int) getNumArticulation;
-(bool) getSnareOnOff;
-(int)  getPosition;
-(int)  getNumPosition;
-(int)  getIntensity;
-(int)  getNumIntensity;
-(int)  getHeight;
-(int)  getNumHeight;
-(int)  getExample;
-(int)  getNumExamples;




@end
