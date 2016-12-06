//
//  InstrumentView.h
//  GridViewApp
//
//  Created by Tianyun Zhang on 3/23/14.
//  Copyright (c) 2014 Tianyun Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteTimelineView.h"
@interface InstrumentView : UIView
@property (nonatomic,strong) UILabel *instrumentLabel;
@property (nonatomic,strong) NoteTimelineView *noteTimelineView;

-(void)createInstrumentView:(NSString *)instrumentName withTime:(float)time withArticulation:(NSInteger)articulation withIntensity:(NSInteger)intensity withPosition:(NSInteger)position withDynamics:(NSInteger)dynamics;
-(void)resize:(CGRect)rect;

@end
