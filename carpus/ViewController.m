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
#import "Influencer.h"
#import "Sink.h"
#import "GraphicsQuad.h"
#import "ParticleSystem.h"
#import "ShaderParticleSystem.h"
//#import "

@interface MyGestureDelegate : NSObject <UIGestureRecognizerDelegate>
@end

@implementation MyGestureDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    return YES;
}

@end

@interface ViewController () {
    GLuint _program;
    GLuint cameraProg;
    
    GLuint floorTexture;
    
    Camera* camera;
    
    Simulation * simulation;
    
    GraphicsQuad* quad;
    
    GraphicsQuad* fragQuad;
    
    ParticleSystem* particleSystem;
    
    ShaderParticleSystem* shaderParticleSystem;
    
    BOOL interacting;
    BOOL zoomedOut;

}

@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ViewController {
    NSDate *startTime;
    
    NSMutableArray *gameTouches;
    
    MyGestureDelegate *deleg;
    
    //CAKeyframeAnimation* swipeAnimation;
    
    //UITouch* secondTouch;
    //UITouch* thirdTouch;
    //UITouch* fourthTouch;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationFade];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.multipleTouchEnabled = YES;
    view.enableSetNeedsDisplay = YES;
    
    interacting = NO;
    zoomedOut = NO;
    
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

- (BOOL)prefersStatusBarHidden {
    return YES;
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
    
    /***
     Sources
     ***/
    //Source* source = [[Source alloc] initWithPositionSizeAndSpeed:100 y:150 w:20 h:25 theta:0 speed:2];
    //[source setSourceColor:GREEN];
    //[simulation.sources addObject:source];
    
    //source = [[Source alloc] initWithPositionSizeAndSpeed:300 + 2 * 768 y:200 w:24 h:25 theta:0 speed:2];
    //[source setSourceColor:BLUE];
    //[simulation.sources addObject:source];
    
    float fm = 3.0;
    float sm = 1.6;
    /***
     Influencers
     ***/
    Influencer* influencer = [[Influencer alloc] initWithPositionSizeAndForce:100 y:900 radius:15 force:2.5 * fm];
    [simulation.influencers addObject:influencer];
    
    /***
     Sinks
     ***/
    Sink* sink = [[Sink alloc] initWithPositionSizeForceSpeedAndColor:400 y:600 radius:15 force:5 * fm speed:5 * sm inColor:GREEN outColor:GREEN];
    sink.isSource = YES;
    [simulation.sinks addObject:sink];
    
    sink = [[Sink alloc] initWithPositionSizeForceSpeedAndColor:200 y:300 radius:15 force:5 * fm speed:0 inColor:RED outColor:BLUE];
    [simulation.sinks addObject:sink];
    
    //sink = [[Sink alloc] initWithPositionSizeForceSpeedAndColor:500 y:400 radius:15 force:5 * fm speed:0 inColor:BLUE outColor:GREEN];
    //[simulation.sinks addObject:sink];
    
    /*sink = [[Sink alloc] initWithPositionSizeForceAndSpeed:400 + 2 * 768 y:600 radius:15 force:5 speed:5];
    [sink setSinkColor:BLUE outColor:RED];
    [simulation.sinks addObject:sink];
    
    sink = [[Sink alloc] initWithPositionSizeForceAndSpeed:500 + 768 y:600 radius:15 force:5 speed:5];
    [sink setSinkColor:RED outColor:GREEN];
    [simulation.sinks addObject:sink];
    
    sink = [[Sink alloc] initWithPositionSizeForceAndSpeed:300 + 768 y:600 radius:15 force:5 speed:5];
    [sink setSinkColor:GREEN outColor:GREEN];
    [simulation.sinks addObject:sink];
    
    sink = [[Sink alloc] initWithPositionSizeForceAndSpeed:768 * 1.5 y:1024 * 1.5 radius:35 force:10 speed:5];
    [sink setSinkColor:GREEN outColor:GREEN];
    sink.isSource = false;
    sink.isGoal = true;
    [simulation.sinks addObject:sink];*/
    
    //Obstacle* obstacle = [[Obstacle alloc] initWithPositionAndSize:500 y:300 w:300 h:25 theta:-M_2_PI color:ORANGE];
    //[simulation.obstacles addObject:obstacle];
    
    //obstacle = [[Obstacle alloc] initWithPositionAndSize:350 y:150 w:300 h:25 theta:-M_PI * 0.5 color:ORANGE];
    //[simulation.obstacles addObject:obstacle];
    
    //Portal* portal = [[Portal alloc] initWithPositionAndSize:100 y:200 w:30 h:25 theta:0 color:GREEN];
    //[simulation.portals addObject:portal];
    
    simulation.gameGrid = [[GameGrid alloc] initWithWidthHeightAndGridSpacing:768.0 h:1024.0 gridx:768.0 gridy:1024.0];
    //[simulation.gameGrid addDoor:0 tileColIndex:0 wallIndex:1 s1:0.6 s2:1.0];
    //[simulation.gameGrid addDoor:0 tileColIndex:0 wallIndex:3 s1:0.5 s2:0.75];
    //[simulation.gameGrid addDoor:0 tileColIndex:1 wallIndex:1 s1:0.33 s2:0.66];
    //[simulation.gameGrid addDoor:1 tileColIndex:0 wallIndex:3 s1:0.33 s2:0.66];
    //[simulation.gameGrid addDoor:0 tileColIndex:2 wallIndex:2 s1:0.5 s2:0.75];
    
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
    
    //shaderParticleSystem = [[ShaderParticleSystem alloc] initWithPosition:600 y:200];
    //[shaderParticleSystem loadParticleSystem:camera.particleShader];
    
    //camera.particleShader = [[ParticleShader alloc] init];
    
    
    
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
    
    [camera update:dt];
    
    [particleSystem update:dt];
    
    //[shaderParticleSystem update:dt];
    
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
            [camera reset];
            [camera translateObject:0 y:0 z:0];
            [simulation draw:camera];
            glUseProgram(camera.particleShader.program);
            //[shaderParticleSystem draw:camera];
            [simulation drawShaderParticles:camera];
            
            //GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(camera.projectionMatrix, camera.baseModelViewMatrix);
            //glUseProgram(shaderParticleSystem.program);
            //[shaderParticleSystem renderWithProjection:modelViewProjectionMatrix];
            
            [camera endRenderFBO];
        
            //**** fast blur ****
            if (fastBlur) {
                
                [camera startRenderFBO2];
                
                glUseProgram([camera fastBlurShader]);
                glUniform1i(camera.uiVerticalPass, 0);
                [camera resetToFullScreenTextureView];
                [camera translateObject:0 y:0 z:0];
                glActiveTexture(GL_TEXTURE0);
                glBindTexture(GL_TEXTURE_2D, [camera fbo1Texture]);
                [quad draw];
                
                [camera endRenderFBO];
                
                [camera startRenderFBO1];
                
                glUseProgram([camera fastBlurShader]);
                glUniform1i(camera.uiVerticalPass, 1);
                //[camera resetToFullScreenTextureView];
                //[camera translateObject:0 y:0 z:0];
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
            [camera resetToFullScreenTextureView];
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, [camera fbo1Texture]);
            //glBindTexture(GL_TEXTURE_2D, floorTexture);
            [quad draw];
            
            glUseProgram([camera basicShader]);
            [camera reset];
            [camera translateObject:0 y:0 z:0.0];
            [simulation draw:camera];
            //glUseProgram(camera.particleShader.program);
            //[shaderParticleSystem draw:camera];
        } else {
            glUseProgram([camera basicShader]);
            [camera translateObject:0 y:0 z:-0.1];
            [particleSystem draw:camera];
            [simulation draw:camera];
            //GLKMatrix4 modelViewProjectionMatrix = GLKMatrix4Multiply(camera.projectionMatrix, camera.baseModelViewMatrix);
            glUseProgram(camera.particleShader.program);
            [shaderParticleSystem draw:camera];
            //[shaderParticleSystem renderWithShaderAndProjection:camera.particleShader projectionMatrix:modelViewProjectionMatrix];
            //[shaderParticleSystem renderWithProjection:modelViewProjectionMatrix];
            
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

- (void)tapHandle:(UITapGestureRecognizer*)gestureRecognizer {
    NSLog(@"tapHandle");
    if (![camera isZoomedOut]) {
        CGPoint p = [camera screenToWorld:[gestureRecognizer locationInView:self.view]];
        [simulation singleTap:p];
    }
}

- (void)doubleTapHandle:(UITapGestureRecognizer*)gestureRecognizer {
    NSLog(@"doublTapHandle");
    CGPoint p = [camera screenToWorld:[gestureRecognizer locationInView:self.view]];
    if ([camera isZoomedOut]) {
        //zoom in on the tile we just clicked on...
        CGPoint center = [simulation.gameGrid centerOfTouchedTile:p];
        [camera zoomAll:center.x y:center.y extentx:768 extenty:1024];
        zoomedOut = NO;
        return;
    } else if([simulation doubleTap:p]) {
        return;
    } else {
        [camera zoomAll:768 * 0.5 y:1024 * 0.5 extentx:768 * 3 extenty:1024 * 3];
        zoomedOut = YES;
    }
}

- (void)panHandle:(UIPanGestureRecognizer*)gestureRecognizer {
    //NSLog(@"panHandle");
    CGPoint p = [camera screenToWorld:[gestureRecognizer locationInView:self.view]];
    [simulation panGesture:p];
}

- (void)leftSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer {
    NSLog(@"swipe");
    if (!interacting && ![camera isZoomedOut] /* && not at right edge */) {
        [camera startMoveTransition:768 dy:0];
    }
}

- (void)rightSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer {
    NSLog(@"swipe");
    if (!interacting && ![camera isZoomedOut]) {
        [camera startMoveTransition:-768 dy:0];
    }
}

- (void)upSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer {
    NSLog(@"swipe");
    if (!interacting && ![camera isZoomedOut]) {
        [camera startMoveTransition:0 dy:1024];
    }
}

- (void)downSwipeHandle:(UISwipeGestureRecognizer*)gestureRecognizer {
    NSLog(@"swipe");
    if (!interacting && ![camera isZoomedOut]) {
        [camera startMoveTransition:0 dy:-1024];
    }
}

-(void)handlePinchGesture:(UIPinchGestureRecognizer*)recognizer {
    NSLog(@"pinched...");
    //if (!interacting) {
        //get center of grid
        //and zoom out
        if (recognizer.velocity > 0) {
            //get grid center
            [camera zoomAll:768 * 0.5 y:1024 * 0.5 extentx:768 extenty:1024];
            zoomedOut = NO;
        } else {
            //we should detect which tile we're on and zoom there...
            [camera zoomAll:768 * 0.5 y:1024 * 0.5 extentx:768 * 3 extenty:1024 * 3];
            zoomedOut = YES;
        }
    //}
}

// we use this to prevent panning when we're moving a grabber
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    interacting = NO;
    for (UITouch *touch in touches) {
        //CGPoint pos = [camera screenToWorld:[touch locationInView: [UIApplication sharedApplication].keyWindow]];
        //if ([simulation hitInteractable:pos]) {
        if ([simulation touchBegan:touch]) {
            interacting = YES;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    interacting = NO;
    //[simulation touchEnded:<#(UITouch *)#>]
    for (UITouch *touch in touches) {
        [simulation touchEnded:touch];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        [simulation touchMoved:touch];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    interacting = NO;
    //[simulation touchEnded:<#(UITouch *)#>]
    for (UITouch *touch in touches) {
        [simulation touchEnded:touch];
    }
}
@end
