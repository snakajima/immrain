//
//  OpenGLBaseShader.h
//
//  Created by Satoshi Nakajima on 9/18/13.
//  Copyright (c) 2013 Satoshi Nakajima. All rights reserved.
//

@protocol OpenGLBaseShaderDelegate <NSObject>
@property (nonatomic) NSTimeInterval timeElapsed;
@property (nonatomic) NSMutableSet* touches;
@property (nonatomic, readonly) UIView* view;
@end

@interface OpenGLBaseShader : NSObject {
    GLuint _programHandle;
}
@property (nonatomic, assign) id <OpenGLBaseShaderDelegate> delegate;
+(GLuint) compileAndLinkShader:(NSString*)nameVertex fragment:(NSString*)nameFragment;
+(NSString*) didAnimationEnd;
-(id) initWithVertex:(NSString*)nameVertex fragment:(NSString*)nameFragment;
-(id) initWithSize:(CGSize)size;
-(void) setProjection:(GLKMatrix4*)projection;
-(void) render;
@end
