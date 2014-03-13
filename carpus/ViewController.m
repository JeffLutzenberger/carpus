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
#import "GraphicsQuad.h"

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

// Add texture coordinates to Vertex structure as follows
typedef struct {
    float Position[3];
    float Color[4];
    float TexCoord[2]; // New
} Vertex;

// Add texture coordinates to Vertices as follows
const Vertex Vertices[] = {
    {{1, -1, 0}, {1, 0, 0, 1}, {1, 0}},
    {{1, 1, 0}, {1, 0, 0, 1}, {1, 1}},
    {{-1, 1, 0}, {0, 1, 0, 1}, {0, 1}},
    {{-1, -1, 0}, {0, 1, 0, 1}, {0, 0}},
    {{1, -1, -1}, {1, 0, 0, 1}, {1, 0}},
    {{1, 1, -1}, {1, 0, 0, 1}, {1, 1}},
    {{-1, 1, -1}, {0, 1, 0, 1}, {0, 1}},
    {{-1, -1, -1}, {0, 1, 0, 1}, {0, 0}}
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
    
    GLuint floorTexture;
    GLuint fishTexture;
    GLuint texCoordSlot;
    GLuint textureUniform;
    
    Camera* camera;
    
    Simulation * simulation;
    
    GraphicsQuad* quad;
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
    
    floorTexture = [self setupTexture:@"tile_floor.png"];
    //fishTexture = [self setupTexture:@"item_powerup_fish.png"];
    
    self.effect = [[GLKBaseEffect alloc] init];
    
    float w = self.view.bounds.size.width;
    float h = self.view.bounds.size.height;
    float x = w * 0.5;
    float y = h * 0.5;
    camera = [[Camera alloc] initWithCenterAndSize:x y:y w:w h:h];
    
    //[camera loadShaders:@"Shader" fshFile:@"Shader" program:&cameraProg];
    
    //GLuint test;
    //[camera loadShaders:@"basic" fshFile:@"basic" program:&test];
    
    //[camera loadPrivateShaders];
    
    glEnable(GL_DEPTH_TEST);
    
    //NOTE: opengl context must exist before we can add objects...should add a "setupGL" method to
    // the simulation class to decouple object loading from rendering
    [simulation.sources addObject:[[Source alloc] initWithPositionSizeAndSpeed:100 y:100 w:50 h:25 theta:0 speed:10]];
    
    quad = [[GraphicsQuad alloc] initWithPoints:[[Vector2D alloc] initWithXY:0 y:0]
                                             p2:[[Vector2D alloc] initWithXY:w y:0]
                                             p3:[[Vector2D alloc] initWithXY:w y:h]
                                             p4:[[Vector2D alloc] initWithXY:0 y:h]];
    
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
    [camera startRenderFBO];
    glUseProgram([camera basicShader]);
    [camera translateObject:0 y:0 z:0];
    [simulation draw:camera];
    //[camera endRenderFBO];
    
    //[camera startRenderFBO];
    glUseProgram([camera hBlurShader]);
    //glUseProgram([camera textureShader]);
    [camera translateObject:0 y:0 z:0];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, [camera fboTexture]);
    //glBindTexture(GL_TEXTURE_2D, floorTexture);
    [quad draw];
    
    glUseProgram([camera vBlurShader]);
    //glUseProgram([camera textureShader]);
    [camera translateObject:0 y:0 z:0];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, [camera fboTexture]);
    //glBindTexture(GL_TEXTURE_2D, floorTexture);
    [quad draw];
    [camera endRenderFBO];
    
    [((GLKView *) self.view) bindDrawable];

    glClearColor(0.20f, 0.20f, 0.20f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    
    //glDepthMask(false);
    
    //glUseProgram([camera basicShader]);
    //[camera translateObject:0 y:0 z:0];
    //[simulation draw:camera];
    
    
    glUseProgram([camera textureShader]);
    [camera translateObject:0 y:0 z:0];
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, [camera fboTexture]);
    //glBindTexture(GL_TEXTURE_2D, floorTexture);
    [quad draw];
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

@end
