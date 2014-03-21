//
//  GraphicsRectangle.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>
#import "Vector2D.h"
#import "GameColor.h"

@interface GraphicsRectangle : NSObject

@property int lineWidth;

- (id) initWithPositionAndSize:(float)x y:(float)y w:(float)w h:(float)h theta:(float)theta lineWidth:(float)lineWidth color:(float*)color;

- (void) setColor:(float[4])c;

- (void) draw;

@end
