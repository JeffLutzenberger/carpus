//
//  ViewController.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "ViewController.h"
#import "Camera.h"
#import "Simulation.h"
#import "Bucket.h"
#import "Source.h"
#import "Sink.h"
#import "GraphicsQuad.h"
#import "ParticleSystem.h"

@interface ViewController () {
    GLuint _program;
    GLuint cameraProg;
    
    GLuint floorTexture;
    
    Camera* camera;
    
    Simulation * simulation;
    
    GraphicsQuad* quad;
    
    ParticleSystem* particleSystem;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ViewController {
    NSMutableArray *gameTouches;
    
    //UITouch* secondTouch;
    //UITouch* thirdTouch;
    //UITouch* fourthTouch;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.multipleTouchEnabled = true;
    
    gameTouches = [[NSMutableArray alloc] init];
 
    //load our simulation
    simulation = [[Simulation alloc] init];
    
    [self setupGL];
}

- (void)dealloc
{
    [self tearDownGL];
    
    //[simulation tearDownGL];
    //[camera tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    floorTexture = [self setupTexture:@"tile_floor.png"];
    //fishTexture = [self setupTexture:@"item_powerup_fish.png"];
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    float w = self.view.bounds.size.width;
    float h = self.view.bounds.size.height;
    float x = w * 0.5;
    float y = h * 0.5;
    camera = [[Camera alloc] initWithCenterAndSize:x y:y w:w h:h];
    
    glEnable(GL_DEPTH_TEST);
    
    //NOTE: opengl context must exist before we can add objects...should add a "setupGL" method to
    // the simulation class to decouple object loading from rendering
    [simulation.sources addObject:[[Source alloc] initWithPositionSizeAndSpeed:100 y:100 w:25 h:25 theta:0 speed:2]];
    
    [simulation.sinks addObject:[[Sink alloc] initWithPositionSizeForceAndSpeed:400 y:800 radius:15 force:5 speed:5]];
    
    [simulation.buckets addObject:[[Bucket alloc] initWithPositionAndSize:600 y:600 w:100 h:50 theta:M_PI*0.25]];
    
    quad = [[GraphicsQuad alloc] initWithPoints:[[Vector2D alloc] initWithXY:0 y:0]
                                             p2:[[Vector2D alloc] initWithXY:w y:0]
                                             p3:[[Vector2D alloc] initWithXY:w y:h]
                                             p4:[[Vector2D alloc] initWithXY:0 y:h]];
    
    particleSystem = [[ParticleSystem alloc] initWithCoordsAndCapacity:400 y:400 capacity:200];
    
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    //glDeleteBuffers(1, &_vertexBuffer);
    //glDeleteVertexArraysOES(1, &_vertexArray);
    
    self.effect = nil;
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    NSTimeInterval dt = self.timeSinceLastUpdate * 1000;
    
    [particleSystem update:dt];
    
    [simulation update:dt];
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    bool bShowBlur = true;
    bool fastBlur = false;
    if (bShowBlur) {
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        [camera startRenderFBO];
        
        glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glUseProgram([camera basicShader]);
        [camera translateObject:0 y:0 z:0];
        [simulation draw:camera];
    
        //**** fast blur ****
        if (fastBlur) {
            glUseProgram([camera fastBlurShader]);
            GLint verticalPass = glGetUniformLocation([camera fastBlurShader], "verticalPass");
            glUniform1i(verticalPass, 0);
        
            [camera translateObject:0 y:0 z:0];
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, [camera fboTexture]);
            [quad draw];
        
            glUniform1i(verticalPass, 1);
            
            [camera translateObject:0 y:0 z:0];
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, [camera fboTexture]);
            [quad draw];
        } else {
        
            //**** slower blur ****
            glUseProgram([camera vBlurShader]);
            [camera translateObject:0 y:0 z:-1.0];
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, [camera fboTexture]);
            [quad draw];
        
            glUseProgram([camera hBlurShader]);
            [camera translateObject:0 y:0 z:-1.0];
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, [camera fboTexture]);
            [quad draw];
            
            //glUseProgram([camera basicShader]);
            //[camera translateObject:0 y:0 z:-0.1];
            //[particleSystem draw:camera];
            //[simulation draw:camera];
        }
        
        //glEnable(GL_BLEND);
        //glBlendFunc(GL_SRC_ALPHA, GL_ONE);
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE); //this looks really nice for untextured entities
        glDisable(GL_DEPTH_TEST); //we want everything to accumulate
        

        glUseProgram([camera basicShader]);
        [camera translateObject:0 y:0 z:0.0];
        [simulation draw:camera];
        
        [camera endRenderFBO];
    
        [((GLKView *) self.view) bindDrawable];
    }
    
    glClearColor(0.20f, 0.20f, 0.20f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE); //this looks really nice for untextured entities
    glDisable(GL_DEPTH_TEST); //we want everything to accumulate
    
    if (bShowBlur) {
        glUseProgram([camera textureShader]);
        [camera translateObject:0 y:0 z:-1.0];
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, [camera fboTexture]);
        //glBindTexture(GL_TEXTURE_2D, floorTexture);
        [quad draw];
    } else {
        glUseProgram([camera basicShader]);
        [camera translateObject:0 y:0 z:-0.1];
        [particleSystem draw:camera];
        [simulation draw:camera];
    }
}

- (GLuint)setupTexture:(NSString *)fileName {
    // 1
    CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
    if (!spriteImage) {
        NSLog(@"Failed to load image %@", fileName);
        exit(1);
    }
    
    // 2
    size_t width = CGImageGetWidth(spriteImage);
    size_t height = CGImageGetHeight(spriteImage);
    
    GLubyte * spriteData = (GLubyte *) calloc(width*height*4, sizeof(GLubyte));
    
    CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width*4,
                                                       CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
    
    // 3
    CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
    
    CGContextRelease(spriteContext);
    
    // 4
    GLuint texName;
    glGenTextures(1, &texName);
    glBindTexture(GL_TEXTURE_2D, texName);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
    
    free(spriteData);        
    return texName;    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [simulation touchBegan:touch];
        [particleSystem burst:400 y:400 burstRadius:50 speed:0.01 accel:-0.0075 nparticles:20 lifetime:500];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [simulation touchEnded:touch];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [simulation touchMoved:touch];
    }
}
@end
