//
//  GraphicsCircleOutline.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/14/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphicsCircleOutline : NSObject

@property float x;
@property float y;
@property float radius;
@property float lineWidth;
@property float* innerColor;
@property float* outerColor;

- (id) initWithPositionAndRadius:(float)x y:(float)y radius:(float)radius lineWidth:(float)lineWidth innerColor:(float[4])innerColor outerColor:(float[4])outerColor;

- (void) draw;

@end
