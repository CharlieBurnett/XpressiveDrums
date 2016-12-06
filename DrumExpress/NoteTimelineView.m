//
//  NoteTimelineView.m
//  GridViewApp
//
//  Created by Tianyun Zhang on 3/22/14.
//  Copyright (c) 2014 Tianyun Zhang. All rights reserved.
//

#import "NoteTimelineView.h"

@implementation NoteTimelineView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //Draw the line from leftmost to the right most of noteTimelineView
        [self setNeedsDisplay];
        self.noteArray = [[NSMutableArray alloc]init];
        self.opaque=0;
    }
    return self;
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*- (void)drawRect:(CGRect)rect
{
    CGFloat lineStartX = 0;
    CGFloat lineEndX = self.bounds.size.width;
    CGFloat lineY = self.bounds.size.height/2;
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(lineStartX, lineY)];
    [linePath addLineToPoint:CGPointMake(lineEndX, lineY)];
    [linePath stroke];
}*/

const float NOTE_HEIGHT = 40;
const float NOTE_WIDTH = 11;
-(void)addNote:(float)time withArticulation:(NSInteger)articulation
 withIntensity:(NSInteger)intensity withPosition:(NSInteger)position
  withDynamics:(NSInteger)dynamics {
    CGRect noteRect = [self createNoteViewRect:self.frame withTime:time];
    
    NoteView *noteView = [[NoteView alloc] initNote:noteRect withTime:time withArticulation:articulation withIntensity:intensity withPosition:position withDynamics:dynamics];
    [self addSubview:noteView];
    [self.noteArray addObject:noteView];
}

-(void)resize:(CGRect)rect {
    [self setFrame:rect];
    
    for(int i=0;i<[self.noteArray count];i++) {
        NoteView *noteView = [self.noteArray objectAtIndex:i];
        CGRect newNoteViewRect = [self createNoteViewRect:rect withTime:noteView.time];
        [noteView setFrame:newNoteViewRect];
    }
}

-(CGRect)createNoteViewRect:(CGRect)rect withTime:(float)time{
    CGFloat noteRectWidth = NOTE_WIDTH/2;
    CGFloat noteRectHeight = NOTE_HEIGHT/2;
    CGFloat noteRectX = (CGRectGetWidth(rect)*time)-(noteRectWidth/2);
    CGFloat noteRectY = (CGRectGetHeight(rect)-noteRectHeight)/2;
    CGRect noteRect = CGRectMake(noteRectX, noteRectY, noteRectWidth, noteRectHeight);
    return noteRect;
}
@end
