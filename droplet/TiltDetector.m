//
//  TiltDetector.m
//  HelloOpenGL
//
//  Created by satoshi on 9/19/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "TiltDetector.h"

@implementation TiltDetector

+ (TiltDetector *) sharedInstance {
    static TiltDetector *s_manager = nil;
    if (!s_manager) {
        s_manager = [[TiltDetector alloc] init]; // retain count = 1
    }
    return s_manager;
}

+(NSString*) didDetectTilt {
    static NSString* s_str = @"didDetectTilt";
    return s_str;
}

-(id) init {
  if (self = [super init]) {
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 0.05;
  }
  return self;
}

-(void) start {
  if (self.motionManager.isDeviceMotionAvailable) {
    [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue currentQueue] withHandler:^(CMDeviceMotion *motion, NSError *error) {
      self.attitude = motion.attitude;
      //NSLog(@"TD start %f, %f, %f", self.attitude.pitch, self.attitude.roll, self.attitude.yaw);
      //NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
      //[center postNotificationName:[TiltDetector didDetectTilt] object:self];
    }];
  }
}

-(void) stop {
  [self.motionManager stopDeviceMotionUpdates];
}

@end
