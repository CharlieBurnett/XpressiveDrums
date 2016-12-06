//
//  GridView.h
//  GridViewApp
//
//  Created by Tianyun Zhang on 3/11/14.
//  Copyright (c) 2014 Tianyun Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstrumentView.h"
@interface GridView : UIScrollView
@property (nonatomic,strong)NSMutableDictionary *instrumentViewDict;
@property (nonatomic,strong)NSMutableArray *instrumentViewDictKeys;
-(void)addNote: (NSString *)instrumentName withTime:(float)time withArticulation:(NSInteger)articulation withIntensity:(NSInteger)intensity withPosition:(NSInteger)position withDynamics:(NSInteger)dynamics;
-(void)resize: (CGRect)rect;
-(void)saveView;
-(void)loadView;
-(void)setDraggableNoteView;
@end
