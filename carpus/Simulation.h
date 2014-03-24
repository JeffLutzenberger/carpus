//
//  Simulation.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/11/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Camera.h"
#import "GameGrid.h"
#import "BackgroundGrid.h"

@interface Simulation : NSObject

@property float maxParticleAge;
@property float maxParticleSpeed;
@property int missed;
@property int caught;
@property NSMutableArray* buckets;
@property NSMutableArray* influencers;
@property NSMutableArray* obstacles;
@property NSMutableArray* portals;
@property NSMutableArray* sources;
@property NSMutableArray* sinks;
@property NSMutableArray* touches;
@property NSMutableArray* touchObjects;
@property GameGrid* gameGrid;
@property BackgroundGrid* backgroundGrid;

- (void) touchBegan:(UITouch*)touch;

- (void) touchEnded:(UITouch*)touch;

- (void) touchMoved:(UITouch*)touch;

- (void) update:(float)dt;

- (void) draw:(Camera*)camera;

@end
