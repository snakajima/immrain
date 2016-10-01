//
//  OpenGLVideoRecorder.m
//  droplet
//
//  Created by satoshi on 10/7/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OpenGLVideoRecorder.h"
#import "OpenGLBaseShader.h"

@implementation OpenGLVideoRecorder

-(id) initWithSize:(CGSize)size view:(GLKView*)glkView {
    if (self = [super init]) {
        // http://allmybrain.com/2011/12/08/rendering-to-a-texture-with-ios-5-texture-cache-api/
        // http://www.verious.com/qa/open-gl-es-to-video-in-ios-rendering-to-a-texture-with-ios-5-texture-cache/
        // http://mickyd.wordpress.com/2012/05/20/creating-render-to-texture-secondary-framebuffer-objects-on-ios-using-opengl-es-2/
        _size = size;
        /*
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                                 [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                                 [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey,
                                 nil];
        */
        CFDictionaryRef empty; // empty value for attr value.
          CFMutableDictionaryRef attrs;
          empty = CFDictionaryCreate(kCFAllocatorDefault, // our empty IOSurface properties dictionary
              NULL,
              NULL,
              0,
              &kCFTypeDictionaryKeyCallBacks,
              &kCFTypeDictionaryValueCallBacks);
          attrs = CFDictionaryCreateMutable(kCFAllocatorDefault,
              1,
              &kCFTypeDictionaryKeyCallBacks,
              &kCFTypeDictionaryValueCallBacks);
         
          CFDictionarySetValue(attrs,
              kCVPixelBufferIOSurfacePropertiesKey,
              empty);
        CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault,
                                              size.width,
                                              size.height,
                                              kCVPixelFormatType_32BGRA,
                                              NULL, // attrs, // (__bridge CFDictionaryRef) options,
                                              &_pxbuffer);
        if (status != kCVReturnSuccess){
            NSLog(@"Failed to create pixel buffer");
        }        
        glGenFramebuffers(1, &_framebuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
        //glGenRenderbuffers(1, &_colorRenderbuffer);
        //glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
        //glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA, size.width, size.height);
        //glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderbuffer);
        CVOpenGLESTextureCacheCreate(NULL, NULL, glkView.context, NULL, &_textureCache);
        glActiveTexture(GL_TEXTURE3);
        CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, _textureCache, _pxbuffer, NULL, GL_TEXTURE_2D, GL_RGBA, _size.width, _size.height, GL_BGRA, GL_UNSIGNED_BYTE, 0, &_texture);
        glBindTexture(CVOpenGLESTextureGetTarget(_texture), CVOpenGLESTextureGetName(_texture));
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, CVOpenGLESTextureGetName(_texture), 0);
        
        GLenum st = glCheckFramebufferStatus(GL_FRAMEBUFFER) ;
        if(st != GL_FRAMEBUFFER_COMPLETE) {
            NSLog(@"failed to make complete framebuffer object %x", st);
        }

        NSArray* dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* path = [dirPaths[0] stringByAppendingPathComponent:@"output.mp4"];
        NSFileManager* fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:path error:nil];
        NSURL* url = [NSURL fileURLWithPath:path];
        
        _videoWriter = [[AVAssetWriter alloc] initWithURL:url fileType:AVFileTypeQuickTimeMovie error:nil];
        NSDictionary *videoSettings = @{
            AVVideoCodecKey: AVVideoCodecH264,
            AVVideoWidthKey: [NSNumber numberWithInt:size.width],
            AVVideoHeightKey: [NSNumber numberWithInt:size.height]
        };
        _videoWriterInput = [AVAssetWriterInput
                                            assetWriterInputWithMediaType:AVMediaTypeVideo
                                            outputSettings:videoSettings];
        _adaptor = [AVAssetWriterInputPixelBufferAdaptor
                                                     assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoWriterInput
                                                     sourcePixelBufferAttributes:nil];
        _videoWriterInput.expectsMediaDataInRealTime = YES;
        [_videoWriter addInput:_videoWriterInput];
        [_videoWriter startWriting];
        CMTime time = CMTimeMakeWithSeconds(CACurrentMediaTime(), 1000000);
        [_videoWriter startSessionAtSourceTime:time];
        


    }
    return self;
}

-(void) finishWriting {
    [_videoWriterInput markAsFinished];
    [_videoWriter finishWritingWithCompletionHandler:^{
        ;
    }];
}

-(void) render:(GLKView*)glkView shaders:(NSArray*)shaders {
    if (_adaptor.assetWriterInput.readyForMoreMediaData) {
        //glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderbuffer);
        //[glkView.context presentRenderbuffer:GL_RENDERBUFFER];
        //CVPixelBufferLockBaseAddress(_pxbuffer, 0);
        //void *pxdata = CVPixelBufferGetBaseAddress(_pxbuffer);
        //glReadPixels(0, 0, _size.width, _size.height, , GL_UNSIGNED_BYTE, pxdata);
        //CVPixelBufferUnlockBaseAddress(_pxbuffer, 0);
        glBindFramebuffer(GL_FRAMEBUFFER, _framebuffer);
        glActiveTexture(GL_TEXTURE3);
        glBindTexture(CVOpenGLESTextureGetTarget(_texture), CVOpenGLESTextureGetName(_texture));
        //glClearColor(0.333, 0.333, 0.333, 1.0);
        //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        for (OpenGLBaseShader* shader in shaders) {
            [shader render];
        }
        [glkView bindDrawable];
        
        //[glkView.context presentRenderbuffer:GL_RENDERBUFFER];
        
        CMTime time = CMTimeMakeWithSeconds(CACurrentMediaTime(), 1000000);
        BOOL fSuccess = [_adaptor appendPixelBuffer:_pxbuffer withPresentationTime:time];
        if(!fSuccess){
            NSError *error = _videoWriter.error;
            if(error!=nil) {
                NSLog(@"Unresolved error %@,%@.", error, [error userInfo]);
            }
        }
        NSLog(@"OGLR appended %lld", time.value);
    } else {
        NSLog(@"OGLR not ready");
    }
}

- (void) _renderImage:(UIImage*)image {
    
    CGSize size = image.size;
    
    
    CVPixelBufferLockBaseAddress(_pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(_pxbuffer);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width,
                                                 size.height, 8, 4*size.width, rgbColorSpace,
                                                 kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    //kCGImageAlphaNoneSkipFirst);
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, size.width,
                                           size.height), image.CGImage);
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(_pxbuffer, 0);
}
@end
