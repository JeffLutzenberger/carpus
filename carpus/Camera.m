//
//  Camera.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/11/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Camera.h"
#import "ShaderLoader.h"

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_TEXTURE,
    //UNIFORM_BLUR_TEXEL_SIZE,
    //UNIFORM_BLUR_ORIENTATION,
    //UNIFORM_BLUR_AMOUNT,
    //UNIFORM_BLUR_SCALE,
    //UNIFORM_BLUR_STRENGTH,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    ATTRIB_TEX_COORDS,
    NUM_ATTRIBUTES
};

@implementation Camera {
    GLKMatrix4 modelViewProjectionMatrix;
    GLKMatrix3 normalMatrix;
    float fboWidth;
    float fboHeight;
    //GLuint fboHandle;
    GLuint fbo1Handle;
    GLuint fbo2Handle;
    GLint defaultFBO;
    GLuint depthBuffer1;
    GLuint depthBuffer2;
    
    bool doTransition;
    Vector2D* startTransitionCenter;
    Vector2D* finalTransitionCenter;
    float startTransitionScale;
    float finalTransitionScale;
    float transitionTime;
    
}

- (id) initWithCenterAndSize:(float)x y:(float)y w:(float)w h:(float)h {
    self = [super init];
    if (self) {
        float left = -w * 0.5;
        float right = w * 0.5;
        float bottom = h * 0.5;
        float top = -h * 0.5;
        self.width = w;
        self.height = h;
        self.viewRect = CGRectMake(left, top, w, h);
        self.center = [[Vector2D alloc] initWithXY:x y:y];
        self.scale = 1.0;
        
        doTransition = false;
        startTransitionCenter = [[Vector2D alloc] initWithXY:0 y:0];
        finalTransitionCenter = [[Vector2D alloc] initWithXY:0 y:0];
        startTransitionScale = 1.0;
        finalTransitionScale = 1.0;
        transitionTime = 0;
        
        self.projectionMatrix = GLKMatrix4MakeOrtho (left, right, bottom, top, 0.1f, 100.0f);
        
        self.baseModelViewMatrix = GLKMatrix4MakeTranslation(-self.center.x, -self.center.y, -1.0f);
        
        normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(self.baseModelViewMatrix), NULL);
        
        modelViewProjectionMatrix = GLKMatrix4Multiply(self.projectionMatrix, self.baseModelViewMatrix);
        
        [self loadShaders:@"fastblur" fshFile:@"fastblur" program:&_fastBlurShader];
        _uiVerticalPass = glGetUniformLocation(_fastBlurShader, "verticalPass");
        [self loadShaders:@"basic" fshFile:@"basic" program:&_basicShader];
        [self loadShaders:@"basic" fshFile:@"basicTexture" program:&_textureShader];
        [self loadShaders:@"basic" fshFile:@"hblur" program:&_hBlurShader];
        [self loadShaders:@"basic" fshFile:@"vblur" program:&_vBlurShader];
        //[self loadShaders:@"basic" fshFile:@"fire" program:&_fireShader];
        
        self.particleShader = [[ParticleShader alloc] init];
        self.parametricShader = [[ParametricShader alloc] init];
        
        [self setupFBO:w * 0.5 height:h * 0.5 fboHandle:&fbo1Handle depthBuffer:&depthBuffer1 fboTexture:&_fbo1Texture];
        [self setupFBO:w * 0.5 height:h * 0.5 fboHandle:&fbo2Handle depthBuffer:&depthBuffer2 fboTexture:&_fbo2Texture];
        
    }
    return self;
}

- (void)translateObject:(float)x y:(float)y z:(float)z {
    
    // Compute the model view matrix for the object rendered with ES2
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(x, y, z);
    modelViewMatrix = GLKMatrix4Multiply(self.baseModelViewMatrix, modelViewMatrix);
    
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    modelViewProjectionMatrix = GLKMatrix4Multiply(self.projectionMatrix, modelViewMatrix);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
}

- (void)rotateAndTranslateObject:(float)theta x:(float)x y:(float)y z:(float)z {
    GLKMatrix4 modelViewMatrix1 = GLKMatrix4MakeTranslation(x, y, z);
    modelViewMatrix1 = GLKMatrix4Multiply(self.baseModelViewMatrix, modelViewMatrix1);
    GLKMatrix4 modelViewMatrix2 = GLKMatrix4MakeRotation(theta, 0.0f, 0.0f, 1.0f);
    modelViewMatrix2 = GLKMatrix4Multiply(modelViewMatrix1, modelViewMatrix2);
    
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix2), NULL);
    
    modelViewProjectionMatrix = GLKMatrix4Multiply(self.projectionMatrix, modelViewMatrix2);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
}

- (void)multiplyModelViewMatrix:(GLKMatrix4)modelViewMatrix {
    
    modelViewMatrix = GLKMatrix4Multiply(self.baseModelViewMatrix, modelViewMatrix);
    
    normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    modelViewProjectionMatrix = GLKMatrix4Multiply(self.projectionMatrix, modelViewMatrix);
    
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
    
}

- (BOOL) isZoomedOut {
    return _scale < 0.999;
}

- (void) moveTo:(float)x y:(float)y {
    _center.x = x;
    _center.y = y;
}

- (void) reset {
    GLKMatrix4 transMatrix = GLKMatrix4MakeTranslation(-self.center.x, -self.center.y, -1.0f);
    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(self.scale, self.scale, 1.0);
    self.baseModelViewMatrix = GLKMatrix4Multiply(transMatrix, scaleMatrix);
    
    //self.baseModelViewMatrix = GLKMatrix4MakeTranslation(-self.center.x, -self.center.y, -1.0f);
    
    modelViewProjectionMatrix = GLKMatrix4Multiply(self.projectionMatrix, self.baseModelViewMatrix);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
}

- (void) resetToFullScreenTextureView {
    self.baseModelViewMatrix = GLKMatrix4MakeTranslation(-384, -512, -1.0f);
    modelViewProjectionMatrix = GLKMatrix4Multiply(self.projectionMatrix, self.baseModelViewMatrix);
    glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, modelViewProjectionMatrix.m);
    glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, normalMatrix.m);
}

- (void) onTransition:(float)dt {
    float duration = 500.0;
    float centerDeltaX = finalTransitionCenter.x - startTransitionCenter.x;
    float centerDeltaY = finalTransitionCenter.y - startTransitionCenter.y;
    float scaleDelta = finalTransitionScale - startTransitionScale;
    
    if (transitionTime > duration) {
        transitionTime = duration;
        doTransition = false;
    }
    
    float s = transitionTime / duration;
    
    float x = startTransitionCenter.x + s * centerDeltaX;
    float y = startTransitionCenter.y + s * centerDeltaY;
    self.scale = startTransitionScale + s * scaleDelta;
    [self moveTo:x y:y];
    transitionTime += dt;
}

- (void) startMoveTransition:(float)dx dy:(float)dy {
    if (!doTransition) {
        doTransition = true;
        transitionTime = 0;
        startTransitionCenter.x = _center.x;
        startTransitionCenter.y = _center.y;
        finalTransitionCenter.x = _center.x + dx;
        finalTransitionCenter.y = _center.y + dy;
        startTransitionScale = self.scale;
        finalTransitionScale = self.scale;
    }
}

- (void) zoomAll:(float)x y:(float)y extentx:(float)extentx extenty:(float)extenty {
    if (!doTransition) {
        doTransition = true;
        transitionTime = 0;
        startTransitionCenter.x = self.center.x;
        startTransitionCenter.y = self.center.y;
        finalTransitionCenter.x = x;
        finalTransitionCenter.y = y;
        startTransitionScale = self.scale;
        finalTransitionScale = 768.0 / extentx;
    }
}

- (CGPoint) screenToWorld:(CGPoint)p {
    float w = 768;
    float h = 1024;
    
    //normalize screen coords 0..1
    float xn = p.x / w;
    float yn = p.y / h;
    
    float left = self.center.x / self.scale - w / self.scale * 0.5;
    float top = self.center.y /self.scale - h / self.scale * 0.5;
    
    float xg = left + xn * w / self.scale;
    float yg = top + yn * h / self.scale;
    
    return CGPointMake(xg, yg);
}

- (void) update:(float)dt {
    if (doTransition) {
        [self onTransition:dt];
    }
};

#pragma mark -  OpenGL ES 2 shader compilation


- (BOOL)loadShaders:(NSString*)vshFile fshFile:(NSString*)fshFile program:(GLuint*)program {
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    *program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:vshFile ofType:@"vsh"];
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:fshFile ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(*program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(*program, fragShader);
    
    // Bind attribute locations.
    // self needs to be done prior to linking.
    glBindAttribLocation(*program, GLKVertexAttribPosition, "position");
    glBindAttribLocation(*program, GLKVertexAttribNormal, "normal");
    glBindAttribLocation(*program, GLKVertexAttribColor, "color");
    glBindAttribLocation(*program, GLKVertexAttribTexCoord0, "texcoord");
    
    // Link program.
    if (![self linkProgram:*program]) {
        NSLog(@"Failed to link program: %d", *program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program) {
            glDeleteProgram(*program);
            program = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(*program, "modelViewProjectionMatrix");
    uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(*program, "normalMatrix");
    uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(*program, "Texture");
    //uniforms[UNIFORM_TEXTURE] = glGetUniformLocation(*program, "Texture");
    //uniforms[UNIFORM_BLUR_TEXEL_SIZE] = glGetUniformLocation(*program, "TexelSize");
    //uniforms[UNIFORM_BLUR_ORIENTATION] = glGetUniformLocation(*program, "Orientation");
    //uniforms[UNIFORM_BLUR_AMOUNT] = glGetUniformLocation(*program, "BlurAmount");
    //uniforms[UNIFORM_BLUR_SCALE] = glGetUniformLocation(*program, "BlurScale");
    //uniforms[UNIFORM_BLUR_STRENGTH] = glGetUniformLocation(*program, "BlurStrength");
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(*program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(*program, fragShader);
        glDeleteShader(fragShader);
    }
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader");
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    
    return YES;
}


#pragma mark - FBO

// intialize FBO
- (void)setupFBO:(float)width height:(float)height fboHandle:(GLuint*)fboHandle depthBuffer:(GLuint*)depthBuffer fboTexture:(GLuint*)fboTexture {
    fboWidth = width;
    fboHeight = height;
    
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &defaultFBO);
    
    glGenFramebuffers(1, fboHandle);
    glGenTextures(1, fboTexture);
    glGenRenderbuffers(1, depthBuffer);
    
    glBindFramebuffer(GL_FRAMEBUFFER, *fboHandle);
    
    glBindTexture(GL_TEXTURE_2D, *fboTexture);
    glTexImage2D( GL_TEXTURE_2D,
                 0,
                 GL_RGBA,
                 fboWidth, fboHeight,
                 0,
                 GL_RGBA,
                 GL_UNSIGNED_BYTE,
                 NULL);
    
    //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    //glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    //glHint(GL_GENERATE_MIPMAP_HINT, GL_DONT_CARE);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, *fboTexture, 0);
    
    glBindRenderbuffer(GL_RENDERBUFFER, *depthBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, fboWidth, fboHeight);
    
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, *depthBuffer);
    
    // FBO status check
    GLenum status;
    status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    switch(status) {
        case GL_FRAMEBUFFER_COMPLETE:
            NSLog(@"fbo complete");
            break;
            
        case GL_FRAMEBUFFER_UNSUPPORTED:
            NSLog(@"fbo unsupported");
            break;
            
        default:
            /* programming error; will fail on all hardware */
            NSLog(@"Framebuffer Error");
            break;
    }
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFBO);
}

// render FBO
- (void)startRenderFBO1 {
    [self startRenderFBO:fbo1Handle];
}

- (void)startRenderFBO2 {
    [self startRenderFBO:fbo2Handle];
}

- (void)startRenderFBO:(GLuint)fboHandle
{
    glBindTexture(GL_TEXTURE_2D, 0);
    //glEnable(GL_TEXTURE_2D);
    glBindFramebuffer(GL_FRAMEBUFFER, fboHandle);
    
    glViewport(0,0, fboWidth, fboHeight);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
}

- (void)endRenderFBO {
    glBindFramebuffer(GL_FRAMEBUFFER, defaultFBO);
}


@end
