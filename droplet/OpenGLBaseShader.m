//
//  OpenGLBaseShader.m
//
//  Created by Satoshi Nakajima on 9/18/13.
//  Copyright (c) 2013 Satoshi Nakajima. All rights reserved.
//

#import "OpenGLBaseShader.h"

@implementation OpenGLBaseShader

+(NSString*) didAnimationEnd {
    static NSString* s_string = @"didAnimationEnd";
    return s_string;
}

// To be implemented by a subclass
-(id) initWithSize:(CGSize)size {
    return nil;
}

// To be called from subclass's initWithSide: method
-(id) initWithVertex:(NSString*)nameVertex fragment:(NSString*)nameFragment {
    if (self = [super init]) {
        _programHandle = [OpenGLBaseShader compileAndLinkShader:nameVertex fragment:nameFragment];
    }
    return self;
}

// A subclass may call this method to create additional programs.
+(GLuint) compileAndLinkShader:(NSString*)nameVertex fragment:(NSString*)nameFragment {
    GLuint vs = [OpenGLBaseShader _compileShader:nameVertex withType:GL_VERTEX_SHADER];
    GLuint fs = [OpenGLBaseShader _compileShader:nameFragment withType:GL_FRAGMENT_SHADER];

    GLuint handle = glCreateProgram();
    glAttachShader(handle, vs);
    glAttachShader(handle, fs);
    glLinkProgram(handle);
    glDeleteShader(vs);
    glDeleteShader(fs);

    GLint linkSuccess;
    glGetProgramiv(handle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
      GLchar messages[256];
      glGetProgramInfoLog(handle, sizeof(messages), 0, &messages[0]);
      NSString *messageString = [NSString stringWithUTF8String:messages];
      NSLog(@"%@", messageString);
      exit(1);
    }
    return handle;
}

// A private helper method to compile a shader
+(GLuint) _compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:nil];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath 
        encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
        NSLog(@"Error loading shader(%@): %@", shaderName, error.localizedDescription);
        exit(1);
    }
 
    GLuint shaderHandle = glCreateShader(shaderType);
 
    const char * shaderStringUTF8 = [shaderString UTF8String];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, NULL);
    glCompileShader(shaderHandle);
 
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
 
    return shaderHandle;
 
}

// To be implemented by a subclass
-(void) setProjection:(GLKMatrix4*)projection {
}

// To be implemented by a subclass
-(void) render {
}

-(void) dealloc {
    glDeleteProgram(_programHandle);
}
@end
