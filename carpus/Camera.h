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

- (id) initWithCenterAndSize:(float)x y:(float)y w:(float)w h:(float)h;

- (void)translateObject:(float)x y:(float)y z:(float)z;

- (BOOL)loadShaders:(NSString*)vshFile fshFile:(NSString*)fshFile program:(GLuint*)program;

@end
