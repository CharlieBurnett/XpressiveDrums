//
//  NoteTimelineView.h
//  GridViewApp
//
//  Created by Tianyun Zhang on 3/22/14.
//  Copyright (c) 2014 Tianyun Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NoteView.h"
@interface NoteTimelineView : UIView
@property(nonatomic,strong)NSMutableArray *noteArray;
-(void)addNote:(float)time withArticulation:(NSInteger)articulation withIntensity:(NSInteger)intensity withPosition:(NSInteger)position withDynamics:(NSInteger)dynamics;
-(void)resize:(CGRect)rect;
@end
