//
//  Articulation.m
//  Xpressive
//
//  Created by Matthew Prockup on 4/14/13.
//  Copyright (c) 2013 Xpressive Instruments. All rights reserved.
//

#import "Articulation.h"

@implementation Articulation
#pragma mark -
#pragma mark Initialize

-(void) initArticulation:(NSString*)art forDrum:(NSString*) drum withSnares:(int)snOn{
    _drumName = drum;
    _articulation = art;
    _snaresOn = snOn;
}


-(void)  setExpressiveRangePositions:(int) pos forIntensity:(int) intense forHeight:(int) hei forExamples:(int) examps;
{
    _numPosition = pos;
    _numIntensity = intense;
    _numHeight = hei;
    _numExamples = examps;
}

-(void)  setExpressiveRangeForIntensity:(int) intense forHeight:(int) hei forExamples:(int) examps;
{
    _numPosition = -1;
    _numIntensity = intense;
    _numHeight = hei;
    _numExamples = examps;
}


#pragma mark -
#pragma mark Audio Content

-(void) loadAudio{
    _expressions = [[NSMutableDictionary alloc] init];
    
    
    if(_snaresOn>-1)
    {
    
        for(int i = 1;i<=_numIntensity; i++)
        {
            for(int p = 1;p<=_numPosition; p++)
            {
                for(int h = 1;h<=_numHeight; h++)
                {
                    for(int e = 1;e<=_numExamples; e++)
                    {
                        NSString* fileName = [[NSString alloc] initWithFormat:@"MN_%@_%@_%d%d%d%d.%d",_drumName,_articulation,_snaresOn,i,p,h,e];
                        NSLog(@"%@",fileName);
                        
                        AudioSample* tempSample = [[AudioSample alloc]init];
                        [tempSample  initSampleFile:fileName forDrum:_drumName withArticulation: _articulation];
                        [tempSample setExpressionForPosition:p forIntensity:i forHeight:h forExamples:e];
                        [tempSample setMaxExpressionsNums:4 forPosition:_numPosition forIntensity:_numIntensity forHeight:_numHeight forExamples:_numExamples];
                        [tempSample loadAudio];
                        
                        NSString* tempKey = [[NSString alloc] initWithFormat:@"%d%d%d%d.%d",_snaresOn,i,p,h,e];
                        [_expressions setObject:tempSample forKey:tempKey];
                    }
                    
                }
                
            }
        }
        
    }
    
    else if(_numPosition>-1)
    {
        
        for(int i = 1;i<=_numIntensity; i++)
        {
            for(int p = 1;p<=_numPosition; p++)
            {
                for(int h = 1;h<=_numHeight; h++)
                {
                    for(int e = 1;e<=_numExamples; e++)
                    {
                        NSString* fileName = [[NSString alloc] initWithFormat:@"MN_%@_%@_%d%d%d.%d",_drumName,_articulation,i,p,h,e];
                        NSLog(@"%@",fileName);
                        
                        AudioSample* tempSample = [[AudioSample alloc]init];
                        [tempSample  initSampleFile:fileName forDrum:_drumName withArticulation: _articulation];
                        [tempSample setExpressionForPosition:p forIntensity:i forHeight:h forExamples:e];
                        [tempSample setMaxExpressionsNums:4 forPosition:_numPosition forIntensity:_numIntensity forHeight:_numHeight forExamples:_numExamples];
                        [tempSample loadAudio];
                        
                        NSString* tempKey = [[NSString alloc] initWithFormat:@"%d%d%d.%d",i,p,h,e];
                        [_expressions setObject:tempSample forKey:tempKey];
                    }
                    
                }
                
            }
        }
        
    }
    
    else
    {
        
        for(int i = 1;i<=_numIntensity; i++)
        {
            for(int h = 1;h<=_numHeight; h++)
            {
                for(int e = 1;e<=_numExamples; e++)
                {
                    NSString* fileName = [[NSString alloc] initWithFormat:@"MN_%@_%@_%d%d.%d",_drumName,_articulation,i,h,e];
                    NSLog(@"%@",fileName);
                    
                    AudioSample* tempSample = [[AudioSample alloc]init];
                    [tempSample  initSampleFile:fileName forDrum:_drumName withArticulation: _articulation];
                    [tempSample setExpressionForPosition:_numPosition forIntensity:i forHeight:h forExamples:e];
                    [tempSample setMaxExpressionsNums:4 forPosition:_numPosition forIntensity:_numIntensity forHeight:_numHeight forExamples:_numExamples];
                    [tempSample loadAudio];
                    
                    NSString* tempKey = [[NSString alloc] initWithFormat:@"%d%d.%d",i,h,e];
                    [_expressions setObject:tempSample forKey:tempKey];
                }
            }
        }
    }
    
    
    NSLog(@"Loading Articulation: %@",_articulation);

}


-(SInt32*) getSampleDataWithKey:(NSString*)keyJawn
{
    AudioSample* tempSample = (AudioSample*)[_expressions objectForKey:keyJawn];
    SInt32* buffer = [tempSample getSampleData];
    //NSLog(@"%ld", buffer[0]);
    return buffer;
}

-(AudioSample*) getAudioSampleWithKey:(NSString*)keyJawn
{
    return (AudioSample*)[_expressions objectForKey:keyJawn];
}


#pragma mark -
#pragma access methods

-(NSString*) getDrumName{
    return _drumName;
}

-(NSString*) getArticulation{
    return _articulation;
}

-(int) getNumPosition{
    return _numPosition;
}

-(int) getNumIntensity{
    return _numIntensity;
}

-(int) getNumHeight{
    return _numHeight;
}

-(int) getNumExamples{
    return _numExamples;
}

-(BOOL) getSnaresOn{
    return _snaresOn;
}


@end
