//
//  DropletShaders.h
//  HelloOpenGL
//
//  Created by satoshi on 9/18/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "OpenGLBaseShader.h"
#import "Parameters.h"


typedef struct {
    float x;
    float y;
    float r; // radius
    float friction; // friction
    CFTimeInterval t;
} Droplet;

typedef enum {
    DropletStateInitial = 0,
    DropletStateNormal = 1,
    DropletStateClearing = 2,
    DropletStateCleared = 3,
    DropletStateFadingOut = 4,
    DropletStateOver = 5
} DropletState;

@class BackgroundShaders;
@interface DropletShaders : OpenGLBaseShader {
  DropletState _state;
  NSTimeInterval _timeStarted;
  NSTimeInterval _timeCleared;
  NSTimeInterval _timeEmptied;
  NSTimeInterval _timeStartedFading;
  CGSize _size;
  NSUInteger _count;
  Droplet _droplets[DROPLET_COUNT];
  float _aspect;

  GLuint _aPosition;
  //GLuint _aNormal;
  GLuint _uBaseColor;
  GLuint _uProjection;
  GLuint _uModelView, _uNormalModelView;
  GLuint _uRefLightPosition;
  GLuint _bufVertices;
  GLuint _bufIndices[VERTICES_COUNT2];
  GLuint _bufSubdivision;
  GLuint _textureLight, _uLightTexture;
  GLuint _uTextureBlur, _uTextureText, _uTexturePlain;
  GLuint _uCoordMap;
  GLuint _uMixText;
  GLuint _uMixPlain;
  GLuint _uFadeRatio;

  GLuint _phShadow;
  GLuint _bufShadow;
  GLuint _aPositionShadow;
  GLuint _uProjectionShadow;
  GLuint _uModelViewShadow;
  GLuint _uBaseColorShadow;
  GLuint _uTextureShadow;
  GLuint _uTextureTextShadow;
  GLuint _uCoordMapShadow;
  GLuint _uMixOrgShadow;
  GLuint _uMixShadow;
  GLuint _uFadeRatioShadow;
  
  BackgroundShaders* _shaderBackground;
}
@property (nonatomic) GLuint textureBackground;
@property (nonatomic) GLuint textureText;
@property (nonatomic) GLuint texturePlain;
@end
