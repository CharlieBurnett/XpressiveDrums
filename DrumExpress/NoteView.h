//
//  NoteView.h
//  GridViewApp
//
//  Created by Tianyun Zhang on 3/21/14.
//  Copyright (c) 2014 Tianyun Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteView : UIView
@property(nonatomic)int articulation;
@property(nonatomic)int intensity;
@property(nonatomic)int position;
@property(nonatomic)int dynamics;
@property(nonatomic)float time;
@property(nonatomic)float originalX;
@property(nonatomic)BOOL isDraggable;
- (instancetype)initNote:(CGRect)frame withTime:(float)time withArticulation:(NSInteger)articulation withIntensity:(NSInteger)intensity withPosition:(NSInteger)position withDynamics:(NSInteger)dynamics;
- (void)onDragged:(UIPanGestureRecognizer*)recognizer;
@end
