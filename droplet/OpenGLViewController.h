//
//  OpenGLViewController.h
//
//  Created by Satoshi Nakajima on 9/23/13.
//  Copyright (c) 2013 Satoshi Nakajima. All rights reserved.
//

#import "OpenGLBaseShader.h"

@class OpenGLVideoRecorder;
@interface OpenGLViewController : GLKViewController <OpenGLBaseShaderDelegate>
@property (nonatomic) NSTimeInterval timeElapsed;
@property (nonatomic) NSMutableSet* touches;
@property (nonatomic) OpenGLVideoRecorder* recorder;
@end
