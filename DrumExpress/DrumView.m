//
//  DrumView.m
//  Xpressive
//
//  Created by Matthew Prockup on 12/4/12.
//  Copyright (c) 2012 Xpressive Instruments. All rights reserved.
//

#import "DrumView.h"

float maxTap;
bool justTouched;
float sumDiff;
bool isFreeToAlter;
@implementation DrumView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

#pragma mark Touch Code
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
}


//Called when a DrumView is touched
//Calculate (r,theta) of touch, map it to the sample space
//Add selected sample to the playback "bucket"
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"--------");
    NSLog(@"touchesBegan, id:%d",objID);
    UITouch *touch = [[event allTouches] anyObject];
    CGPoint location = [touch locationInView:touch.view];
    float ang = [self getAng:location]+.785;
    float depth = [self getRad:location];
    
    
    float distanceFromCenter = 0.0;
    if([self isCymbal])//linear positioning across cymbal.
    {
        distanceFromCenter = powf([self normalizeDistance:depth],1);
    }
    else //more radius length for center samples than egde samples.
    {
        distanceFromCenter = powf([self normalizeDistance:depth],2);
    }
    
    float radialAxis = [self normalizeAngle:ang];
    NSLog(@"Angle: %f | norm ang: %f", ang, [self normalizeAngle:ang]);
    int quad = [self getQuadrant:location]; //used for articulation selection
    
    justTouched = true;//used for accel.
    
    quad = quad-1;
    SInt32* tempData;
    Articulation* tempArt = [_articulations objectAtIndex:quad];
    int tempPos = distanceFromCenter*[tempArt getNumPosition] + 1;
    int tempIntense = radialAxis*[tempArt getNumIntensity] + 1;
    int tempExample = 1; //Init sample example to choose. Multiple versions of same sample add realism
    int tempSnareOn = 0; //init snare
    
    if(_snOn)
        tempSnareOn = 1;
    
    int tempHeight = 3; //hardcode hight. This will eventually reflect accelerometer intensity.
    
    if([tempArt getNumIntensity] == 1) //if samples contain only one intensity parameter
    {
        tempHeight = radialAxis*[tempArt getNumHeight] + 1; //make the radial axis height samples
        tempIntense = 1;
    }
    
    //crate key from touch parameters. This will correlate to the file names of the audio samples
    NSString* tempKey = [NSString stringWithFormat:@"%d%d%d%d.%d", tempSnareOn,tempIntense, tempPos, tempHeight,tempExample];
    
    //get the sample data associated with the articuation (quadrant) and the given parameter key.
    int tempSize = [[[_articulations objectAtIndex:quad] getAudioSampleWithKey:tempKey] getAudioSize];
    tempData= [[_articulations objectAtIndex:quad] getSampleDataWithKey:tempKey];
    
    //Print touch output for debug
    NSLog(@"Distance:%f  Rotation:%f  Quad:%d  Drum:%@ Articulation:%@  Key:%@",distanceFromCenter,radialAxis,quad, [tempArt getDrumName], [tempArt getArticulation],tempKey);
    
    //add the sample data to the playback "bucket"
    [self addAudioData:(SInt32*)tempData onChannel:0 withFrames:tempSize withGain:1];

    
    if (_isRecording) {
        NSDate *recDate = [[NSDate alloc] init];
        NSString *tempDataString = [NSString stringWithFormat:@"%ld", tempData];
        NSString *tempSizeString = [NSString stringWithFormat:@"%d", tempSize];
        NSNumber * drumPadNumber = [NSNumber numberWithInteger:self.tag];

        NSDictionary *recordedData = @{@"data": tempDataString, @"channel": @0, @"frames": tempSizeString, @"gain": @1, @"date": recDate, @"drum":drumPadNumber};
        [_drumVals addObject:recordedData];
        NSLog(@"drumVals: %lu", (unsigned long)_drumVals.count);
    }
    NSLog(@"tempData %ld", tempData);
    //NSLog(@"ang: %f, depth: %f, radialAxis: %f, quad: %d", ang, depth,radialAxis,quad);

    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{

}


#pragma mark Touch Geometry
- (float)getRad:(CGPoint) point{
    float centerX = self.bounds.size.width/2.0;
    float newX = point.x - centerX;
    float centerY = self.bounds.size.height/2.0;
    float newY = point.y - centerY;
    float radius = sqrtf(powf(newX, 2.0) + powf(newY, 2.0));
    NSLog(@"Rad:%f", radius);
    return radius;
}

- (float)getAng:(CGPoint) point{
    float centerX = self.bounds.size.width/2.0;
    float newX = point.x - centerX;
    float centerY = self.bounds.size.height/2.0;
    float newY = point.y - centerY;
    float angle = atanf(newY/newX);
    NSLog(@"ang:%f", angle);
    return angle;
}


- (float)normalizeAngle:(float) angle{
    float angleOverPi = (angle/M_PI);
    float normAng = fabsf(angleOverPi)*2;
    return normAng;
}


- (float)normalizeDistance:(float) dist{
    return dist/(self.bounds.size.width/2.0);
}


- (int)getQuadrant:(CGPoint) point{
    float quadrant = 1;
    /*
    float centerX = self.bounds.size.width/2.0;
    float newX = point.x - centerX;
    float centerY = self.bounds.size.height/2.0;
    float newY = point.y - centerY;
    float quadrant = 1;
    if(newX>=0 && newY>=0)
    {
        quadrant = 4;
    }
    else if(newX>=0 && newY<0)
    {
        quadrant = 1;
    }
    else if(newX<0 && newY>=0)
    {
        quadrant = 3;
    }
    else if(newX<0 && newY<0)
    {
        quadrant = 2;
    }
     */
    if (point.x>=point.y&&point.x>=self.frame.size.width-point.y) {
        quadrant = 1;
    }
    else if (point.x>=point.y&&point.x<self.frame.size.width-point.y) {
        quadrant = 2;
    }
    else if (point.x<point.y&&point.x<self.frame.size.width-point.y) {
        quadrant = 3;
    }
    else if (point.x<point.y&&point.x>=self.frame.size.width-point.y) {
        quadrant = 4;
    }
    NSLog(@"quadtest %f", quadrant);
    return quadrant;
}

#pragma mark Audio Code
//access audio samples from the playback bucket, return by refrerence in the supplied buffer
- (void)getAudioData:(SInt32*)buffer onChannel:(int)chan withFrames:(int)numFrames{
    
    while(isFreeToAlter == false)//make sure buffer is not being read from in the audio callback
    {
        usleep(500);
        
    }
    isFreeToAlter = false;
    
    if(numFrames<audiosize) //there is more in the "bucket" than being asked for. Dump those samples into the supplied buffer.
    {
        for(int i = 0; i<numFrames; i++)
        {
            buffer[i] = playingAudio[i];
        }
       
        SInt32* temp = malloc((audiosize-numFrames)*sizeof(SInt32));
        memcpy(temp, &playingAudio[numFrames],(audiosize-numFrames)*sizeof(SInt32));
        
        playingAudio = (SInt32*)realloc(playingAudio,(audiosize-numFrames)*sizeof(SInt32));
        memcpy(playingAudio, temp, (audiosize-numFrames)*sizeof(SInt32));
        free(temp);
        
        audiosize = audiosize-numFrames;
        
    }
    else //it wants more samples than are available. Always keep numFrames samples in the buffer
        // if there are no percussion sounds to play, fill the buffer with 0's
    {
        for(int i = 0; i<audiosize; i++)
        {
            buffer[i] = playingAudio[i];
        }
        for(int i = audiosize; i<numFrames; i++)
        {
            buffer[i] = 0;
        }
       
        free(playingAudio);
        playingAudio = (SInt32*)calloc(numFrames,sizeof(SInt32));
        audiosize = numFrames;
        
    }
   
    
    isFreeToAlter = true;

}

//Add sample data to the playback 'bucket'
- (void)addAudioData:(SInt32*)buffer onChannel:(int)chan withFrames:(int)numFrames withGain:(float)gain{
     NSLog(@"addAudioData, id:%d",objID);
    
    // make sure no one is using the data
    while(isFreeToAlter == false)
    {
        usleep(500);
        
    }
    isFreeToAlter = false;
    NSLog(@"%f",gain);
    
    if(![self isCymbal])//dont overlap cymbals, chop them off when another is pressed.
    {
        int addedAudioSize = numFrames;
        if(audiosize>=addedAudioSize)//new is shorter than suff thats there. Add new sample data on top of the stuff thats already there
        {
            for(int i = 0; i<addedAudioSize; i++)
            {
                playingAudio[i] = playingAudio[i]+buffer[i]*gain;
            }
            
        }
        else //New stuff is longer than "bucket", resize the "bucket" and add new stuff on top
        {
            SInt32* tempAudio = (SInt32*) malloc(addedAudioSize*sizeof(SInt32));
            
            
            for(int i = 0; i<audiosize; i++)
            {
                tempAudio[i] = playingAudio[i]+buffer[i]*gain;
            }
            for(int i = audiosize; i<addedAudioSize; i++)
            {
                 tempAudio[i] = buffer[i]*gain;
            }
            
            free(playingAudio);
            playingAudio = (SInt32*) malloc(addedAudioSize*sizeof(SInt32));
            memcpy(playingAudio, tempAudio, addedAudioSize*sizeof(SInt32));
            free(tempAudio);
            audiosize = addedAudioSize;
        }
    }
    else //Add new sample data on top of the stuff thats already there
    {
        free(playingAudio);
        playingAudio = (SInt32*) malloc(numFrames*sizeof(SInt32));
        for(int i = 0; i<numFrames; i++)
        {
            playingAudio[i] = buffer[i]*gain;
        }
        audiosize = numFrames;
        
    }
    isFreeToAlter = true;
    
}


//Add object to articulations array, snare on/off included
- (void)addArticulation:(NSString*)articulation snarePos:(bool)sn numIntensities:(int)ints numPositions: (int)poss numHeights: (int)heightJawn numExamples:(int)examps withID:(int)idJawn
{
    _snOn = sn;
    Articulation* tempArt = [[Articulation alloc] init];
    [tempArt initArticulation:articulation forDrum:_drumName withSnares:sn];
    [tempArt setExpressiveRangePositions:poss forIntensity:ints forHeight:heightJawn forExamples:examps];
  
    [tempArt loadAudio];
    
    [_articulations addObject:tempArt];
        
    objID = idJawn;
}

//Add object to articulations array, snare on/off not included
- (void)addArticulation:(NSString*)articulation numIntensities:(int)ints numPositions: (int)poss numHeights: (int)heightJawn numExamples:(int)examps withID:(int)idJawn
{
    _snOn = -1;
    Articulation* tempArt = [[Articulation alloc] init];
    [tempArt initArticulation:articulation forDrum:_drumName withSnares:_snOn];
    [tempArt setExpressiveRangePositions:poss forIntensity:ints forHeight:heightJawn forExamples:examps];
    
    [tempArt loadAudio];
    
    [_articulations addObject:tempArt];
    
    objID = idJawn;
}

//setup audio track with a given drum name
- (void)initializeTrackWithDrum:(NSString*)drum
{
    _drumName=drum;
    _articulations = [[NSMutableArray alloc] init];
    _drumVals = [[NSMutableArray alloc] init];
    isFreeToAlter = true;
    
    //init "bucket" with 0's, could use calloc as well...
    playingAudio = (SInt32*)malloc(512*sizeof(SInt32));
    for(int i = 0; i<512; i++)
    {
        playingAudio[i]=0;
    }
    audiosize = 512;
    
    prevX = 0;
    prevY = 0;
    prevZ = 0;
    maxTap= 0;
    levelIterate = 0;
    useMaxTap = false;
    justTouched = false;
    
}


#pragma mark helper functions

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

-(BOOL) isCymbal
{
    if([_drumName isEqualToString:@"Bright Crash"])
    {
        return true;
    }
    if([_drumName isEqualToString:@"HiHat"])
    {
        return true;
    }

    if([_drumName isEqualToString:@"Dark Crash"])
    {
        return true;
    }

    if([_drumName isEqualToString:@"Ride"])
    {
        return true;
    }

    return false;
}

// An attempt at using the accelerometer.

//- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration {
//    
//    //sumDiff = powf( fabs(acceleration.x-prevX)+ fabs(acceleration.y-prevY) + fabs(acceleration.z-prevZ),2);
//    
//    
//    if(justTouched == true)
//    {
//        NSLog(@"Touched");
//    }
//    
//    
//    sumDiff = fabs(acceleration.z-prevZ);
//    
//    //NSLog(@"%f",sumDiff);
//    
//    prevX = acceleration.x;
//    prevY = acceleration.y;
//    prevZ = acceleration.z;
//    
//    prevX = 1;
//    prevY = 1;
//    prevZ = 1;
//    
//    if(levelIterate>4)
//    {
//        if(sumDiff>maxTap)
//        {
//            useMaxTap = true;
//            maxTap = sumDiff;
////            NSLog(@"MAXTAP: %f",maxTap);
//            //usleep(100000);
//            levelIterate = levelIterate + 1;
//                
//            
//        }
//        
//        if(justTouched == true){
//            [self addAudioData:(SInt32*)mUserData.soundBuffer[1].data onChannel:0 withFrames:mUserData.soundBuffer[1].numFrames withGain:maxTap];
//            levelIterate = 5;
//            maxTap = 0;
//            justTouched = false;
//        }
//        
//        //NSLog(@"%f",maxTap);
//    }
//    else
//    {
//        levelIterate = levelIterate+1;
//    }
//    if(levelIterate>15)
//    {
//        levelIterate = 5;
//        maxTap = 0;
//        
//    }
//    
//}



@end
