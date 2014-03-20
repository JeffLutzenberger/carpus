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


@interface GraphicsLine : NSObject

@property GameColor* color;

- (id) initWithCoordsAndColor:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 lineWidth:(float)lineWidth color:(GameColor*)color;

- (void) updateCoordinates:(float)x1 y1:(float)y1 x2:(float)x2 y2:(float)y2 lineWidth:(float)lineWidth color:(GameColor*)color;

- (void) draw;

@end
