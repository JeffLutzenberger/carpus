//
//  ParametricShapes.h
//  carpus
//
//  Created by Jeff Lutzenberger on 4/6/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

#import "ParametricShader.h"
#import "Camera.h"
#import "GameColor.h"

@interface ParametricShapes : NSObject

- (id) initWithPositionAndColor:(float)x y:(float)y color:(ETColor)color;

- (void) draw:(Camera*)camera;

- (void)update:(float)timeElapsed;

- (void)loadShapeShade:(ParametricShader*)shader;

@end
