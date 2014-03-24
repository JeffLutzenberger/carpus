//
//  Simulation.m
//  carpus
//
//  Created by Jeff.Lutzenberger on 3/11/14.
//  Copyright (c) 2014 Jeff.Lutzenberger. All rights reserved.
//

#import "Simulation.h"
#import "Obstacle.h"
#import "Influencer.h"
#import "Portal.h"
#import "Source.h"
#import "Sink.h"
#import "Bucket.h"


@implementation Simulation {
}

- (id) init {
    self = [super init];
    if (self) {
        self.maxParticleAge = 5000; //ms
        self.maxParticleSpeed = 2;
        self.missed = 0;
        self.caught = 0;
        self.influencers = [[NSMutableArray alloc] init];
        self.obstacles = [[NSMutableArray alloc] init];
        self.portals = [[NSMutableArray alloc] init];
        self.buckets = [[NSMutableArray alloc] init];
        self.sources = [[NSMutableArray alloc] init];
        self.sinks = [[NSMutableArray alloc] init];
        self.touches = [[NSMutableArray alloc] init];
        self.touchObjects = [[NSMutableArray alloc] init];
        //self.backgroundGrid = [[BackgroundGrid alloc] initWithSizeAndSpacing:768.0 h:1024.0 gridx:768.0 / 32.0 gridy:1024.0 / 32.0];
    }
    return self;
}

- (void) update:(float)dt {

    [self.backgroundGrid update:dt];
    
    for (Source* s in self.sources) {
        [s update:dt];
    }
    
    for (Sink* s in self.sinks) {
        [s update:dt];
        //f = -o.force;
        //f = f < 0 ? f * 0.25 : f;
        [self.backgroundGrid applyExplosiveForce:s.x y:s.y force:1.0 radius:s.radius * 10];
        //self.backgroundGrid.applyExplosiveForce(1.0 * 5, new Vector(o.x, o.y), o.radius * 10);
    }

    [self moveParticles:dt];
}

- (void) touchBegan:(UITouch*)touch {
    //touch event can be either a grabber or an interactable object...
    CGPoint pos = [touch locationInView: [UIApplication sharedApplication].keyWindow];
    Particle* p = [[Particle alloc] initWithPositionAndColor:pos.x y:pos.y r:20 color:BLACK];
    //is this a grabber
    for(Sink* s in self.sinks) {
        if ([s hitGrabber:p]) {
            s.grabberSelected = true;
            return;
        }
    }
    Influencer* influencer = nil;
    [self.touches addObject:touch];
    influencer = [[Influencer alloc] initWithPositionSizeAndForce:pos.x y:pos.y radius:15 force:5];
    influencer.enabled = true;
    [self.influencers addObject:influencer];
    return;
}

- (void) touchEnded:(UITouch*)touch {
    NSUInteger index = [self.touches indexOfObject:touch];
    if (index != NSNotFound) {
        id obj = [self.influencers objectAtIndex:index];
        if (obj) {
            [self.touches removeObjectAtIndex:index];
            [self.influencers removeObjectAtIndex:index];
            return;
        }
    }
    CGPoint pos = [touch locationInView: [UIApplication sharedApplication].keyWindow];
    Particle* p = [[Particle alloc] initWithPositionAndColor:pos.x y:pos.y r:20 color:BLACK];
    //is this a grabber
    for(Sink* s in self.sinks) {
        if ([s hitGrabber:p]) {
            s.grabberSelected = false;
            return;
        }
    }
}

- (void) touchMoved:(UITouch*)touch {
    CGPoint pos = [touch locationInView: [UIApplication sharedApplication].keyWindow];
    Particle* p = [[Particle alloc] initWithPositionAndColor:pos.x y:pos.y r:20 color:BLACK];
    NSUInteger index = [self.touches indexOfObject:touch];
    if (index != NSNotFound) {
        id obj = [self.influencers objectAtIndex:index];
        if (obj && [obj class] == [Influencer class]) {
            Influencer* influencer = (Influencer*)obj;
            influencer.x = pos.x;
            influencer.y = pos.y;
            return;
        }
    }
    //is this a grabber
    for(Sink* s in self.sinks) {
        if ([s hitGrabber:p]) {
            s.grabberSelected = true;
            Vector2D* v = [[Vector2D alloc] initWithXY:pos.x y:pos.y];
            [s moveGrabber:v];
            return;
        }
    }
}

- (void) moveParticles:(float)dt {
    for (Source* s in self.sources) {
    //for (int i = 0; i < [self.sources count]; i++) {
        //Source* s = [self.sources objectAtIndex:i];
        for (int j = 0; j < [s.particles count]; j += 1) {
            Particle* p = [s.particles objectAtIndex:j];
            [self moveParticle:p dt:dt];
        }
    }
}

- (void) moveParticle:(Particle*)particle dt:(float)dt {
    
    [particle move:dt];
    
    [particle trace];
    
    [self hitInfluencers:particle dt:dt];
 
    [self hitSinks:particle dt:dt];
 
    [self hitObstacles:particle dt:dt];
    
    [self hitBuckets:particle dt:dt];

    [self hitPortals:particle dt:dt];
    
    [self hitGridWalls:particle dt:dt];
    
    //for(Sink* s in self.touchObjects) {
    //    [s influence:particle dt:dt maxSpeed:[self maxParticleSpeed]];
    //}
    
    if (particle.age > self.maxParticleAge) {
        self.missed += 1;
        [particle.source recycleParticle:particle];
    }

}

- (void) hitObstacles:(Particle*)p dt:(float)dt {
    for (Obstacle* o in self.obstacles) {
        if (!o.enabled) {
            continue;
        }
        
        Vector2D* h = [o hit:p];
        if (h) {
            if (o.reaction > 0) {
                [p bounce:h];
                [p move:dt];
                [p trace];
            } else {
                [p.source recycleParticle:p];
            }
            [p move:dt];
        }
    }
}

- (void) hitBuckets:(Particle*)p dt:(float)dt {
    for (Bucket* b in self.buckets) {
        if (!b.enabled) {
            continue;
        }
        Vector2D* h = [b hit:p];
        if (h) {
            [p move:dt];
        }
    }
}

- (void) hitInfluencers:(Particle*)p dt:(float)dt {
    for (Influencer* i in self.influencers) {
        if (![i enabled]) {
            continue;
        }
        if ([i localizeInfluence] /*&& ![s.grid sameTile:s particle:p]*/) {
            continue;
        }
        if ([i influenceBound] /*&& ![s insideInfluenceRing:p]*/) {
            continue;
        }
        
        if (i.deflectParticles) {
            Vector2D* n = [i bounce:p];
            if (n) {
                //move the particle outside the circle...
                [p bounce:n];
                [p move:dt];
                [p trace];
            }
        }
        
        [i influence:p dt:dt maxSpeed:[self maxParticleSpeed]];
    }
}

- (void) hitPortals:(Particle*)p dt:(float)dt {
    for (Portal* portal in self.portals) {
        if (!portal.enabled) {
            continue;
        }
        if ([portal hit:p]) {
            return;
        }
    }
    return;
}

- (void) hitSinks:(Particle*)p dt:(float)dt {
    for (Sink* s in self.sinks) {
        if (![s enabled]) {
            continue;
        }
        if ([s localizeInfluence] /*&& ![s.grid sameTile:s particle:p]*/) {
            continue;
        }
        if ([s influenceBound] /*&& ![s insideInfluenceRing:p]*/) {
            continue;
        }
        
        if ([p color] != [s inColor]) {
            Vector2D* n = [p cicleLineCollision:s.x cy:s.y r:s.influenceRadius + 8];
            //Vector2D* n = [s bounce:p];
            if (n) {
                //move the particle outside the circle...
                [p bounce:n];
                [p move:dt];
                [p trace];
                return;
            }
        }
        
        if ([s sinkHit:p]) {
            if (s.isSource && [s checkIsFull]) {
                [s recycleParticle:p];
                //p.brightness += 0.1;
                p.age = 0;
                return;
            } else {
                [p.source recycleParticle:p];
                self.caught += 1;
                //NSLog(@"%d", self.caught);
                return;
            }
        }
        [s influence:p dt:dt maxSpeed:[self maxParticleSpeed]];
        //s.influence(p, dt, this.maxParticleSpeed);
    }
};

- (void) hitGridWalls:(Particle*)p dt:(float)dt {
    //where is the particle...
    //i.e. get the grid rect that the particle is in
    Vector2D* v = [self.gameGrid hit:p];
    if (v) {
        [p bounce:v];
        [p move:dt];
        [p trace];
    }
}

- (void) draw:(Camera*)camera {

    [self drawParticles:camera];

    [self drawBuckets:camera];
    
    [self drawInfluencers:camera];
    
    [self drawObstacles:camera];
    
    [self drawPortals:camera];
    
    [self drawSources:camera];
    
    [self drawSinks:camera];
    
    [self.gameGrid draw:camera];
    
    [self.backgroundGrid draw:camera];
    
}

- (void) drawParticles:(Camera*)camera {
    for (int i = 0; i < [self.sources count]; i++) {
        Source* s = [self.sources objectAtIndex:i];
        for (int j = 0; j < [s.particles count]; j++) {
            [[s.particles objectAtIndex:j] draw:camera];
        }
    }
}

- (void) drawBuckets:(Camera*)camera {
    for (Bucket* b in self.buckets) {
        [b draw:camera];
    }
}

- (void) drawInfluencers:(Camera*)camera {
    for (Influencer* i in self.influencers) {
        [i draw:camera];
    }
}

- (void) drawObstacles:(Camera*)camera {
    for (Obstacle* o in self.obstacles) {
        [o draw:camera];
    }
}

- (void) drawPortals:(Camera*)camera {
    for (Portal* p in self.portals) {
        [p draw:camera];
    }
}

- (void) drawSources:(Camera*)camera {
    for (Source* s in self.sources) {
        [s draw:camera];
    }
}

- (void) drawSinks:(Camera*)camera {
    for (Sink* s in self.sinks) {
        [s draw:camera];
    }
}

@end
