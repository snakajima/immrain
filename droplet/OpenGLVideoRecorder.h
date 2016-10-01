//
//  OpenGLVideoRecorder.h
//  droplet
//
//  Created by satoshi on 10/7/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenGLVideoRecorder : NSObject {
    CGSize _size;
    AVAssetWriter* _videoWriter;
    AVAssetWriterInput* _videoWriterInput;
    AVAssetWriterInputPixelBufferAdaptor *_adaptor;
    
    CVPixelBufferRef _pxbuffer;
    GLuint _framebuffer;
    CVOpenGLESTextureCacheRef _textureCache;
    CVOpenGLESTextureRef _texture;
}
-(id) initWithSize:(CGSize)size view:(GLKView*)glkView;
-(void) finishWriting;
-(void) render:(GLKView*)glkView shaders:(NSArray*)shaders;

@end
