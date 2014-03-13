//
//  Simulation.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/11/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Simulation.h"
#import "Source.h"

@implementation Simulation {
    
}

- (id) init {
    self = [super init];
    if (self) {
        self.maxParticleAge = 5000; //ms
        self.missed = 0;
        self.sources = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void) update:(float)dt {

    for (int i = 0; i < [self.sources count]; i++) {
        Source* s = [self.sources objectAtIndex:i];
        [s update:dt];
    }
    
    [self moveParticles:dt];
}

- (void) moveParticles:(float)dt {
    for (int i = 0; i < [self.sources count]; i++) {
        Source* s = [self.sources objectAtIndex:i];
        for (int j = 0; j < [s.particles count]; j += 1) {
            Particle* p = [s.particles objectAtIndex:j];
            [self moveParticle:p dt:dt];
        }
    }
}

- (void) moveParticle:(Particle*)particle dt:(float)dt {
    
    [particle move:dt];
    
    [particle trace];
    
    if (particle.age > self.maxParticleAge) {
        self.missed += 1;
        [particle.source recycleParticle:particle];
    }

}

- (void) draw:(Camera*)camera {

    [self drawParticles:camera];
    
    [self drawSources:camera];
    
}

- (void) drawParticles:(Camera*)camera {
    for (int i = 0; i < [self.sources count]; i++) {
        Source* s = [self.sources objectAtIndex:i];
        for (int j = 0; j < [s.particles count]; j++) {
            [[s.particles objectAtIndex:j] draw:camera];
        }
    }
}

- (void) drawSources:(Camera*)camera {
    for (int i = 0; i < [self.sources count]; i++) {
        [[self.sources objectAtIndex:i] draw:camera];
    }
}
@end
