//
//  BackgroundShaders.h
//  HelloOpenGL
//
//  Created by satoshi on 9/18/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenGLBaseShader.h"

@interface BackgroundShaders : OpenGLBaseShader {
  GLuint _aPosition, _aTextCoord, _uProjection, _uTextureBlur, _uTextureText, _uTexturePlain, _uMixText, _uMixPlain;
  GLuint _bufVertices, _bufIndices;
  GLuint _uFadeRatio;
}
@property (nonatomic) GLuint textureBackground;
@property (nonatomic) GLuint textureText;
@property (nonatomic) GLuint texturePlain;
@property (nonatomic) GLfloat mixText, mixPlain, fadeRatio;
@end
