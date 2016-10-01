//
//  DropletShaders.m
//  HelloOpenGL
//
//  Created by satoshi on 9/18/13.
//  Copyright (c) 2013 satoshi. All rights reserved.
//

#import "DropletShaders.h"
#import "OpenGLBaseShader.h"
#import "TiltDetector.h"
#import "BackgroundShaders.h"


@implementation DropletShaders : OpenGLBaseShader

-(id) initWithSize:(CGSize)size {
  if (self = [super initWithVertex:@"DropletShader.vsh" fragment:@"DropletShader.fsh"]) {
    _size = size;
    
    glUseProgram(_programHandle);
    _aPosition = glGetAttribLocation(_programHandle, "aPosition");
    //_aNormal = glGetAttribLocation(_programHandle, "aNormal");
    glEnableVertexAttribArray(_aPosition);
    //glEnableVertexAttribArray(_aNormal);
  
    _uProjection = glGetUniformLocation(_programHandle, "uProjection");
    _uBaseColor = glGetUniformLocation(_programHandle, "uBaseColor");
    _uModelView = glGetUniformLocation(_programHandle, "uModelview");
    _uNormalModelView = glGetUniformLocation(_programHandle, "uNormalizeModelview");
    _uRefLightPosition = glGetUniformLocation(_programHandle, "uRefLightPosition");
    _uLightTexture = glGetUniformLocation(_programHandle, "uLightTexture");
    _uCoordMap = glGetUniformLocation(_programHandle, "uCoordMap");
    _uTextureBlur = glGetUniformLocation(_programHandle, "uTextureBlur");
    _uTextureText = glGetUniformLocation(_programHandle, "uTextureText");
    _uTexturePlain = glGetUniformLocation(_programHandle, "uTexturePlain");
    _uMixText = glGetUniformLocation(_programHandle, "uMixText");
    _uMixPlain = glGetUniformLocation(_programHandle, "uMixPlain");
    _uFadeRatio = glGetUniformLocation(_programHandle, "uFadeRatio");

    [self _setupCubeTexture];
    [self _setupDroplets];

    _aspect = 1.0 * size.height / size.width;
    _count = 0;
    for (int i=0; i<DROPLET_COUNT; i++) {
        float t = (arc4random() % 100) / 100.0;
        float x = (arc4random() % 1000) / 1000.0 * 16.0;
        float y = (arc4random() % 1000) / 1000.0 * 16.0;
        float friction = FRICTION_BASE / (1.0 + 1.0 * (arc4random() % 10) / 10.0);
        Droplet droplet = {
            x, y * _aspect,
            DROPLET_SIZE_MIN + DROPLET_SIZE_VAR * powf(t, 3.0),
            friction
        };
        _droplets[_count++] = droplet;
    }
    [self _detectCollisions:YES];

    glUseProgram(_phShadow);
    _phShadow = [OpenGLBaseShader compileAndLinkShader:@"ShadowVertex.vsh" fragment:@"ShadowFragment.fsh"];
    _aPositionShadow = glGetAttribLocation(_phShadow, "aPosition");
    glEnableVertexAttribArray(_aPositionShadow);
    _uProjectionShadow = glGetUniformLocation(_phShadow, "uProjection");
    _uModelViewShadow = glGetUniformLocation(_phShadow, "uModelview");
    _uBaseColorShadow = glGetUniformLocation(_phShadow, "uBaseColor");
    _uTextureShadow = glGetUniformLocation(_phShadow, "uTextureBlur");
    _uTextureTextShadow = glGetUniformLocation(_phShadow, "uTextureText");
    _uCoordMapShadow = glGetUniformLocation(_phShadow, "uCoordMap");
    _uMixShadow = glGetUniformLocation(_phShadow, "uMixShadow");
    _uMixOrgShadow = glGetUniformLocation(_phShadow, "uMixOrg");
    _uFadeRatioShadow = glGetUniformLocation(_phShadow, "uFadeRatio");

    // Load the original texture
    NSError* err = nil;
    NSDictionary* info = [[NSBundle mainBundle] infoDictionary];
    NSArray* quotes = [info objectForKey:@"DropletQuotes"];
    NSUInteger index = arc4random() % quotes.count;
    NSString* str = [quotes objectAtIndex:index];
    str = [str stringByReplacingOccurrencesOfString:@"\\n" withString:@"\n"];

    NSArray* images = [info objectForKey:@"DropletImages"];
    NSUInteger indexI = arc4random() % images.count;
    NSString* imageName = [images objectAtIndex:indexI];
    
    NSString* filePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"jpg"];
#if 1
    UIImage* image = [UIImage imageNamed:filePath.lastPathComponent];
    UIGraphicsBeginImageContext(image.size);
    //CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect rc = { 0.0, 0.0, image.size.width, image.size.height };
    [image drawInRect:rc];
    UIImage* imagePlain = UIGraphicsGetImageFromCurrentImageContext();
    
    NSMutableParagraphStyle* pstyle = [[NSMutableParagraphStyle alloc] init];
    pstyle.alignment = NSTextAlignmentLeft;
    pstyle.paragraphSpacing = TEXT_PARAGRAPH_SPACING;
    NSShadow *textShadow = [[NSShadow alloc] init];
    textShadow.shadowColor = [UIColor blackColor];
    textShadow.shadowBlurRadius = TEXT_SHADOW_RADIUS;
    textShadow.shadowOffset = CGSizeMake(TEXT_SHADOW_OFFSET, TEXT_SHADOW_OFFSET);

    NSDictionary* attr = @{
        NSForegroundColorAttributeName: [UIColor whiteColor],
        NSFontAttributeName: [UIFont systemFontOfSize:TEXT_FONT_SIZE],
        NSParagraphStyleAttributeName: pstyle,
        NSShadowAttributeName: textShadow
        };
    NSAttributedString* strAttr = [[NSAttributedString alloc] initWithString:str attributes:attr];
    CGRect rcBound = { rc.size.width * TEXT_PARAGRAPH_INDENT, 0.0, rc.size.width * TEXT_PARAGRAPH_WIDTH, MAXFLOAT};
    rcBound = [strAttr boundingRectWithSize:rcBound.size options:NSLineBreakByWordWrapping | NSStringDrawingUsesLineFragmentOrigin context:nil];
    rcBound.origin.x = rc.size.width * TEXT_PARAGRAPH_INDENT;
    rcBound.origin.y = (image.size.height - rcBound.size.height) / 2.0;
    [strAttr drawInRect:rcBound];

    UIImage* imageText = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // http://stackoverflow.com/questions/8611063/glktextureloader-fails-when-loading-a-certain-texture-the-first-time-but-succee
    glGetError(); // dummy call to get around the bug
    
    GLKTextureInfo* textureText = [GLKTextureLoader textureWithCGImage:imageText.CGImage options:nil error:&err];
    if (err) {
        NSLog(@"DS textureText %@", err);
    }
    GLKTextureInfo* texturePlain = [GLKTextureLoader textureWithCGImage:imagePlain.CGImage options:nil error:&err];
    if (err) {
        NSLog(@"DS texturePlain %@", err);
    }
#else
    GLKTextureInfo* textureText = [GLKTextureLoader textureWithContentsOfFile:filePath options:nil error:&err];
    if (err) {
        NSLog(@"DS textureText %@", err);
    }
#endif
    CIContext *context = [CIContext contextWithOptions:nil];

    // Generate the smoke-glassed texture
    CIImage* imageOrg = [CIImage imageWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
    CIFilter *filter0 = [CIFilter filterWithName:@"CIAffineClamp"];
    [filter0 setValuesForKeysWithDictionary:@{
        kCIInputImageKey:imageOrg
    }];
    CIFilter *filter1 = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter1 setValuesForKeysWithDictionary: @{
        kCIInputImageKey:filter0.outputImage,
        @"inputRadius":@SMOKING_GAUSSIAN_RADIUS
    }];
    CIFilter *filter2 = [CIFilter filterWithName:@"CIColorControls"];
    [filter2 setValuesForKeysWithDictionary: @{
        kCIInputImageKey:filter1.outputImage,
        @"inputBrightness" : @SMOKING_BLIGHTNESS,
        @"inputSaturation" : @SMOKING_SATURATION
    }];
    CIImage *result = filter2.outputImage;
    CGImageRef cgImage = [context createCGImage:result fromRect:imageOrg.extent];

    // HACK: For some reason, it does not work with cgImage directly.
    NSData* data = UIImagePNGRepresentation([UIImage imageWithCGImage:cgImage]);
    CGImageRelease(cgImage);
    cgImage = [UIImage imageWithData:data].CGImage;
    
    GLKTextureInfo* texture = [GLKTextureLoader textureWithCGImage:cgImage options:nil error:&err];
    if (err) {
        NSLog(@"DS texture %@", err);
    }

    self.textureBackground = texture.name;
    self.textureText = textureText.name;
    self.texturePlain = texturePlain.name;

    _shaderBackground= [[BackgroundShaders alloc] initWithSize:size];
    _shaderBackground.textureBackground = texture.name;
    _shaderBackground.textureText = textureText.name;
    _shaderBackground.texturePlain = texturePlain.name;
    _shaderBackground.mixPlain = 0.0;
    _shaderBackground.mixText = 0.0;
    _shaderBackground.fadeRatio = 0.0;
    _state = DropletStateInitial;
    _timeStarted = CACurrentMediaTime();
  }
  return self;
}

-(void) _checkCount {
    if (_count == 1) {
        _state = DropletStateClearing;
        _timeCleared = CACurrentMediaTime();
        _timeEmptied = _timeCleared + 10000.0;
    } else if (_count == 0) {
        _timeEmptied = CACurrentMediaTime();
    }
}

-(void) _detectCollisions:(BOOL)first {
    int i=0;
    while (i<_count) {
        Droplet droplet0 = _droplets[i];
        if (droplet0.x - droplet0.r > 16.0 || droplet0.x + droplet0.r < 0.0) {
            //NSLog(@"collision side %lu", (unsigned long)_count);
            _droplets[i] = _droplets[_count-1];
            _count--;
            [self _checkCount];
            continue;
        }
        if (droplet0.y + droplet0.r < 0.0 || droplet0.y - droplet0.r > 16.0 * _aspect) {
            //NSLog(@"collision high/low %lu", (unsigned long)_count);
            _droplets[i] = _droplets[_count-1];
            _count--;
            [self _checkCount];
            continue;
        }
        for (int j=i+1; j<_count; j++) {
            Droplet droplet1 = _droplets[j];
            float dx = (droplet1.x - droplet0.x) / XRATIO;
            float dy = droplet1.y - droplet0.y;
            float d = sqrtf(dx*dx + dy*dy);
            if (d < droplet0.r + droplet1.r) {
                //NSLog(@"collision detected %d", _count);
                float w0 = powf(droplet0.r, 3.0);
                float w1 = powf(droplet1.r, 3.0);
                droplet0.r = powf(w0 + w1, 1.0/3.0);
                float t = w1 / (w0 + w1);
                droplet0.x += t * dx * XRATIO;
                droplet0.y += t * dy;
                if (!first) {
                    droplet0.friction = FRICTION_MIN + FRICTION_VAR / powf(droplet0.r * 4.0, 2.0);
                    //NSLog(@"friction = %f", droplet0.friction);
                }
                droplet0.t = CACurrentMediaTime();
                _droplets[i] = droplet0;
                _droplets[j] = _droplets[_count-1];
                _count--;
                [self _checkCount];
            }
        }
        i++;
    }
}

typedef struct {
    float Position[3];
} Vertex;

-(void) _prepareVertices:(Vertex*)pvertices offset:(int)offset
      from:(float)angle {
    float r = cosf(angle);
    float h = sinf(angle);
  
    for (int i=0; i < VERTICES_COUNT; i++) {
      pvertices[i].Position[0] = r * cosf(M_PI / VERTICES_COUNT * (2 * i + offset));
      pvertices[i].Position[1] = r * sinf(M_PI / VERTICES_COUNT * (2 * i + offset));
      pvertices[i].Position[2] = h;
    }
}

- (void)_setupDroplets {
    // Droplet vertices
    glGenBuffers(1, &_bufVertices);
    glBindBuffer(GL_ARRAY_BUFFER, _bufVertices);

    // Vertices for the droplet
    Vertex vertices[VERTICES_COUNT*(VERTICES_COUNT2+2)];
    for (int index=0; index<VERTICES_COUNT2+1; index++) {
      [self _prepareVertices:vertices + index * VERTICES_COUNT offset:0 from:index * M_PI / VERTICES_COUNT];
    }
    // Subdivision vertices (around the droplet - it is a bit lazy implementation, but works)
    [self _prepareVertices:vertices + VERTICES_COUNT * (VERTICES_COUNT2+1) offset:1 from:0.0];

    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    // Droplet strips
    for (int index=0; index<VERTICES_COUNT2; index++) {
      GLushort indices[VERTICES_COUNT*2+2];
      glGenBuffers(1, _bufIndices+index);
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufIndices[index]);
      for (int i=0; i<VERTICES_COUNT; i++) {
        indices[i*2] = i + VERTICES_COUNT * index;
        indices[i*2+1] = i + VERTICES_COUNT * (index+1);
      }
      indices[VERTICES_COUNT*2] = VERTICES_COUNT * index;
      indices[VERTICES_COUNT*2+1] = VERTICES_COUNT * (index+1);
      glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    }
    // Subdivision strip
    glGenBuffers(1, &_bufSubdivision);
      glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufSubdivision);
    GLushort indicesS[VERTICES_COUNT*3];
    for (int i=0; i<VERTICES_COUNT; i++) {
        indicesS[i*3] = i;
        indicesS[i*3+1] = i + VERTICES_COUNT * (VERTICES_COUNT2+1);
        indicesS[i*3+2] = (i+1) % VERTICES_COUNT;
    }
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indicesS), indicesS, GL_STATIC_DRAW);
  
    // Shade fan
    glGenBuffers(1, &_bufShadow);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufShadow);
    GLushort indices[VERTICES_COUNT*2+2];
    indices[0] = VERTICES_COUNT * VERTICES_COUNT2;
    for (int i=0; i<VERTICES_COUNT; i++) {
      indices[1+i*2] = i % VERTICES_COUNT;
      indices[2+i*2] = i % VERTICES_COUNT + VERTICES_COUNT * (VERTICES_COUNT2+1);
    }
    indices[VERTICES_COUNT * 2 + 1] = 0;
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
  
}

-(void) setProjection:(GLKMatrix4*)projection {
    float colors[] = {
        32.0/255.0,
        45.0/255.0,
        54.0/255.0,
        1.0
    };
    glUseProgram(_programHandle);
    glUniform4fv(_uBaseColor, 1, colors);
    
    
    glUniformMatrix4fv(_uProjection, 1, 0, projection->m);
    glUniform3f(_uRefLightPosition, 0.25, -0.7, 0.2);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_CUBE_MAP, _textureLight);
    glUniform1i(_uLightTexture, 0);

    glBindBuffer(GL_ARRAY_BUFFER, _bufVertices);
    glVertexAttribPointer(_aPosition, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    //glVertexAttribPointer(_aNormal, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);
    glUniform2f(_uCoordMap,
        1.0 / 16.0,
        1.0 / 16.0 * _size.width / _size.height);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.textureBackground);
    glUniform1i(_uTextureBlur, 1);
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, self.textureText);
    glUniform1i(_uTextureText, 2);
    glActiveTexture(GL_TEXTURE3);
    glBindTexture(GL_TEXTURE_2D, self.texturePlain);
    glUniform1i(_uTexturePlain, 3);
    glUniform1f(_uMixText, 0.0);
    glUniform1f(_uFadeRatio, 1.0);

    glUseProgram(_phShadow);
    glUniform4fv(_uBaseColorShadow, 1, colors);
    glUniformMatrix4fv(_uProjectionShadow, 1, 0, projection->m);
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, self.textureBackground);
    glUniform1i(_uTextureShadow, 1);
    glActiveTexture(GL_TEXTURE2);
    glBindTexture(GL_TEXTURE_2D, self.textureText);
    glUniform1i(_uTextureTextShadow, 2);
    glUniform1f(_uMixShadow, 0.4);
    glUniform1f(_uMixOrgShadow, 0.0);
    glUniform1f(_uFadeRatioShadow, 1.0);
    
    glUniform2f(_uCoordMapShadow,
        1.0 / 16.0,
        1.0 / 16.0 * _size.width / _size.height);

    [_shaderBackground setProjection:projection];
}

-(void) render {
    float fUntiGravity = 0.0;
    CGPoint ptTouch = { -1000.0, -1000.0 };
    if (self.delegate.touches.count == 1) {
        fUntiGravity = -1.0;
        for (UITouch* touch in self.delegate.touches) {
            ptTouch = [touch locationInView:self.delegate.view];
            ptTouch.x = 16.0 * ptTouch.x / _size.width;
            ptTouch.y = 16.0 * (_size.height - ptTouch.y) / _size.width;
            //NSLog(@"DS:render pt=%.2f,%.2f", ptTouch.x, ptTouch.y);
        }
        
        if (_count==0 && _state == DropletStateCleared) {
            NSLog(@"*** TOUCHED");
            _state = DropletStateFadingOut;
            _timeStartedFading = CACurrentMediaTime();
        }
    }
    TiltDetector* detector = [TiltDetector sharedInstance];
    float vy = -V_GRAVITY * sin(detector.attitude.pitch);
    float vx = V_GRAVITY * sin(detector.attitude.roll);
#if TARGET_IPHONE_SIMULATOR
    vy = -100.0;
#endif

    // Adjust positions first
    for (int index=0; index<_count; index++) {
        Droplet* pdroplet = &_droplets[index];
        float dx = pdroplet->x - ptTouch.x;
        float dy = pdroplet->y - ptTouch.y;
        float r2 = dx*dx + dy*dy;
        float r2Drop = powf(pdroplet->r, 2.0);
        if (r2 < r2Drop + kTouchMargin) {
            r2 = r2Drop;
            pdroplet->t = CACurrentMediaTime();
            pdroplet->x -= dx/2.0;
            pdroplet->y -= dy/2.0;
        } else {
            float gx = fUntiGravity * dx / sqrt(r2) / r2;
            float gy = fUntiGravity * dy / sqrt(r2) / r2;
            pdroplet->x += self.delegate.timeElapsed * (vx / pdroplet->friction + gx);
            pdroplet->y += self.delegate.timeElapsed * (vy / pdroplet->friction + gy);
        }
    }
    [self _detectCollisions:NO];

    glUseProgram(_phShadow);
    glBindBuffer(GL_ARRAY_BUFFER, _bufVertices);
    glVertexAttribPointer(_aPositionShadow, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0);

    glUseProgram(_programHandle);
    if (_state == DropletStateInitial) {
        GLfloat fadeRatio = 1.0;
        GLfloat timer = CACurrentMediaTime() - _timeStarted;
        if (timer < TIMING_FADE_IN) {
            fadeRatio = timer / TIMING_FADE_IN;
        } else {
            _state = DropletStateNormal;
        }
        _shaderBackground.fadeRatio = fadeRatio;
        glUniform1f(_uFadeRatio, fadeRatio);
        glUseProgram(_phShadow);
        glUniform1f(_uFadeRatioShadow, fadeRatio);
    } else if (_state == DropletStateClearing) {
        GLfloat mixPlain = 1.0;
        GLfloat mixText = 1.0;
        GLfloat timer = CACurrentMediaTime() - _timeCleared;
        if (timer < TIMING_CLEAR_BLUR) {
            mixPlain = timer/TIMING_CLEAR_BLUR;
            mixText = 0.0;
        } else {
            if (timer < TIMING_CLEAR_ALL) {
                mixText = (timer - TIMING_SHOW_TEXT_BEGIN) / TIMING_SHOW_TEXT_DURATION;
            } else {
                _state = DropletStateCleared;
            }
        }
        _shaderBackground.mixPlain = mixPlain;
        _shaderBackground.mixText = mixText;
        glUniform1f(_uMixText, mixText);
        glUniform1f(_uMixPlain, mixPlain);
        
        glUseProgram(_phShadow);
        //NSLog(@"_uMixShadow = %f", 0.4 * (1.0-mixText));
        glUniform1f(_uMixShadow, 0.4 * (1.0-mixText));
        glUniform1f(_uMixOrgShadow, mixText);
    } else if (_state == DropletStateCleared) {
        float timer = CACurrentMediaTime() - _timeEmptied;
        if (timer >= TIMING_AUTO_SWITCH) {
            _state = DropletStateFadingOut;
            _timeStartedFading = CACurrentMediaTime();
            NSLog(@"DS ### TIMEOUT ###");
        }
    } else if (_state == DropletStateFadingOut) {
        float fadeRatio = 0.0;
        float timer = CACurrentMediaTime() - _timeStartedFading;
        if (timer < TIMING_FADE_OUT) {
            fadeRatio = 1.0 - timer / TIMING_FADE_OUT;
        } else {
            _state = DropletStateOver;
            NSNotificationCenter* center = [NSNotificationCenter defaultCenter];
            [center postNotificationName:[OpenGLBaseShader didAnimationEnd] object:self];
        }
        _shaderBackground.fadeRatio = fadeRatio;
        glUniform1f(_uFadeRatio, fadeRatio);
        glUseProgram(_phShadow);
        glUniform1f(_uFadeRatioShadow, fadeRatio);
    }
    
    for (int index=0; index<_count; index++) {
        Droplet droplet = _droplets[index];
        glUseProgram(_programHandle);
        /*
        float ratio = 0.6 * droplet.y / 16.0;
        float colors[] = {
            (32.0 + 95.0 * ratio)/255.0,
            (45.0 + 116.0 * ratio)/255.0,
            (54.0 + 132.0 * ratio)/255.0,
            1.0
        };
        glUniform4fv(_uBaseColor, 1, colors);
        */

        GLKMatrix4 modelView = GLKMatrix4MakeTranslation(droplet.x, droplet.y, -10.0);
        /*
        GLKMatrix4 modelShear = GLKMatrix4Identity;
        modelShear.m[8] = sin(detector.attitude.roll) * 1.0;
        modelShear.m[9] = -sin(detector.attitude.pitch) * 1.0;
        modelView = GLKMatrix4Multiply(modelView, modelShear);
        float r = sin(M_PI * CACurrentMediaTime());
        */
        float wobble = 0.05 * sin(M_PI * CACurrentMediaTime() * 8.0) / (1.0 + 3.0 * (CACurrentMediaTime() - droplet.t));
        modelView = GLKMatrix4Scale(modelView,
            XRATIO * droplet.r * (1.0 + wobble), droplet.r * (1.0 - wobble),
            ZRATIO * droplet.r);
        glUniformMatrix4fv(_uModelView, 1, 0, modelView.m);

        GLKMatrix3 normalModelView = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelView), NULL);
        glUniformMatrix3fv(_uNormalModelView, 1, 0, normalModelView.m);
      
        for (int i=0; i<VERTICES_COUNT2; i++) {
          glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufIndices[i]);
          glDrawElements(GL_TRIANGLE_STRIP, VERTICES_COUNT * 2 + 2, GL_UNSIGNED_SHORT, 0);
        }
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufSubdivision);
        glDrawElements(GL_TRIANGLE_STRIP, VERTICES_COUNT * 3, GL_UNSIGNED_SHORT, 0);

        glUseProgram(_phShadow);

        GLKMatrix4 modelShadow = GLKMatrix4MakeTranslation(0.0, -0.15 * droplet.r, -0.1);
        modelShadow = GLKMatrix4Multiply(modelShadow, modelView);
        glUniformMatrix4fv(_uModelViewShadow, 1, 0, modelShadow.m);
        //glUniform4fv(_uBaseColorShadow, 1, colors);
        glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _bufShadow);
        glDrawElements(GL_TRIANGLE_FAN, VERTICES_COUNT*2+2, GL_UNSIGNED_SHORT, 0);
    }
    
    [_shaderBackground render];
}

-(void) _setupCubeTexture {
  glGenTextures(1, &_textureLight);
  glBindTexture(GL_TEXTURE_CUBE_MAP, _textureLight);
  //glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  //glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  //glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_CUBE_MAP, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  //glEnable(GL_TEXTURE_CUBE_MAP);

  GLsizei width = 256;
  GLsizei height = 256;
#if 1
  CVPixelBufferRef pxbuffer = NULL;
  NSDictionary* options = @{
    (NSString*)kCVPixelBufferCGImageCompatibilityKey: @YES,
    (NSString*)kCVPixelBufferCGBitmapContextCompatibilityKey:@YES };
  CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                      kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef)options,
                      &pxbuffer);
  CVReturn status = CVPixelBufferLockBaseAddress(pxbuffer, 0);
  if (status != kCVReturnSuccess){
      NSLog(@"Failed to create pixel buffer");
  }
  GLubyte * spriteData = CVPixelBufferGetBaseAddress(pxbuffer);
#else
  GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
#endif
  
  // Draw two round cicles on the ceiling
  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  CGContextRef ctx = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
        colorSpace, kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedFirst);
  CGColorSpaceRelease(colorSpace);
  CGContextClearRect(ctx, CGRectMake(0.0, 0.0, width, height));
  for (int i=0;i<6;i++) {
    glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_X + i, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
  }
  CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
  CGRect rc1 = { width * 0.4, height * 0.6, width * 0.1, height * 0.1 };
  CGContextFillEllipseInRect(ctx, rc1);
  CGRect rc2 = { width * 0.35, height * 0.6, width * 0.05, height * 0.05 };
  CGContextFillEllipseInRect(ctx, rc2);
  CGContextRelease(ctx);
  
  glTexImage2D(GL_TEXTURE_CUBE_MAP_POSITIVE_Z, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);

#if 1
  CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
  CVPixelBufferRelease(pxbuffer);
#else
  free(spriteData);
#endif
}

-(void) dealloc {
    GLuint textures[] = {
        self.textureBackground,
        self.textureText,
        self.texturePlain,
        _textureLight
    };
    glDeleteTextures(sizeof(textures)/sizeof(textures[0]), textures);
    
    glDeleteProgram(_phShadow);
    
    glDeleteBuffers(sizeof(_bufIndices) / sizeof(_bufIndices[0]), _bufIndices);
    glDeleteBuffers(1, &_bufShadow);
    glDeleteBuffers(1, &_bufSubdivision);
    glDeleteBuffers(1, &_bufVertices);
}

@end
