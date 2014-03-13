//
//  Source.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/10/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Rectangle.h"
#import "Particle.h"
#import "Camera.h"

@interface Source : Rectangle

@property float speed;
@property int nparticles;
@property NSMutableArray* particles;

- (id) initWithPositionSizeAndSpeed:(float)x y:(float)y w:(float)w h:(float)h theta:(float)theta speed:(float)speed;

- (void) addParticles;

- (void) recycleParticle:(Particle*)p;

- (void) update:(float)dt;

- (void) draw:(Camera*)camera;

@end
