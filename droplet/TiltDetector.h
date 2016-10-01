//
//  TiltDetector.h
//  HelloOpenGL
//
//  Created by satoshi on 9/19/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TiltDetector : NSObject
@property (nonatomic, strong) CMMotionManager* motionManager;
@property (nonatomic, strong) CMAttitude* attitude;
+ (TiltDetector *) sharedInstance;
+ (NSString*) didDetectTilt;
-(void) stop;
-(void) start;
@end
