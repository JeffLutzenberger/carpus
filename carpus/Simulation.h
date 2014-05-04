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

typedef enum {
    SINK,
    OBSTACLE,
    WALL,
    NREDIRECTNODETYPES
} ETRedirectNodeTypes;

/* 
  PathNode is used to create a linked list of the particle path.
 
  Note: We create a Path once all particles are being redirected by sinks
 i.e. time since the source last emitted a particle is greater than the
 particle lifetime.

*/

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
@property NSMutableArray* paths;

- (void) singleTap:(CGPoint)pos;

- (BOOL) doubleTap:(CGPoint)pos;

- (void) panGesture:(CGPoint)pos;

- (BOOL) touchBegan:(UITouch*)touch;

- (void) touchEnded:(UITouch*)touch;

- (void) touchMoved:(UITouch*)touch;

- (BOOL) hitInteractable:(CGPoint)pos;

- (void) update:(float)dt;

- (void) draw:(Camera*)camera;

- (void) drawShaderParticles:(Camera*)camera;

@end
