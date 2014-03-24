//
//  BackgroundGrid.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/18/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Vector2D.h"
#import "PointMass.h"
#import "Spring.h"
#import "Camera.h"

@interface BackgroundGrid : NSObject

@property float w;
@property float h;

@property (nonatomic) NSMutableArray* springs;
@property (nonatomic) NSMutableArray* points;
@property (nonatomic) NSMutableArray* fixedPoints;

@property float gridx;
@property float gridy;
@property (nonatomic) NSMutableArray* lines;
@property (nonatomic) NSMutableArray* rows;
@property (nonatomic) NSMutableArray* cols;

- (id) initWithSizeAndSpacing:(float)w h:(float)h gridx:(float)gridx gridy:(float)gridy;

- (void) applyExplosiveForce:(float)x y:(float)y force:(float)force radius:(float)radius;

- (void) update:(float)dt;

- (void) draw:(Camera*)camera;

@end
