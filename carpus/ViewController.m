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
#import "Source.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Uniform index.
enum
{
    UNIFORM_MODELVIEWPROJECTION_MATRIX,
    UNIFORM_NORMAL_MATRIX,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum
{
    ATTRIB_VERTEX,
    ATTRIB_NORMAL,
    NUM_ATTRIBUTES
};

@interface ViewController () {
    GLuint _program;
    GLuint cameraProg;
    
    GLuint fbo_width;
    GLuint fbo_height;
    GLuint fboTex;
    GLint defaultFBO;
    GLuint depthBuffer;
    GLuint fboHandle;
    GLuint texId;
    
    Camera* camera;
    
    Simulation * simulation;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

//- (BOOL)loadShaders;
//- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
//- (BOOL)linkProgram:(GLuint)prog;
//- (BOOL)validateProgram:(GLuint)prog;
@end

@implementation ViewController

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
    
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    float w = self.view.bounds.size.width;
    float h = self.view.bounds.size.height;
    float x = w * 0.5;
    float y = h * 0.5;
    camera = [[Camera alloc] initWithCenterAndSize:x y:y w:w h:h];
    
    [camera loadShaders:@"Shader" fshFile:@"Shader" program:&cameraProg];
    
    glEnable(GL_DEPTH_TEST);
    
    //NOTE: opengl context must exist before we can add objects...should add a "setupGL" method to
    // the simulation class to decouple object loading from rendering
    [simulation.sources addObject:[[Source alloc] initWithPositionSizeAndSpeed:100 y:100 w:50 h:25 theta:0 speed:10]];
    
    /*// to test texturing
    GLubyte tex[] = {255, 0, 0, 255, 0, 255, 0, 255, 0, 255, 0, 255, 255, 0, 0, 255};
    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1, &texId);
    glBindTexture(GL_TEXTURE_2D, texId);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 2, 2, 0, GL_RGBA, GL_UNSIGNED_BYTE, tex);
    glBindTexture(GL_TEXTURE_2D, 0);*/
    
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
    
    //NSLog(@"%0.2f", dt);
    [simulation update:dt];
    
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.20f, 0.20f, 0.20f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    glDepthMask(false);
    
    
    // Render the object with GLKit
    // standard opengl-like rendering
    //[self.effect prepareToDraw];
    
    //[camera translateObject:0 y:0 z:-1.5];
    
    //[simulation draw:camera];
    
    // Render the object again with ES2...do the funky shit
    glUseProgram(cameraProg);
    
    [camera translateObject:0 y:0 z:-1.5];
    
    [simulation draw:camera];
   
}

@end
