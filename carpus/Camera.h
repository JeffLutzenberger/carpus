//
//  Camera.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/11/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Vector2D.h"

@interface Camera : NSObject

@property float width;
@property float height;
@property Vector2D* center;
@property GLKMatrix4 projectionMatrix;
@property GLKMatrix4 baseModelViewMatrix;

@property GLuint basicShader;
@property GLuint textureShader;
@property GLuint hBlurShader;
@property GLuint vBlurShader;
@property GLuint fastBlurShader;

@property GLuint fbo1Texture;
@property GLuint fbo2Texture;

- (id) initWithCenterAndSize:(float)x y:(float)y w:(float)w h:(float)h;

- (void)multiplyModelViewMatrix:(GLKMatrix4)modelView;

- (void)translateObject:(float)x y:(float)y z:(float)z;

- (void)rotateAndTranslateObject:(float)theta x:(float)x y:(float)y z:(float)z;

- (BOOL)loadShaders:(NSString*)vshFile fshFile:(NSString*)fshFile program:(GLuint*)program;

- (void)startRenderFBO1;

- (void)startRenderFBO2;

- (void)endRenderFBO;

@end
