//
//  GridView.m
//  GridViewApp
//
//  Created by Tianyun Zhang on 3/11/14.
//  Copyright (c) 2014 Tianyun Zhang. All rights reserved.
//

#import "GridView.h"

@implementation GridView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.instrumentViewDict = [[NSMutableDictionary alloc]init];
        self.instrumentViewDictKeys = [[NSMutableArray alloc]init];
        [self setBackgroundColor:[UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1]];
    }
    return self;
}



-(void)awakeFromNib {
    self.instrumentViewDict = [[NSMutableDictionary alloc]init];
    self.instrumentViewDictKeys = [[NSMutableArray alloc]init];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
/*
- (void)drawRect:(CGRect)rect
{
 
}*/

-(void)addInstrument:(NSString *)instrumentName {

        
}

-(void)addNote: (NSString *)instrumentName withTime:(float)time
withArticulation:(NSInteger)articulation
 withIntensity:(NSInteger)intensity
  withPosition:(NSInteger)position
  withDynamics:(NSInteger)dynamics {
    InstrumentView *instrumentView = self.instrumentViewDict[instrumentName];
    
    if(!instrumentView) {
        int rowNum = [self.instrumentViewDictKeys count];
        //New row
        CGRect instrumentViewRect = [self createInstrumentViewRect:self.frame
                                            withPos:[self.instrumentViewDict count]];
        instrumentView = [[InstrumentView alloc] initWithFrame:instrumentViewRect];
        [instrumentView createInstrumentView:instrumentName withTime:time withArticulation:articulation withIntensity:intensity withPosition:position withDynamics:dynamics];
        if(rowNum %2 ==0) {   //odd rows
            instrumentView.backgroundColor =[UIColor colorWithRed:77.0/255.0 green:80.0/255.0 blue:81.0/255.0 alpha:1];
            
        }
        else {
            instrumentView.backgroundColor =[UIColor colorWithRed:60.0f/255.0f green:60.0f/255.0f blue:60.0f/255.0f alpha:1];
        }

        [self addSubview: instrumentView];
        [self.instrumentViewDict setObject:instrumentView forKey:instrumentName];
        [self.instrumentViewDictKeys addObject:instrumentName];
        
        [self setContentSize:(CGSizeMake(self.bounds.size.width, CGRectGetHeight(instrumentViewRect)*
                                                                        [self.instrumentViewDict count]))];
    }
    else {
        [instrumentView.noteTimelineView addNote:time withArticulation:articulation withIntensity:intensity withPosition:position withDynamics:dynamics];
    }
    
    
}

-(void)resize:(CGRect)rect {
    [self setFrame:rect];
    
    for(int i=0;i<[self.instrumentViewDictKeys count];i++) {
        InstrumentView *instrumentView = [self.instrumentViewDict objectForKey:[self.instrumentViewDictKeys objectAtIndex:i]];
        
        CGRect intrumentViewNewRect = [self createInstrumentViewRect:rect withPos:i];
        
        [instrumentView resize:intrumentViewNewRect];
    }
    
    //[self setContentSize:(CGSizeMake(CGRectGetWidth(rect), CGRectGetHeight(rect)*INSTRUMENTVIEW_HEIGHT_PERCENT*[self.instrumentViewDict count]))];
}

const float HEIGHT = 50;
const float FROM_LEFT = 10;
-(CGRect)createInstrumentViewRect:(CGRect)rect withPos:(int)position {
    CGFloat instrumentViewRectWidth = CGRectGetWidth(rect);
    CGFloat instrumentViewRectHeight = HEIGHT/2;
    
    CGFloat instrumentViewRectX = FROM_LEFT/2;
    CGFloat instrumentViewRectY = instrumentViewRectHeight*position;
    CGRect intrumentViewRect = CGRectMake(instrumentViewRectX, instrumentViewRectY, instrumentViewRectWidth, instrumentViewRectHeight);
    return intrumentViewRect;
}

-(void)saveView {
    NSString *text = [self viewToText];
    
    [self writeToFile:text];
}

-(void)loadView {
    NSString *text = [self readFromFile];
    [self textToView:text];
}

-(NSString *)viewToText{
    NSString *text=@"";
    for(int i=0;i<[self.instrumentViewDictKeys count];i++) {
        NSString *instrumentName = [self.instrumentViewDictKeys objectAtIndex:i];
        text = [text stringByAppendingString:instrumentName];
        InstrumentView *instrumentView = [self.instrumentViewDict objectForKey:instrumentName];
        NoteTimelineView *noteTimelineView = instrumentView.noteTimelineView;
        NSMutableArray *noteArray = noteTimelineView.noteArray;
        for(int j=0;j<[noteArray count];j++) {
            NoteView *noteView = [noteArray objectAtIndex:j];
            text = [text stringByAppendingString: [NSString stringWithFormat:@",%f", noteView.time]];
        }
        text = [text stringByAppendingString:@"\n"];
    }
    
    return text;
}
-(void) textToView:(NSString *)text {
    [self removeAllSubViews];
    NSArray *lines = [text componentsSeparatedByString:@"\n"];
    for(int i=0;i<[lines count];i++) {
        NSString *line = lines[i];
        NSArray *components = [line componentsSeparatedByString:@","];
        for(int j=1;j<[components count];j++) {
            //TODO need to change the code here
            //[self addNote:components[0] withTime:[components[j] doubleValue]];
        }
    }
    [self setDraggableNoteView];
    
}
-(void) removeAllSubViews {
    for(int i=0;i<[self.instrumentViewDictKeys count];i++) {
        NSString *instrumentName = [self.instrumentViewDictKeys objectAtIndex:i];
        InstrumentView *instrumentView = [self.instrumentViewDict objectForKey:instrumentName];
        NoteTimelineView *noteTimelineView = instrumentView.noteTimelineView;
        NSMutableArray *noteArray = noteTimelineView.noteArray;
        for(int j=0;j<[noteArray count];j++) {
            NoteView *noteView = [noteArray objectAtIndex:j];
            [noteView removeFromSuperview];
        }
        [noteArray removeAllObjects];
        [noteTimelineView removeFromSuperview];
        [instrumentView removeFromSuperview];
        
    }
    [self.instrumentViewDict removeAllObjects];
    [self.instrumentViewDictKeys removeAllObjects];
}
-(void)writeToFile:(NSString *)text {
    NSString *homeDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = @"gridView.txt";
    NSString *filePath = [homeDirectory stringByAppendingPathComponent:fileName];
    NSError *err;
    
    BOOL success = [text writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&err];
    
    if(!success) {
        NSLog(@"Error writing file at %@\n%@",filePath,[err localizedFailureReason]);
    }
}
-(NSString *)readFromFile {
    NSString *homeDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *fileName = @"gridView.txt";
    NSString *filePath = [homeDirectory stringByAppendingPathComponent:fileName];
    NSError *err;
    NSString *text = [[NSString alloc]initWithContentsOfFile:filePath encoding:YES error:&err];
    return text;
}

-(void)setDraggableNoteView {
    for(int i=0;i<[self.instrumentViewDictKeys count];i++) {
        InstrumentView *instrumentView = [self.instrumentViewDict objectForKey:[self.instrumentViewDictKeys objectAtIndex:i]];
        NoteTimelineView *noteTimelineView = instrumentView.noteTimelineView;
        for(int j=0;j<[noteTimelineView.noteArray count];j++) {
            NoteView *noteView = [noteTimelineView.noteArray objectAtIndex:j];
            UIPanGestureRecognizer *panGR = [[UIPanGestureRecognizer alloc]initWithTarget:noteView action:@selector(onDragged:)];
            [noteView addGestureRecognizer:panGR];
            
        }
    }
}
@end
