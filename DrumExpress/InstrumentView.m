//
//  InstrumentView.m
//  GridViewApp
//
//  Created by Tianyun Zhang on 3/23/14.
//  Copyright (c) 2014 Tianyun Zhang. All rights reserved.
//

#import "InstrumentView.h"

@implementation InstrumentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
            }
    return self;
}

-(void)setInstrumentViewBgColor:(int)rowNum {
    
}


const float LABEL_WIDTH = 232;
const float LABEL_HEIGHT = 50;
const float TIMELINE_WIDTH_PERCENT = 0.8;
-(void)createInstrumentView:(NSString *)instrumentName withTime:(float)time
           withArticulation:(NSInteger)articulation
              withIntensity:(NSInteger)intensity
               withPosition:(NSInteger)position
               withDynamics:(NSInteger)dynamics{
    //build a labelView and NoteTimeLineView

    CGRect labelRect = [self createInstrumentLabelRect:self.frame];
    self.instrumentLabel = [[UILabel alloc]initWithFrame:labelRect];
    self.instrumentLabel.textColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:242.0/255.0 alpha:1];
    self.instrumentLabel.text = instrumentName;
    self.instrumentLabel.font = [UIFont systemFontOfSize:12];

    
    
    CGRect noteTimelineViewRect = [self createNoteTimelineViewRect:self.frame];
    self.noteTimelineView = [[NoteTimelineView alloc]initWithFrame:noteTimelineViewRect];
    [self.noteTimelineView addNote:time withArticulation:articulation withIntensity:intensity withPosition:position withDynamics:dynamics ];
    
    
    [self addSubview:self.instrumentLabel];
    [self addSubview:self.noteTimelineView];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

-(void)resize:(CGRect)rect {
    [self setFrame:rect];
    
    CGRect newLabelRect = [self createInstrumentLabelRect:rect];
    [self.instrumentLabel setFrame:newLabelRect];
    
    CGRect newNoteTimelineViewRect = [self createNoteTimelineViewRect:rect];
    [self.noteTimelineView setFrame:newNoteTimelineViewRect];
    [self.noteTimelineView resize:newNoteTimelineViewRect];
}

-(CGRect)createInstrumentLabelRect:(CGRect)rect{
    CGFloat labelRectX = 0;
    CGFloat labelRectY = 0;
    CGFloat labelRectWidth = LABEL_WIDTH/2;  //label width=20% of the total width
    CGFloat labelRectHeight = LABEL_HEIGHT/2;
    CGRect labelRect = CGRectMake(labelRectX, labelRectY, labelRectWidth, labelRectHeight);
    return labelRect;
}

-(CGRect)createNoteTimelineViewRect:(CGRect)rect {
    CGFloat noteTimelineRectX = self.instrumentLabel.frame.size.width+1;
    CGFloat noteTimelineRectY = 0;
    CGFloat noteTimelineRectWidth = CGRectGetWidth(rect)*TIMELINE_WIDTH_PERCENT;
    CGFloat noteTimelineRectHeight = CGRectGetHeight(rect);
    CGRect noteTimeLineRect = CGRectMake(noteTimelineRectX, noteTimelineRectY, noteTimelineRectWidth, noteTimelineRectHeight);
    return noteTimeLineRect;
}

@end
