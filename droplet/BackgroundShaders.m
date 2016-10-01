//
//  BackgroundShaders.m
//  HelloOpenGL
//
//  Created by satoshi on 9/18/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "BackgroundShaders.h"

typedef struct {
    float Position[3];
    float TextCoord[2];
} TextureVertex;

@implementation BackgroundShaders

-(GLuint) textureBackground {
  return _textureBackground;
}

-(id) initWithSize:(CGSize)size {
  if (self = [super initWithVertex:@"TextureVertex.vsh" fragment:@"TextureFragment.fsh"]) {
    glUseProgram(_programHandle);

    _aPosition = glGetAttribLocation(_programHandle, "aPosition");
    _aTextCoord = glGetAttribLocation(_programHandle, "aTextCoord");
    glEnableVertexAttribArray(_aPosition);
    glEnableVertexAttribArray(_aTextCoord);
  
    _uProjection = glGetUniformLocation(_programHandle, "uProjection");
    _uMixText = glGetUniformLocation(_programHandle, "uMixText");
    _uMixPlain = glGetUniformLocation(_programHandle, "uMixPlain");
    _uTextureBlur = glGetUniformLocation(_programHandle, "uTextureBlur");
    _uTextureText = glGetUniformLocation(_programHandle, "uTextureText");
    _uTexturePlain = glGetUniformLocation(_programHandle, "uTexturePlain");
    _uFadeRatio = glGetUniformLocation(_programHandle, "uFadeRatio");

    float h = size.height / size.width;
    const TextureVertex s_vertices[] = {
      { {0.0, 0.0, -11.0}, { 0.0, 1.0 }},
      { {0.0, h * 16.0, -11.0}, { 0.0, 0.0 }},
      { {16.0, h * 16.0, -11.0}, { 1.0, 0.0 }},
      { {16.0, 0.0, -11.0}, { 1.0, 1.0 }}
    };
  
    const static GLushort s_indices[] = {
      1, 0, 2, 3
    };
  
    glGenBuffers(1, &_bufVertices);
    glBindBuffer(GL_ARRAY_BUFFER, _bufVertices);
    glBufferData(GL_ARRAY_BUFFER, sizeof(s_vertices), s_vertices, GL_STATIC_DRAW);

    glGenBuffers(1, &_bufIndices);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufIndices);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(s_indices), s_indices, GL_STATIC_DRAW);
  
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.textureBackground);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glUniform1i(_uTextureBlur, 1);

    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, self.textureText);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glUniform1i(_uTextureText, 2);

    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, self.texturePlain);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glUniform1i(_uTexturePlain, 3);
  }
  return self;
}

-(void) setProjection:(GLKMatrix4*)projection {
    glUseProgram(_programHandle);
    glUniformMatrix4fv(_uProjection, 1, 0, projection->m);
}

-(void) render {
    glUseProgram(_programHandle);
    
    glUniform1f(_uMixText, self.mixText);
    glUniform1f(_uMixPlain, self.mixPlain);
    glUniform1f(_uFadeRatio, self.fadeRatio);

    glBindBuffer(GL_ARRAY_BUFFER, _bufVertices);
    glVertexAttribPointer(_aPosition, 3, GL_FLOAT, GL_FALSE,
        sizeof(TextureVertex), 0);
    glVertexAttribPointer(_aTextCoord, 2, GL_FLOAT, GL_FALSE,
        sizeof(TextureVertex), (GLvoid*) (sizeof(float) * 3));

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufIndices);
    glDrawElements(GL_TRIANGLE_STRIP, 4, GL_UNSIGNED_SHORT, 0);
  
}

-(void) dealloc {
    glDeleteBuffers(1, &_bufVertices);
    glDeleteBuffers(1, &_bufIndices);
}

@end
