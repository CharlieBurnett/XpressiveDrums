//
//  NoteView.m
//  GridViewApp
//
//  Created by Tianyun Zhang on 3/21/14.
//  Copyright (c) 2014 Tianyun Zhang. All rights reserved.
//

#import "NoteView.h"

@implementation NoteView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isDraggable = FALSE;
    }
    return self;
}

- (instancetype)initNote:(CGRect)frame withTime:(float)time
        withArticulation:(NSInteger)articulation
           withIntensity:(NSInteger)intensity
            withPosition:(NSInteger)position
            withDynamics:(NSInteger)dynamics; {
    self = [self initWithFrame:frame];
    UIImage *firstImg = [UIImage imageNamed:@"Outer_1##8"];
    UIImage *secondImg = [UIImage imageNamed:@"Inner_1#28"];
    
    UIImage *image = [self combineTwoImages:firstImg withImage:secondImg];
    
    UIGraphicsBeginImageContext(self.frame.size);
    [image drawInRect:self.bounds];
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    self.backgroundColor = [UIColor colorWithPatternImage:image];
    self.time = time;
    return self;
}

-(void)onDragged:(UIPanGestureRecognizer *)recognizer {
    if (_isDraggable==true) {
        
    
    if (recognizer.state==UIGestureRecognizerStateBegan) {
        self.originalX = self.center.x;
        
    }
    else if( (recognizer.state==UIGestureRecognizerStateChanged) ||
        (recognizer.state==UIGestureRecognizerStateEnded) ) {
        CGPoint translation = [recognizer translationInView:self];
        [self setCenter:CGPointMake(self.center.x+translation.x, self.center.y)];
        
        
        if(recognizer.state==UIGestureRecognizerStateEnded) {
            self.time = (float)self.time*self.center.x/(float)self.originalX;
            //NSLog(@"%f,%f,%f",self.time, self.center.x,self.originalX);
        }
        
        [recognizer setTranslation:CGPointMake(0, 0) inView:self];
        
    }
    }
    
}

-(UIImage *)combineTwoImages:(UIImage *)firstImg withImage:(UIImage*)secondImg {
    
    
    CGSize mergedSize = CGSizeMake(firstImg.size.width,firstImg.size.height);

    //capture image context ref
    UIGraphicsBeginImageContextWithOptions(mergedSize, NO, 0);//(mergedSize);
    
    [firstImg drawInRect:CGRectMake(0, 0, firstImg.size.width, firstImg.size.height)];
    [secondImg drawInRect:CGRectMake(0, 0, secondImg.size.width, secondImg.size.height)];
    
    //assign context to the new image
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //end context
    UIGraphicsEndImageContext();
    
    return newImage;
    
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
/*
\
*/
@end
