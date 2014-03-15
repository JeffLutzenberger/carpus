//
//  GraphicsArc.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/14/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GraphicsArc : NSObject

@property float x;
@property float y;
@property float radius;
@property float lineWidth;
@property float startTheta;
@property float endTheta;
@property float* color;

- (id) initWithPositionAndRadius:(float)x y:(float)y radius:(float)radius lineWidth:(float)lineWidth startTheta:(float)startTheta endTheta:(float)endTheta color:(float[4])color;

- (void) draw;

@end
