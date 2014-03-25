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
#import "Obstacle.h"
#import "Portal.h"
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
    
    GraphicsQuad* fragQuad;
    
    ParticleSystem* particleSystem;
}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ViewController {
    NSDate *startTime;
    
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
    startTime = [NSDate date];
    
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
    
    simulation.backgroundGrid = [[BackgroundGrid alloc] initWithSizeAndSpacing:768.0 h:1024.0 gridx:768.0 / 16.0 gridy:1024.0 / 16.0];
    
    Source* source = [[Source alloc] initWithPositionSizeAndSpeed:100 y:100 w:25 h:25 theta:0 speed:2];
    [source setSourceColor:GREEN];
    
    [simulation.sources addObject:source];
    
    Sink* sink = [[Sink alloc] initWithPositionSizeForceAndSpeed:400 y:800 radius:15 force:5 speed:5];
    [sink setSinkColor:GREEN outColor:RED];
    
    [simulation.sinks addObject:sink];
    
    sink = [[Sink alloc] initWithPositionSizeForceAndSpeed:300 y:400 radius:15 force:5 speed:5];
    [sink setSinkColor:RED outColor:BLUE];
    //sink2.isSource = false;
    [simulation.sinks addObject:sink];
    
    sink = [[Sink alloc] initWithPositionSizeForceAndSpeed:600 y:600 radius:15 force:5 speed:5];
    [sink setSinkColor:BLUE outColor:GREEN];
    //sink3.isSource = false;
    [simulation.sinks addObject:sink];
    
    Obstacle* obstacle = [[Obstacle alloc] initWithPositionAndSize:500 y:300 w:300 h:25 theta:-M_2_PI color:ORANGE];
    [simulation.obstacles addObject:obstacle];
    
    obstacle = [[Obstacle alloc] initWithPositionAndSize:350 y:150 w:300 h:25 theta:-M_PI * 0.5 color:ORANGE];
    [simulation.obstacles addObject:obstacle];
    
    Portal* portal = [[Portal alloc] initWithPositionAndSize:100 y:200 w:30 h:25 theta:0 color:GREEN];
    [simulation.portals addObject:portal];
    
    simulation.gameGrid = [[GameGrid alloc] initWithWidthHeightAndGridSpacing:768.0 h:1024.0 gridx:768.0 gridy:1024.0];
    
    //our fullscreen quad for the fbo texture
    quad = [[GraphicsQuad alloc] initWithPoints:[[Vector2D alloc] initWithXY:0 y:0]
                                             p2:[[Vector2D alloc] initWithXY:w y:0]
                                             p3:[[Vector2D alloc] initWithXY:w y:h]
                                             p4:[[Vector2D alloc] initWithXY:0 y:h]];
    
    fragQuad = [[GraphicsQuad alloc] initWithPoints:[[Vector2D alloc] initWithXY:0 y:0]
                                                 p2:[[Vector2D alloc] initWithXY:w y:0]
                                                 p3:[[Vector2D alloc] initWithXY:w y:h]
                                                 p4:[[Vector2D alloc] initWithXY:0 y:h]];
    
    //particleSystem = [[ParticleSystem alloc] initWithCoordsAndCapacity:400 y:400 capacity:200];
    
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
    bool fastBlur = true;
    bool fireShade = false;
    if (fireShade) {
        [camera startRenderFBO1];
        
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE); //this looks really nice for untextured entities
        glDisable(GL_DEPTH_TEST); //we want everything to accumulate
        
        //glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
        //glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        //glUseProgram([camera basicShader]);
        glUseProgram([camera fireShader]);
        GLint iGlobalTime = glGetUniformLocation([camera fireShader], "iGlobalTime");
        float time = (float)[startTime timeIntervalSinceNow];
        glUniform1f(iGlobalTime, -time);
        [camera translateObject:0 y:0 z:0];
        [fragQuad draw];
        //[camera translateObject:0 y:0 z:0];
        //[simulation draw:camera];
        
        [camera endRenderFBO];
        
        [((GLKView *) self.view) bindDrawable];
        
        glClearColor(0.20f, 0.20f, 0.20f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE); //this looks really nice for untextured entities
        glDisable(GL_DEPTH_TEST); //we want everything to accumulate

        glUseProgram([camera textureShader]);
        [camera translateObject:0 y:0 z:0.0];
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, [camera fbo1Texture]);
        //glBindTexture(GL_TEXTURE_2D, floorTexture);
        [quad draw];
        
    } else {
    
        if (bShowBlur) {
            
            [camera startRenderFBO1];
            
            glEnable(GL_BLEND);
            glBlendFunc(GL_SRC_ALPHA, GL_ONE); //this looks really nice for untextured entities
            glDisable(GL_DEPTH_TEST); //we want everything to accumulate

            glUseProgram([camera basicShader]);
            [camera translateObject:0 y:0 z:0];
            [simulation draw:camera];
            
            [camera endRenderFBO];
        
            //**** fast blur ****
            if (fastBlur) {
                
                [camera startRenderFBO2];
                
                //glUseProgram([camera fireShader]);
                glUseProgram([camera fastBlurShader]);
                GLint verticalPass = glGetUniformLocation([camera fastBlurShader], "verticalPass");
                glUniform1i(verticalPass, 0);
                [camera translateObject:0 y:0 z:0];
                glActiveTexture(GL_TEXTURE0);
                glBindTexture(GL_TEXTURE_2D, [camera fbo1Texture]);
                [quad draw];
                
                [camera endRenderFBO];
                
                [camera startRenderFBO1];
                
                glUseProgram([camera fastBlurShader]);
                glUniform1i(verticalPass, 1);
                [camera translateObject:0 y:0 z:0];
                glActiveTexture(GL_TEXTURE0);
                glBindTexture(GL_TEXTURE_2D, [camera fbo2Texture]);
                [quad draw];
                
                [camera endRenderFBO];
                
            } else {
            
                //**** slower blur ****
                [camera startRenderFBO2];
                
                glUseProgram([camera vBlurShader]);
                [camera translateObject:0 y:0 z:0.0];
                glActiveTexture(GL_TEXTURE0);
                glBindTexture(GL_TEXTURE_2D, [camera fbo1Texture]);
                [quad draw];
            
                [camera endRenderFBO];
                
                [camera startRenderFBO1];
                
                glUseProgram([camera hBlurShader]);
                [camera translateObject:0 y:0 z:0.0];
                glActiveTexture(GL_TEXTURE0);
                glBindTexture(GL_TEXTURE_2D, [camera fbo2Texture]);
                [quad draw];
                
                [camera endRenderFBO];
            }
        
            [((GLKView *) self.view) bindDrawable];
        }
        
        glClearColor(0.20f, 0.20f, 0.20f, 1.0f);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        
        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE); //this looks really nice for untextured entities
        glDisable(GL_DEPTH_TEST); //we want everything to accumulate
        
        if (bShowBlur) {
            glUseProgram([camera textureShader]);
            [camera translateObject:0 y:0 z:0.0];
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, [camera fbo1Texture]);
            //glBindTexture(GL_TEXTURE_2D, floorTexture);
            [quad draw];
            
            glUseProgram([camera basicShader]);
            [camera translateObject:0 y:0 z:0.0];
            [simulation draw:camera];
            
        } else {
            glUseProgram([camera basicShader]);
            [camera translateObject:0 y:0 z:-0.1];
            [particleSystem draw:camera];
            [simulation draw:camera];
        }
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

-(void)handlePinchGesture:(UIPinchGestureRecognizer*)recognizer {
    NSLog(@"pinched...");
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [simulation touchBegan:touch];
        //[particleSystem burst:400 y:400 burstRadius:50 speed:0.5 accel:-0.0009 nparticles:20 lifetime:500];
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
