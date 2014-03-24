//
//  GraphicsLine.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/19/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "GameColor.h"
#import "Vector2D.h"


@interface GraphicsLine : NSObject

- (id) initWithCoordsAndColor:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 lineWidth:(float)lineWidth color:(float[4])color;

- (void) updateCoordinates:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 lineWidth:(float)lineWidth color:(float[4])color;

- (void) draw;

@end

@interface GraphicsQuadLine : NSObject

- (id) initWithCoordsAndColor:(Vector2D*)start end:(Vector2D*)end lineWidth:(float)lineWidth color:(float[4])color;

- (void) updateCoordinates:(Vector2D*)start end:(Vector2D*)end lineWidth:(float)lineWidth color:(float[4])color;

- (void) draw;

@end

