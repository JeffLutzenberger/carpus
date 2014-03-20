//
//  GraphicCircle.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

@interface GraphicsCircle : NSObject

@property float x;
@property float y;
@property float radius;
//@property float innerColor[4];
//@property float* outerColor;

- (id) initWithPositionAndRadius:(float)x y:(float)y radius:(float)radius innerColor:(float[4])innerColor outerColor:(float[4])outerColor;

- (void) updateCircle;

- (void) draw;

@end
