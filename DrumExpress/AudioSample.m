//
//  AudioSample.m
//  Xpressive
//
//  Created by Matthew Prockup on 4/14/13.
//  Copyright (c) 2013 Xpressive Instruments. All rights reserved.
//

#import "AudioSample.h"

@implementation AudioSample

#pragma mark -
#pragma mark SETUP
#pragma mark
-(void) initSampleFile:(NSString*) fileJawn forDrum:(NSString*) drum withArticulation:(NSString*)art
{
    fileName = fileJawn;
    drumName = drum;
    articulation = art;
}


-(void) setMaxExpressionsNums: (int)arts forPosition:(int) pos forIntensity:(int) intense forHeight:(int) hei forExamples:(int) examps
{
    numArticulation = arts;
    numPosition = pos;
    numIntensity = intense;
    numHeight = hei;
    numExamples = examps;
}

-(void) setExpressionForPosition:(int) pos forIntensity:(int) intense forHeight:(int) hei forExamples:(int) examps
{
    position = pos;
    intensity = intense;
    height = hei;
    example = examps;
}


#pragma mark -
#pragma mark AUDIO
#pragma mark
#pragma mark Loading Audio Content

-(SInt32 *) getSampleData
{
    return audioData;
}

- (void)loadAudio
{  
    NSLog(@"Loading Audio");
    // client format audio goes into the mixer
    
    mClientFormat.mSampleRate       = 44100.0;
    mClientFormat.mFormatID         = kAudioFormatLinearPCM;
    mClientFormat.mFormatFlags      = kAudioFormatFlagsAudioUnitCanonical;
    mClientFormat.mBytesPerPacket   = 1 * sizeof (SInt32);    // 8
    mClientFormat.mFramesPerPacket  = 1;
    mClientFormat.mBytesPerFrame    = 1 * sizeof (SInt32);    // 8
    mClientFormat.mChannelsPerFrame = 1;
    mClientFormat.mBitsPerChannel   = 8 * sizeof (SInt32);    // 32
    mClientFormat.mReserved         = 0;   
    
    // output format
    mOutputFormat.mSampleRate       = 44100.0;
    mOutputFormat.mFormatID         = kAudioFormatLinearPCM;
    mOutputFormat.mFormatFlags      = kAudioFormatFlagsAudioUnitCanonical;
    mOutputFormat.mBytesPerPacket   = 1 * sizeof (SInt32);    // 8
    mOutputFormat.mFramesPerPacket  = 1;
    mOutputFormat.mBytesPerFrame    = 1 * sizeof (SInt32);    // 8
    mOutputFormat.mChannelsPerFrame = 1;
    mOutputFormat.mBitsPerChannel   = 8 * sizeof (SInt32);    // 32
    mOutputFormat.mReserved         = 0;   
    
    
    
    
    sourceURL[0] = (__bridge CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:fileName ofType:@"wav"]];
    
    
    mUserData.frameNum = 0;
    mUserData.maxNumFrames = 0;
    
    for (int i = 0; i < NUMFILES && i < MAXBUFS; i++)  {
        printf("loadFiles, %d\n", i);
        
        ExtAudioFileRef xafref = 0;
        
        // open one of the two source files
        OSStatus result = ExtAudioFileOpenURL(sourceURL[i], &xafref);
        if (result || !xafref) { 
            NSLog(@"ExtAudioFileOpenURL:  %@", [self OSStatusToStr:result]); 
            return; 
        }
        
        // get the file data format, this represents the file's actual data format
        // for informational purposes only -- the client format set on ExtAudioFile is what we really want back
        AudioStreamBasicDescription fileFormat;
        UInt32 propSize = sizeof(fileFormat);
        
        result = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileDataFormat, &propSize, &fileFormat);
        if (result) {
            NSLog(@"ExtAudioFileGetProperty kExtAudioFileProperty_FileDataFormat:  %@", [self OSStatusToStr:result]); 
            //printf("ExtAudioFileGetProperty kExtAudioFileProperty_FileDataFormat result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); 
            return;
        }
        
        printf("file %d, native file format\n", i);
        //fileFormat.Print();
        
        //set the client format to be what we want back
        // this is the same format audio we're giving to the the mixer input
        result = ExtAudioFileSetProperty(xafref, kExtAudioFileProperty_ClientDataFormat, sizeof(mClientFormat), &mClientFormat);
        if (result) {
            NSLog(@"ExtAudioFileGetProperty kExtAudioFileProperty_ClientDataFormat:  %@", [self OSStatusToStr:result]); 
            NSLog(@"ExtAudioFileSetProperty kExtAudioFileProperty_ClientDataFormat %d %08X %4.4s\n", (int)result, (unsigned int)result, (char*)&result);
            return; 
        }
        
        
        // get the file's length in sample frames
        UInt64 numFrames = 0;
        propSize = sizeof(numFrames);
        result = ExtAudioFileGetProperty(xafref, kExtAudioFileProperty_FileLengthFrames, &propSize, &numFrames);
        if (result) {
            NSLog(@"ExtAudioFileGetProperty kExtAudioFileProperty_FileLengthFrames:  %@", [self OSStatusToStr:result]); 
            //printf("ExtAudioFileGetProperty kExtAudioFileProperty_FileLengthFrames result %ld %08X %4.4s\n", result, (unsigned int)result, (char*)&result); 
            return; 
        }
        
        // keep track of the largest number of source frames
        if (numFrames > mUserData.maxNumFrames) mUserData.maxNumFrames = (UInt32)numFrames;
        
        // set up our buffer
        mUserData.soundBuffer[i].numFrames = (UInt32)numFrames;
        mUserData.soundBuffer[i].asbd = mClientFormat;
        
        UInt32 samples = (UInt32)(numFrames * mUserData.soundBuffer[i].asbd.mChannelsPerFrame);
        mUserData.soundBuffer[i].data = (SInt32 *)calloc(samples, sizeof(SInt32));
        
        // set up a AudioBufferList to read data into
        AudioBufferList bufList;
        bufList.mNumberBuffers = 1;
        bufList.mBuffers[0].mNumberChannels = mUserData.soundBuffer[i].asbd.mChannelsPerFrame;
        bufList.mBuffers[0].mData = mUserData.soundBuffer[i].data;
        bufList.mBuffers[0].mDataByteSize = samples * sizeof(SInt32);
        
        
        
        
        // perform a synchronous sequential read of the audio data out of the file into our allocated data buffer
        UInt32 numPackets = (UInt32)numFrames;
        result = ExtAudioFileRead(xafref, &numPackets, &bufList);
        if (result) {
            
            NSLog(@"ExtAudioFileRead:  %@", [self OSStatusToStr:result]);
            
            NSLog(@"ExtAudioFileRead result %%d %08X %4.4s\n", (int)result, (char*)&result);
            free(mUserData.soundBuffer[i].data);
            mUserData.soundBuffer[i].data = 0;
            return;
        }
        
        NSLog(@"%d",(int)[self maxAudio:bufList.mBuffers[0].mData withSize:512]);
        audioData = bufList.mBuffers[0].mData;
        audioSize = samples;
        // close the file and dispose the ExtAudioFileRef
        ExtAudioFileDispose(xafref);
    }
    
    
}


- (NSString *)OSStatusToStr:(OSStatus)st
{
    switch (st) {
        case kAudioFileUnspecifiedError:
            return @"kAudioFileUnspecifiedError";
            
        case kAudioFileUnsupportedFileTypeError:
            return @"kAudioFileUnsupportedFileTypeError";
            
        case kAudioFileUnsupportedDataFormatError:
            return @"kAudioFileUnsupportedDataFormatError";
            
        case kAudioFileUnsupportedPropertyError:
            return @"kAudioFileUnsupportedPropertyError";
            
        case kAudioFileBadPropertySizeError:
            return @"kAudioFileBadPropertySizeError";
            
        case kAudioFilePermissionsError:
            return @"kAudioFilePermissionsError";
            
        case kAudioFileNotOptimizedError:
            return @"kAudioFileNotOptimizedError";
            
        case kAudioFileInvalidChunkError:
            return @"kAudioFileInvalidChunkError";
            
        case kAudioFileDoesNotAllow64BitDataSizeError:
            return @"kAudioFileDoesNotAllow64BitDataSizeError";
            
        case kAudioFileInvalidPacketOffsetError:
            return @"kAudioFileInvalidPacketOffsetError";
            
        case kAudioFileInvalidFileError:
            return @"kAudioFileInvalidFileError";
            
        case kAudioFileOperationNotSupportedError:
            return @"kAudioFileOperationNotSupportedError";
            
        case kAudioFileNotOpenError:
            return @"kAudioFileNotOpenError";
            
        case kAudioFileEndOfFileError:
            return @"kAudioFileEndOfFileError";
            
        case kAudioFilePositionError:
            return @"kAudioFilePositionError";
            
        case kAudioFileFileNotFoundError:
            return @"kAudioFileFileNotFoundError";
            
        default:
            return @"unknown error";
    }
}

-(int) getAudioSize{
    return audioSize;
}

#pragma mark Audio Helper Functions

- (void)printAudio:(SInt32*)audio withSize:(int)length
{
    for(int i = 1;i<length;i++)
    {
        NSLog(@"%d",(int)audio[i]);
    }
    
}

- (SInt32)maxAudio:(SInt32*)audio withSize:(int)length
{   SInt32 max = 0.0;
    for(int i = 0;i<length;i++)
    {
        if( abs(audio[i])>max)
        {
            max = abs(audio[i]);
        }
    }
    return max;


}


#pragma mark -
#pragma mark ACCESS
#pragma mark -
#pragma mark Articulation Definition
-(NSString*) getFileName{
    return fileName;
}

-(NSString*) getDrumName{
    return drumName;
}
 
-(NSString*) getArticulation{
    return articulation;
}

-(bool) getSnareOnOff{
    return snareOnOff;
}

#pragma mark Expressive Range
-(int) getNumArticulation{
    return numArticulation;
}

-(int) getNumPosition{
    return numPosition;
}

-(int) getNumIntensity{
    return numIntensity;
}

-(int) getNumHeight{
    return numHeight;
}

-(int) getNumExamples{
    return numExamples;
}

#pragma mark Articulation Parameters
-(int) getPosition{
    return position;
}

-(int) getIntensity{
    return intensity;
}

-(int) getHeight{
    return height;
}

-(int) getExample{
    return example;
}




@end
