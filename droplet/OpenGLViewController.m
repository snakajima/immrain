//
//  OpenGLViewController.m
//
//  Created by Satoshi Nakajima on 9/23/13.
//  Copyright (c) 2013 Satoshi Nakajima. All rights reserved.
//

#import "OpenGLViewController.h"
#import "DropletShaders.h"
#import "TiltDetector.h"
#import "OpenGLVideoRecorder.h"

@interface OpenGLViewController () {
    NSArray* _shaders;
}
@end

@implementation OpenGLViewController

-(id) initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        TiltDetector* detector = [TiltDetector sharedInstance];
        [detector start];
        self.touches = [NSMutableSet set];
    }
    return self;
}

-(UIStatusBarStyle)preferredStatusBarStyle{ 
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.preferredFramesPerSecond = 60.0;
    self.timeElapsed = 0.0;
    
    // Initialize the view's layer
    GLKView* glkView = (GLKView*)self.view;
    glkView.contentScaleFactor = [UIScreen mainScreen].scale;
    CAEAGLLayer* eaglLayer = (CAEAGLLayer*)glkView.layer;
    eaglLayer.opaque = YES;
    eaglLayer.contentsScale = glkView.contentScaleFactor;

    // Initialize the context
    glkView.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!glkView.context || ![EAGLContext setCurrentContext:glkView.context]) {
        NSLog(@"Failed to initialize or set current OpenGL context");
        exit(1);
    }
    glEnable(GL_DEPTH_TEST);

    // Initialize the view's properties
    glkView.drawableDepthFormat = GLKViewDrawableDepthFormat16;
    glkView.drawableMultisample = GLKViewDrawableMultisample4X;

    [self _prepare];
    
    NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(_didAnimationEnd) name:[OpenGLBaseShader didAnimationEnd] object:nil];
}

-(void) _didAnimationEnd {
    [self _prepare];
}

-(void) _prepare {
    CGSize size = self.view.frame.size;
    
    _shaders = nil;

    DropletShaders* shader1 = [[DropletShaders alloc] initWithSize:size];
    
    _shaders = @[shader1];

    // Set the initial projection to all the shaders
    float aspect = size.height / size.width;
    GLKMatrix4 matrix = GLKMatrix4MakeOrtho(0.0, 16.0, 0.0, 16.0 * aspect, 1.0, 100.0);
    for (OpenGLBaseShader* shader in _shaders) {
        shader.delegate = self;
      [shader setProjection:&matrix];
    }
    
    //self.recorder = [[OpenGLVideoRecorder alloc] initWithSize:size view:glkView];
}

-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.recorder finishWriting];
}

// <GLKViewDelegate> method
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    self.timeElapsed = self.timeSinceLastDraw;
    glClearColor(0.333, 0.333, 0.333, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
  
    for (OpenGLBaseShader* shader in _shaders) {
      [shader render];
    }
    
    [self.recorder render:view shaders:_shaders];
}


-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch* touch in touches) {
        [self.touches addObject:touch];
    }
    NSLog(@"OVC touchesBegan %lu", (unsigned long)self.touches.count);
}

-(void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch* touch in touches) {
        [self.touches removeObject:touch];
    }
    NSLog(@"OVC touchesEnd %lu", (unsigned long)self.touches.count);
}

-(void) touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch* touch in touches) {
        [self.touches removeObject:touch];
    }
    NSLog(@"OVC touchesCancelled %lu", (unsigned long)self.touches.count);
}

@end
