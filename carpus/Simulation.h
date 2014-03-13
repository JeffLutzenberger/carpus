//
//  Simulation.h
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/11/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Camera.h"

@interface Simulation : NSObject

@property float maxParticleAge;
@property int missed;
@property NSMutableArray* sources;

- (void) update:(float)dt;

- (void) draw:(Camera*)camera;

@end
